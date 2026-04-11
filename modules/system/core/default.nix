{ pkgs, ... }: {

	imports = [
		./nvim.nix
		./zsh.nix
	];

	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	nixpkgs.config.allowUnfree = true;

	# 基础引导与内核
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.kernelPackages = pkgs.linuxPackages_latest;

	# 区域与语言
	time.timeZone = "Asia/Hong_Kong";
	i18n.defaultLocale = "zh_CN.UTF-8";

	# 核心网络
	networking.networkmanager.enable = true;
	services.openssh = {
		enable = true;
		settings.PermitRootLogin = "prohibit-password";
	};

	# 基础工具集
	environment.systemPackages = with pkgs; [
		curl
		wget
		git
		aria2
		rsync
	];

	system.stateVersion = "25.11"; # 保持不变
}
