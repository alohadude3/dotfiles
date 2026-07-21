{ pkgs, ... }:

{
  imports = [
    ./git.nix
    ./mise.nix
    ./starship.nix
    ./zoxide.nix
    ./zsh.nix
  ];
}
