{ pkgs, ... }:

{
  imports = [
    ./ghostty.nix
    ./git.nix
    ./starship.nix
    ./zsh.nix
  ];
}
