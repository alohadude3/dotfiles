{ config, pkgs, user, ... }:

{
    imports = [
        ./home/linux # Loads ./home/linux/defaults.nix
    ];
}
