{
  description = "Nix";

  inputs = {
    # Use `github:NixOS/nixpkgs/nixpkgs-26.05-darwin` to use Nixpkgs 26.05.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    # Use `github:nix-darwin/nix-darwin/nix-darwin-26.05` to use Nixpkgs 26.05.
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, home-manager, nixpkgs }:
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

      # Linux / WSL User-Only Configuration (Standalone Home Manager)
      homeConfigurations."${user}@linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = { inherit user; };
        modules = [
          ./configuration-linux.nix
          ./home.nix
          ./home-linux.nix
          {
            home.homeDirectory = "/home/${user}";
          }
        ];
      };
    };
}
