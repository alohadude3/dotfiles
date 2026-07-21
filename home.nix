{ config, pkgs, user, ... }:

let
    dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
    imports = [
        ./home # Loads ./home/defaults.nix
    ];

    home.username = user;
    home.stateVersion = "26.05";
    home.packages = with pkgs; [
        fd          # fast find
        fzf         # fuzzy finder
        git
        jq          # json query
        lazygit     # git terminal gui
        lsd         # better ls
        neovim
        pkgs.home-manager
        ripgrep     # fast search
        zoxide      # better cd
    ];
    fonts.fontconfig.enable = true;
    home.sessionVariables = {
        EDITOR = "nvim";
    };

  # symlinks
  home.file.".vimrc".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/.vimrc";
  home.file.".ideavimrc".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/.ideavimrc";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
}
