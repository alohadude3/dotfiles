{ pkgs, ... }:

{
  imports = [
    ./bash.nix
    ./git.nix
    ./mise.nix
    ./starship.nix
    ./zoxide.nix
    ./zsh.nix
  ];
}
