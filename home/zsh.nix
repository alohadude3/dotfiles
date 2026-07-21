{ pkgs, ... }:

{
    programs.zsh = {
        enable = true;
        autosuggestion.enable = true;      # ghost text from history
        syntaxHighlighting.enable = true;  # commands turn green when valid

        initContent = ''
        '';

        shellAliases = {
            ls = "lsd";
            ll = "ls -la";
        };
    };
}
