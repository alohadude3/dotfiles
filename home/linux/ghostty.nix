{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    # macos uses ghostty-bin instead of ghostty
    package = pkgs.ghostty;

    # Home Manager handles shell integration automatically
    enableZshIntegration = true;

    settings = {
      theme = "TokyoNight";

      # Cursor
      shell-integration-features = "no-cursor";
      cursor-style = "block";
      
      # Padding
      window-padding-x = 10;
      window-padding-y = 4;

     # Background blur
     background-opacity = 0.9;
     background-blur = "macos-glass-clear";
     background-opacity-cells = true;
    };
  };
}
