{ pkgs, ... }:

{
  programs.zoxide = {
    enable = true;

    # Home Manager handles shell integration automatically
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
