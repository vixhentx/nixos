{ config, lib, ... }:
let
  cfg = config.vix.program.ai;
  cmds = import ./commands.nix;

  # OpenCode bash 权限 pattern 匹配完整命令行，`*` 是 glob。
  # 每个命令前缀同时生成裸命令 `P` 与带参数 `P *` 两条规则，使裸执行也命中同一动作。
  toRules = action: cmdList:
    builtins.concatMap (c: [
      (lib.nameValuePair c action)
      (lib.nameValuePair "${c} *" action)
    ]) cmdList;

  allowRules = lib.listToAttrs (toRules "allow" (cmds.gitRead ++ cmds.gitManage ++ cmds.nixAllowed ++ cmds.buildTools ++ cmds.readTools));
  denyRules =
    lib.listToAttrs (toRules "deny" cmds.nixDeny)
    // lib.listToAttrs (map (c: lib.nameValuePair c "deny") cmds.dangerousDeny);

  bashRules = { "*" = "ask"; } // allowRules // denyRules;
in
{
  config = lib.mkIf (cfg.enable && cfg.opencode.enable) {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      context = cfg.sharedPrompt;
      settings = {
        model = "{env:OPENCODE_MODEL}";
        small_model = "{env:OPENCODE_SMALL_MODEL}";
        permission = {
          edit = "allow";
          bash = bashRules;
        };
        provider = {
          deepseek = {
            options = {
              apiKey = "{env:DEEPSEEK_API_KEY}";
              baseURL = "https://api.deepseek.com";
            };
          };
          openai = {
            options = {
              apiKey = "{env:OPENAI_API_KEY}";
              baseURL = "{env:OPENAI_API_BASE}";
            };
          };
        };
      };
    };
  };
}
