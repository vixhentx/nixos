{ pkgs, ... }:
let
  addons = {
    "*" = {
      installation_mode = "allowed";
    };

    "uBlock0@raymondhill.net" = {
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
    };

    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
    };
  };
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    policies = {
      AppAutoUpdate = false;
      DisableFeedbackCommands = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      ExtensionSettings = addons;
    };

    profiles.default = {
      id = 0;
      isDefault = true;
      extensions.force = true;

      settings = {
        "browser.toolbars.bookmarks.visibility" = "never";
        "extensions.autoDisableScopes" = 0;
        "signon.rememberSignons" = false;
      };
    };
  };
}
