{ inputs, pkgs, ... }:
let
	flutterDir = inputs.nixpkgs + "/pkgs/development/compilers/flutter";
in
{

	imports = [
		./nvim.nix
		./zsh.nix
		./font.nix
	];

	nix.settings = {
		experimental-features = [ "nix-command" "flakes" ];
		trusted-users = [ "root" "@wheel" ];
		substituters = [
			"https://mirrors.ustc.edu.cn/nix-channels/store"
			"https://cache.nixos.org"
			"https://nix-community.cachix.org"
		];
		trusted-public-keys = [
			"cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
			"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
		];
		# 优化下载设置
		builders-use-substitutes = true;
		keep-outputs = true;
		keep-derivations = true;
		auto-optimise-store = true;
		connect-timeout = 20;
		stalled-download-timeout = 300;
		max-jobs = "auto";
		netrc-file = "/etc/nix/netrc";
	};

	nixpkgs.config.allowUnfree = true;
	nixpkgs.overlays = [
		(final: prev:
			let
				fixedArtifacts = prev.callPackage (flutterDir + "/host-artifacts.nix") {
					inherit (prev.flutter329.scope)
						artifactHashes
						constants
						engineVersion
						engines
						supportedTargetFlutterPlatforms
						useNixpkgsEngine
						;
					hostPlatform = final.stdenv.hostPlatform;
				};

				fixedFlutter329 = prev.flutter329.override {
					artifacts = fixedArtifacts;
				};
			in
			{
				# LocalSend currently builds with flutter329. This avoids nixpkgs'
				# deprecated auto-filled `hostPlatform` argument while keeping it installed.
				flutter329 = fixedFlutter329.overrideAttrs (old: {
					passthru = (old.passthru or { }) // {
						buildFlutterApplication =
							prev.callPackage (flutterDir + "/build-support/build-flutter-application.nix")
								{
									flutter = fixedFlutter329;
								};
					};
				});
			})
	];

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

	environment.sessionVariables = {
		LANG = "zh_CN.UTF-8";
		LANGUAGE = "zh_CN:zh:en_US:en";
		LC_MESSAGES = "zh_CN.UTF-8";
	};

	system.stateVersion = "25.11"; # 保持不变
}
