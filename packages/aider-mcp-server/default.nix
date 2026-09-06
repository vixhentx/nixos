{ pkgs, lib, inputs, ... }:
pkgs.python3Packages.buildPythonApplication {
  pname = "aider-mcp-server";
  version = "0.1.0";
  pyproject = true;
  src = inputs.aider-mcp-server;
  doCheck = false;
  pythonRemoveDeps = [ "pytest" ];
  nativeBuildInputs = [ pkgs.python3Packages.hatchling ];
  propagatedBuildInputs = [
    (pkgs.python3Packages.toPythonModule pkgs.aider-chat)
    pkgs.python3Packages.boto3
    pkgs.python3Packages.mcp
    pkgs.python3Packages.pydantic
    pkgs.python3Packages.rich
  ];
  meta = {
    description = "MCP server that wraps Aider as a coding sub-agent";
    homepage = "https://github.com/disler/aider-mcp-server";
    platforms = lib.platforms.linux;
  };
}
