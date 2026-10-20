{ lib, ... }:
{
  options.vix.keys = {
    desktopKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKI8uHEvN0FJe1JzKVCp6kFJ8jHFdIuo4gjsyxEkCurf vix_hentx@vix-cpd5s" # My Major Computation Laptop
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEjjLIXU/K3yrxz8F+0s3fKifRvtuYGmpfy3cU6OWwW vix_hentx@vix-sp6" # My Tablet
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYoSzea9vbY+L9JXllZPGES6lxmHMQb6RSJHtpSWs2x vix_hentx@vix-envy" # My Omni Flip Laptop
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAMkauGTnh+9merxHbIC0G8gjFbyq1RC6aitlkSp9+9K u0_a655@localhost" # XiaoMi 13
      ];
    };
  };
}