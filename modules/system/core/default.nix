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
	i18n.extraLocaleSettings = {
		LC_ADDRESS = "zh_CN.UTF-8";
		LC_IDENTIFICATION = "zh_CN.UTF-8";
		LC_MEASUREMENT = "zh_CN.UTF-8";
		LC_MONETARY = "zh_CN.UTF-8";
		LC_NAME = "zh_CN.UTF-8";
		LC_NUMERIC = "zh_CN.UTF-8";
		LC_PAPER = "zh_CN.UTF-8";
		LC_TELEPHONE = "zh_CN.UTF-8";
		LC_TIME = "zh_CN.UTF-8";
	};

	# 核心网络
	networking.networkmanager.enable = true;
	services.openssh = {
		enable = true;
		settings.PermitRootLogin = "prohibit-password";
	};
	services.gvfs.enable = true;
	services.udisks2.enable = true;

	# 基础工具集
	environment.systemPackages = with pkgs; [
		curl wget git aria2 rsync
		bottom fastfetch bat fd fzf ripgrep
		zstd gnutar unzip p7zip libarchive
		gnupg pass
		eza fd zoxide
		direnv
		delta tmux zellij
		dnsutils lsof pciutils
		strace usbutils lm_sensors
		nix-tree nvd
	];

	programs.dconf.enable = true;
	programs.nix-ld.enable = true;

	environment.sessionVariables = {
		LANG = "zh_CN.UTF-8";
		LANGUAGE = "zh_CN:zh:en_US:en";
		LC_MESSAGES = "zh_CN.UTF-8";
	};

	system.stateVersion = "25.11"; # 保持不变
}
