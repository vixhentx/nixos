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
        model = "openai/gpt-6-astra";
        small_model = "openai/gpt-5.6-terra";
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
          anthropic = {
            options = {
              apiKey = "{env:ANTHROPIC_API_KEY}";
              baseURL = "{env:ANTHROPIC_API_BASE}";
            };
          };
          google = {
            options = {
              apiKey = "{env:GOOGLE_API_KEY}";
              baseURL = "{env:GOOGLE_API_BASE}";
            };
          };
        };
      };
    };
  };
}
