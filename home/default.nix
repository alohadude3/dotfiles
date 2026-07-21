{ pkgs, ... }:

{
  imports = [
    ./ghostty.nix
    ./git.nix
    ./mise.nix
    ./starship.nix
    ./zoxide.nix
    ./zsh.nix
  ];
}
