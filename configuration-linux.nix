{ config, pkgs, user, ... }:

{
    # Import hardware configuration if it exists (baremetal), otherwise use dummy values (WSL)
    imports = if builtins.pathExists /etc/nixos/hardware-configuration.nix
        then [ /etc/nixos/hardware-configuration.nix ]
        else [
            # Dummy root filesystem requirement for WSL environments
            ({ ... }: {
                fileSystems."/" = {
                    device = "/dev/disk/by-label/nixos";
                    fsType = "ext4";
                };
                boot.loader.grub.enable = false;
            })
        ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.trusted-users = [ "root" "${user}" ];
    nixpkgs.config.allowUnfree = true;

    environment.variables = {
        NIX_LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
    };

    # WSL specific configuration
    wsl.enable = true;
    wsl.defaultUser = user;

    programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
            stdenv.cc.cc
            zlib
            openssl
            libffi
            libxcrypt
            readline
            sqlite
            bzip2
            xz
            ncurses
            glib
            git
        ];
    };

    networking.hostName = "${user}-linux";

    users.users.${user} = {
        home = "/home/${user}";
        isNormalUser = true;
        extraGroups = [ "wheel" ];
    };

    system.stateVersion = "26.05";
}
