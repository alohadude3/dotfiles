{ pkgs, ... }:

{
    programs.git = {
        enable = true;

        settings = {
            fetch.prune = true;
	    # Include mutable configs here 
	    include.path = "~/.gitconfig.local";
        };

        hooks = {
            pre-push = pkgs.writeShellScript "pre-push-hook" ''
            ${builtins.readFile ./git-scripts/prevent-drop-push.sh}
            '';
        };
    };
}
