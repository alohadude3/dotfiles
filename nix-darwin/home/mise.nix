{ pkgs, ... }:

{
    programs.mise = {
        enable = true;

        # Enable shell integration
        enableZshIntegration = true;

        globalConfig = {
            tools = {
                java = "temurin-21";
                python = "latest";
            };
        };
    };
}
