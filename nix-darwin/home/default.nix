{ pkgs, ... }:

{
  imports = [
    ./ghostty.nix
    ./git.nix
    ./mise.nix
    ./starship.nix
    ./zsh.nix
  ];
}
