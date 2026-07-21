{
  description = "Nix";

  inputs = {
    # Use `github:NixOS/nixpkgs/nixos-26.05` for stable Linux & Darwin.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Use `github:nix-darwin/nix-darwin/nix-darwin-26.05` to use Nixpkgs 26.05.
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, home-manager, nixpkgs, nixos-wsl }:
    let
      # The one username line to change if this isn't your machine.
      user = "lhuang";
    in
    {
      # macos
      darwinConfigurations."Leos-Macbook" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user; };
        modules = [
          ./configuration-macos.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit user; };
            home-manager.users.${user} = {
              imports = [
                ./home.nix
                ./home-macos.nix
              ];
              home.homeDirectory = "/Users/${user}";
            };
          }
        ];
      };

      # Linux / WSL NixOS System
      nixosConfigurations.linux = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs user; };
        modules = [
          nixos-wsl.nixosModules.default
          ./configuration-linux.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs user; };
            home-manager.users.${user} = {
              imports = [
                ./home.nix
                ./home-linux.nix
              ];
              # Enforce homeDirectory cleanly here to avoid lower-level conflicts
              home.homeDirectory = "/home/${user}";
            };
          }
        ];
      };
    };
}
