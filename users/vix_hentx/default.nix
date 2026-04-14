{ pkgs, ... }:
{
	imports = [
		./theme/default.nix
	];

	users.users.vix_hentx = {
		isNormalUser = true;
		description = "Trihydra";
		extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" "wireshark" ];
		initialPassword = "vix";
		shell = pkgs.zsh;
	};
}
