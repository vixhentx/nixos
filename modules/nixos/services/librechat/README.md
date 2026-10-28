# LibreChat 系统服务

面向 `vix-szcloud` 的原生 NixOS LibreChat 模块，入口为
`vix.services.librechat`。本模块通过现有 `services.librechat` 管理
systemd 服务，不使用 Docker，不在运行时执行 npm 安装。

当前提供基础聊天、一个共享 OpenAI 兼容端点、本地 MongoDB、关闭注册的
邮箱密码登录，以及交互式账户创建命令。历史搜索和文档 RAG 的后续规划见文末。

本次实现没有执行评估、构建、测试或运行验证，也没有创建提交。

## 文件分工

| 文件 | 职责 |
| --- | --- |
| `default.nix` | 模块接口、系统级 agenix、原生服务和本地 MongoDB |
| `package.nix` | 保留上游账户脚本、包装服务与账户脚本的运行时环境 |
| `administration.nix` | `librechat-create-user` 交互式运维命令 |

## 启用前需要准备

1. 确定真实外部访问 origin，例如 `https://chat.example.com`，不要带路径或末尾 `/`。
2. 确定网关实际支持的模型 ID，至少填写一个；本模块不猜测模型可用性。
3. 准备现有 `ai-keys-env.age` 和新增 `librechat-env.age`。
4. 在加密密钥仓库中为这两份文件授权 `vix-szcloud` 的 age 身份。
5. 更新主仓库锁定的 `age-secrets` 输入，使其包含新增或重新加密的文件。

默认文件位置是 `${inputs.age-secrets}/secrets/ai-keys-env.age` 和
`${inputs.age-secrets}/secrets/librechat-env.age`。加密文件和 age 接收者声明
在密钥仓库维护，不由本模块生成或修改。

本仓库已全局导入 agenix NixOS 模块。独立复用本模块时需要另外导入它。
本模块自行声明所需的系统级 secrets，不要求开启 `vix.secrets.enable`，
也不使用 Home Manager 的 secret 路径。

## 主机侧最小配置

以下为需要用户之后加入目标主机的示例；本次没有修改主机配置。
域名和模型 ID 都是占位示例，必须替换。

```nix
vix.services.librechat = {
  enable = true;
  publicUrl = "https://chat.example.com";
  endpoint = {
    name = "AI Gateway";
    models = {
      fetch = true;
      default = [ "replace-with-real-model-id" ];
    };
  };
};
```

服务默认只监听 `127.0.0.1:3080`，不开放防火墙端口。外部入口由主机侧
另行管理，需正确处理流式响应和应用实际使用的转发协议。
`publicUrl` 仅配置应用的客户端和服务端 URL，不创建外部入口。

本模块位于 Snowfall 的 NixOS 模块目录。使用 Git flake 时，部署前需将
新增文件纳入 Git 跟踪；不要求先创建提交。

## 共享 AI 环境变量

继续使用用户模块的同一份加密 exports 文件；与当前用户 AI 包装器一样，
文件必须是 Bash 兼容的可信 shell 内容，不能包含仅支持 zsh 的语法。
例如其相关部分为：

```sh
export OPENAI_API_BASE='https://gateway.example.com/v1'
export OPENAI_API_KEY='replace-with-real-token'
```

可保留文件中其他供应商的变量，本模块只提取上述两项。BaseURL 原样使用，
不自动拼接或去除 `/v1`；应填写网关约定的 API 根地址。

加载链路为：

```text
ai-keys-env.age
  -> 系统级 agenix 解密，root:root / 0400
  -> systemd LoadCredential=ai-keys-env:...
  -> 包装器在干净的 Bash 子进程中 source
  -> NUL 分隔提取 OPENAI_API_BASE 与 OPENAI_API_KEY
  -> 导出这两项并 exec LibreChat
```

加载阶段抑制源文件的标准输出和错误输出；失败时只报告缺少的变量名或
加载失败，不打印变量值。不相关的 shell exports 不会覆盖父进程中的
`MONGO_URI`、`PORT` 或应用固定密钥。

生成的 `librechat.yaml` 使用 `${OPENAI_API_BASE}`、`${OPENAI_API_KEY}`
占位符。真实供应商凭据不进入生成的 YAML、Nix 字符串或启动命令行。
不要把真实 Token 写入 `services.librechat.env` 或 `settings`。

## LibreChat 独立固定密钥

`librechat-env.age` 的明文使用 systemd `EnvironmentFile` 格式，不要带
`export`、命令替换或其他 shell 语句：

```dotenv
CREDS_KEY=<64 个十六进制字符>
CREDS_IV=<32 个十六进制字符>
JWT_SECRET=<独立生成的 64 个十六进制字符>
JWT_REFRESH_SECRET=<独立生成的 64 个十六进制字符>
```

可以在可信环境中分别使用 `openssl rand -hex 32` 生成三份独立的
32 字节密钥，使用 `openssl rand -hex 16` 生成 IV，再写入 agenix 编辑器。
不要使用上述说明文字作为实际值，也不要提交明文。

本模块将加密文件解密为 root 专用文件，并交给原生
`services.librechat.credentialsFile` / systemd `EnvironmentFile` 加载。
这些值应长期固定：尤其是 `CREDS_KEY` 和 `CREDS_IV`，恢复原数据时必须
恢复相同的值。修改 JWT 密钥会使相关已有登录令牌失效。

不要把应用四项密钥放进共享 `ai-keys-env`：该文件的其他变量不会被传入应用。

### 使用已有运行时文件

也可以跳过本模块对应的 agenix 声明，显式提供绝对路径字符串：

```nix
vix.services.librechat = {
  # 其余必填配置同上。
  aiEnvironmentFile = "/run/secrets/ai-keys-env";
  credentialsFile = "/run/secrets/librechat-env";
};
```

两项彼此独立；仅覆盖一项时，另一项仍使用 agenix。
提供者需要保证文件在服务启动前存在，并自行接好文件生成的启动顺序。
不要写成 `./plaintext.env` 这样的 Nix 路径字面量，避免将明文复制进 store。

若仅需要改变加密文件来源，使用 `aiKeysSecretFile` 或
`applicationSecretFile`，无需覆盖运行时路径。

## 关键设置

| 选项（相对 `vix.services.librechat`） | 默认 / 行为 |
| --- | --- |
| `enable` | `false` |
| `package` | `pkgs.librechat`；包装逻辑面向当前 nixpkgs 包布局 |
| `host` / `port` | `127.0.0.1` / `3080` |
| `publicUrl` | 必填的外部 HTTP(S) origin |
| `dataDir` | `/var/lib/librechat`；不包含 MongoDB 数据目录 |
| `endpoint.name` | `AI Gateway` |
| `endpoint.models.fetch` | `true`；网关必须支持模型列表接口 |
| `endpoint.models.default` | 必填、非空的真实模型 ID 列表 |
| `endpoint.titleConvo` | `false`，不自动发起标题生成请求 |
| `endpoint.titleModel` | 默认 `null`；启用标题生成时必须明确指定 |
| `aiEnvironmentFile` / `credentialsFile` | `null` 表示使用本模块管理的 agenix 路径 |
| `aiKeysSecretFile` / `applicationSecretFile` | 对应的加密文件来源 |

如果网关没有模型列表接口，将 `endpoint.models.fetch = false`，并在
`endpoint.models.default` 中列出要展示的模型。`fetch = true` 时，默认列表
用于回退，不是限制用户调用模型的授权名单；真正的模型权限应由网关控制。

高级非秘密配置继续使用上游 `services.librechat.env` 和
`services.librechat.settings`。本模块为常用项使用 `mkDefault`；上游普通定义
可覆盖这些默认值。例如：

```nix
services.librechat.settings.interface.customWelcome = "Welcome";
```

`endpoints.custom` 是列表，普通定义会替换本模块的默认端点列表，而不是
自动按端点名称合并。自定义该列表时，需要保留所需的环境变量占位符。
模块的必填检查仍按 `vix.services.librechat` 的接口执行。

当前固定使用本地 MongoDB，URI 为 `mongodb://127.0.0.1:27017/LibreChat`，
默认绑定回环地址。LibreChat 在 systemd 层依赖并排在 MongoDB 之后启动；
数据库尚未就绪造成的应用退出由原生服务的重启策略处理。

## 首次创建账户

完成部署、应用数据目录已由原生服务创建后，在服务器终端执行：

```sh
sudo librechat-create-user
```

命令通过带伪终端的临时 systemd 服务运行上游 `config/create-user.js`，
使用应用用户、数据目录、生成的 YAML、同一份 AI credential 和应用密钥。
包装包保留上游账户脚本所需的 `config/`，无需在服务器上重新下载源码或
执行 npm 安装。

按提示输入邮箱、名称、用户名和密码。密码不要留空，也不要放在命令行参数中。
`Email verified?` 选择默认的 `Y`：首版没有配置验证邮件，且拒绝未验证邮箱登录。
该入口创建本地用户账户，不负责额外分配管理员角色。

默认账户策略：

- 允许邮箱密码登录。
- 禁用公开注册、社交登录和社交注册。
- 禁止未验证邮箱登录。
- 关闭邮件密码重置；首版不配置 SMTP 或 SSO。

`librechat-create-user` 是需要 root 的运维入口，不绕过浏览器端的注册限制。
密码重置和角色管理暂不提供单独的封装命令；后续扩展应复用同一临时服务
凭据环境调用锁定版本的上游脚本，而不是直接写数据库或手工处理密码哈希。

## 密钥更新与重启

使用本模块管理的加密文件时，其 store 路径属于服务的 `restartTriggers`。
更新密钥仓库、更新相关 flake 输入并部署之后，密文内容变化会触发服务重启。
文件内容在进程启动时读取，不会因交互式用户的 shell 环境而改变。

如果直接替换运行时文件但路径不变，需要自行重启：

```sh
sudo systemctl restart librechat.service
```

该命令不是在本次实现过程中执行的。不要使用环境变量转储来排查密钥；
运行时加载错误会通过服务日志报告缺失字段名。

## 备份与恢复

需备份的三个部分：

1. MongoDB 中的 `LibreChat` 数据库，包括账户、会话、消息等持久记录。
2. `dataDir` 下的上传文件、生成图片等数据，默认 `/var/lib/librechat`。
3. 两份加密文件、解密身份的安全备份，以及恢复该实例所需的固定密钥版本。

MongoDB 的数据库文件在它自己的 `services.mongodb.dbpath` 下，不在应用
`dataDir` 内。在线备份应使用兼容服务器版本的 MongoDB 备份工具；不要把
复制正在写入的数据库目录当作一致性备份。协调数据库和上传文件的备份时间，
需要一致快照时暂停应用写入。

恢复顺序：停止应用写入，准备解密身份与固定密钥，恢复 MongoDB 和上传文件，
恢复数据目录属主，再启动服务。不要在恢复原数据库时重新生成 `CREDS_KEY`
和 `CREDS_IV`。记录使用的 nixpkgs 提交及 LibreChat 版本，避免盲目跨版本恢复。

## Roadmap

### 阶段一：基础聊天（本次代码范围，未运行验证）

- 原生 LibreChat 与本地 MongoDB。
- 共享 OpenAI 兼容网关，运行时加载 BaseURL / Token。
- 独立应用密钥、关闭注册、手动创建本地账户。
- 提供真实 origin 和模型 ID 后由用户决定部署时机。

### 阶段二：历史会话全文搜索

目标是搜索 MongoDB 中已有的聊天内容，不是联网搜索，也不是文档 RAG。

实现路线：

1. 在模块接口中增加按需启用搜索的选项，复用
   `services.librechat.meilisearch.enable`。
2. 新增独立 Meilisearch master key secret，配置
   `services.meilisearch.masterKeyFile`；由上游模块向 LibreChat 注入一致的 key。
3. 明确只监听本机、持久目录、服务顺序和资源限制。
4. 按所选版本记录旧会话的索引建立方法、索引重建与升级流程。
5. 更新备份说明，区分可重建的索引与不能丢失的 MongoDB 原始记录。

进入这一阶段前，需要决定服务器内存预算、索引保留量和升级窗口。
本次没有启用 Meilisearch，也没有准备其密钥。

### 阶段三：上传文档与知识库 RAG

实现路线：

1. 为 RAG API 提供独立的服务/包实现，保持与主模块的文件边界。
2. 使用 NixOS PostgreSQL 服务，并为对应 PostgreSQL 版本接入 pgvector；
   单独管理数据库、用户、扩展和认证。
3. 明确 Embedding 服务、协议、BaseURL、Token、模型和向量维度。
   不假定聊天网关支持 Embedding，也不默认将聊天 Token 传给新服务。
4. 接好 LibreChat 到 RAG API 的地址、认证、启动顺序和上传文档存储。
5. 再开放相应的文件搜索界面，并记录文档解析依赖及资源限制。
6. 补充 PostgreSQL、原始文档和索引的备份；更换 Embedding 模型或维度时
   制定重新切块/嵌入和索引迁移方案。

进入这一阶段前，需要决定文档类型、大小与数量、Embedding 提供方、资源预算
和数据发送范围。本次不部署 RAG API、PostgreSQL、pgvector，也不启用文件检索。

### 阶段四：按需扩展

- SSO / SMTP：明确身份源、回调 origin、注册准入和密钥管理后再接入。
- 多协议供应商：分别确认 Anthropic、Google 的代理协议与变量映射，不能将
  OpenAI 兼容 BaseURL 机械地复用于其他原生协议。
- Agents / MCP：单独设计服务端工具进程、运行身份、网络访问与凭据范围。
- 运维命令：补充密码重置和角色管理入口，继续通过受控的临时服务运行。
- 升级：同步确认 YAML schema、账户脚本目录与 nixpkgs 打包布局。

## 上游参考

- [NixOS LibreChat 模块（当前锁定提交）](https://github.com/NixOS/nixpkgs/blob/e7439b6b14ad3cc35d05608ebca9bce01a25f5f8/nixos/modules/services/web-apps/librechat.nix)
- [nixpkgs LibreChat 打包定义（当前锁定提交）](https://github.com/NixOS/nixpkgs/blob/e7439b6b14ad3cc35d05608ebca9bce01a25f5f8/pkgs/by-name/li/librechat/package.nix)
- [LibreChat v0.8.7 配置示例](https://github.com/danny-avila/LibreChat/blob/v0.8.7/librechat.example.yaml)
- [LibreChat v0.8.7 创建账户脚本](https://github.com/danny-avila/LibreChat/blob/v0.8.7/config/create-user.js)
- [环境变量](https://www.librechat.ai/docs/configuration/dotenv)
- [YAML 配置](https://www.librechat.ai/docs/configuration/librechat_yaml)
- [Meilisearch](https://www.librechat.ai/docs/configuration/meilisearch)
- [RAG API](https://www.librechat.ai/docs/configuration/rag_api)

官方在线文档可能覆盖较新的开发版本。新增功能应以部署时锁定的包版本及
其配置 schema 为准，而不是默认复制网站最新示例。
