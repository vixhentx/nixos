{ config, lib, pkgs, package, aiEnvironmentFile, credentialsFile }:
let
  native = config.services.librechat;
  environmentArguments = lib.escapeShellArgs (
    lib.mapAttrsToList (name: value: "--setenv=${name}=${toString value}") native.env
  );
in
pkgs.writeScriptBin "librechat-create-user" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail
  if (( EUID != 0 )); then
    printf '%s\n' 'Run this command as root: sudo librechat-create-user' >&2
    exit 1
  fi

  # The system manager reads the root-owned secret files. The account script
  # runs as the application user and uses the application's generated YAML.
  # No token or application encryption key is passed on the command line.
  exec ${config.systemd.package}/bin/systemd-run \
    --quiet --wait --collect --pty --service-type=exec \
    --description='LibreChat interactive account creation' \
    ${lib.escapeShellArg "--property=User=${native.user}"} \
    ${lib.escapeShellArg "--property=Group=${native.group}"} \
    ${lib.escapeShellArg "--property=WorkingDirectory=${native.dataDir}"} \
    ${lib.escapeShellArg "--property=EnvironmentFile=${credentialsFile}"} \
    ${lib.escapeShellArg "--property=LoadCredential=ai-keys-env:${aiEnvironmentFile}"} \
    --property=Requires=mongodb.service \
    --property=After=mongodb.service \
    --property=UMask=0077 \
    --property=NoNewPrivileges=yes \
    --property=PrivateTmp=yes \
    --property=ProtectHome=yes \
    ${environmentArguments} \
    -- ${lib.escapeShellArg "${package}/bin/librechat-create-user-internal"} "$@"
''
