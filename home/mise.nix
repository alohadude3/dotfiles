{ pkgs, ... }:

{
    programs.mise = {
        enable = true;

        # Enable shell integration
        enableZshIntegration = true;
	    enableBashIntegration = true;

        globalConfig = {
            tools = {
                java = "temurin-21";
                python = "3.13";
            };
            settings = {
                auto_install = true;
                all_compile = false;
                trusted_config_paths = [
                    "~/.dotfiles"
                ];
            };
        };
    };
}
