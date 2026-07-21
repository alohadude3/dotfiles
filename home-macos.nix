{ config, pkgs, user, ... }:

{
    imports = [
        ./home/macos # Loads ./home/macos/defaults.nix
    ];
}
