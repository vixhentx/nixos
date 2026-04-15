{ virtualisation, ... }:
{
    virtualisation.docker =
    {
        enable = true;
        storageDriver = "btrfs";
    };
}