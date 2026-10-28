{ lib, pkgs, package }:
let
  # nixpkgs' npm pack whitelist omits config/, which contains the upstream
  # account-management scripts. Retain it alongside the application modules.
  packageWithAdministration = package.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      mkdir -p "$out/lib/node_modules/LibreChat/config"
      cp -R config/. "$out/lib/node_modules/LibreChat/config/"
    '';
  });
  nodejs = package.nodejs or pkgs.nodejs;

  readAiEnvironment = pkgs.writeScript "librechat-read-ai-environment" ''
    #!${pkgs.bash}/bin/bash --noprofile
    set -ef
    # The source file uses the same trusted shell-exports format as the user
    # AI wrappers. Its output is suppressed, and unrelated exports stay here.
    if ! . "$1" >/dev/null 2>&1; then
      exit 1
    fi
    set +x 2>/dev/null
    set -ef
    if [[ -z "''${OPENAI_API_BASE:-}" || -z "''${OPENAI_API_KEY:-}" ]]; then
      exit 1
    fi
    printf '%s\0%s\0' "$OPENAI_API_BASE" "$OPENAI_API_KEY"
  '';

  loadEnvironment = ''
    set -euo pipefail
    if [[ -z "''${CREDENTIALS_DIRECTORY:-}" ]]; then
      printf '%s\n' 'LibreChat: systemd credentials directory is unavailable.' >&2
      exit 1
    fi
    ai_environment_file="$CREDENTIALS_DIRECTORY/ai-keys-env"
    if [[ ! -r "$ai_environment_file" ]]; then
      printf '%s\n' 'LibreChat: ai-keys-env credential is unreadable.' >&2
      exit 1
    fi

    # NUL framing preserves quotes, whitespace and dollar signs in values.
    # The child starts without inherited provider or application credentials.
    # A failed child yields fewer than two fields and is rejected below.
    mapfile -d "" -t ai_environment < <(
      ${pkgs.coreutils}/bin/env -i \
        PATH=${lib.escapeShellArg (lib.makeBinPath [ pkgs.coreutils ])} \
        ${readAiEnvironment} "$ai_environment_file"
    )
    if [[ "''${#ai_environment[@]}" -ne 2 ]]; then
      printf '%s\n' 'LibreChat: could not load OPENAI_API_BASE and OPENAI_API_KEY from ai-keys-env.' >&2
      exit 1
    fi
    export OPENAI_API_BASE="''${ai_environment[0]}"
    export OPENAI_API_KEY="''${ai_environment[1]}"
    unset ai_environment ai_environment_file

    if [[ ! "$OPENAI_API_BASE" =~ ^https?://[^[:space:]]+$ ]]; then
      printf '%s\n' 'LibreChat: OPENAI_API_BASE must be an HTTP(S) URL without whitespace.' >&2
      exit 1
    fi
    for variable in CREDS_KEY CREDS_IV JWT_SECRET JWT_REFRESH_SECRET; do
      if [[ -z "''${!variable:-}" ]]; then
        printf 'LibreChat: required application credential %s is missing.\n' "$variable" >&2
        exit 1
      fi
    done
    if [[ ! "$CREDS_KEY" =~ ^[[:xdigit:]]{64}$ || ! "$CREDS_IV" =~ ^[[:xdigit:]]{32}$ ]]; then
      printf '%s\n' 'LibreChat: CREDS_KEY must be 64 hex characters and CREDS_IV must be 32 hex characters.' >&2
      exit 1
    fi
    unset variable
  '';

  serverLauncher = pkgs.writeScript "librechat-server-with-ai-env" ''
    #!${pkgs.bash}/bin/bash
    ${loadEnvironment}
    exec ${lib.escapeShellArg (lib.getExe packageWithAdministration)} "$@"
  '';

  createUserLauncher = pkgs.writeScript "librechat-create-user-with-ai-env" ''
    #!${pkgs.bash}/bin/bash
    ${loadEnvironment}
    exec ${lib.getExe nodejs} ${packageWithAdministration}/lib/node_modules/LibreChat/config/create-user.js "$@"
  '';
in
pkgs.symlinkJoin {
  name = "${lib.getName package}-with-ai-env-${lib.getVersion package}";
  version = lib.getVersion package;
  inherit (package) meta;
  paths = [ packageWithAdministration ];
  postBuild = ''
    rm "$out/bin/librechat-server"
    ln -s ${serverLauncher} "$out/bin/librechat-server"
    ln -s ${createUserLauncher} "$out/bin/librechat-create-user-internal"
  '';
}
