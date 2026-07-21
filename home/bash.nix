{ pkgs, ... }:

{
    programs.bash = {
        enable = true;

        shellAliases = {
            ls = "lsd";
            ll = "ls -la";
        };
    };
}
