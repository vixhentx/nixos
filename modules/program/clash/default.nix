{ ... }:
{
	programs.clash-verge = 
	{
		enable = true;
		autoStart = true;
		group = "wheel";
		tunMode = true;
		serviceMode = true;
	};
}