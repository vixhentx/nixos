{ pkgs, ... }:
{
	fonts = {
		packages = with pkgs; [
			sarasa-gothic
			noto-fonts-color-emoji
			nerd-fonts.symbols-only
            fira-code
		];

		fontconfig = {
			enable = true;
			defaultFonts = {
				serif = [ "Sarasa UI SC" ];
				sansSerif = [ "Sarasa UI SC" ];
				monospace = [ "Sarasa Mono SC" ];
				emoji = [ "Noto Color Emoji" ];
			};
		};
	};

}