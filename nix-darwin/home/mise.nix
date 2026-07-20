{ pkgs, ... }:

{
    programs.mise = {
        enable = true;

        # Enable shell integration
        enableZshIntegration = true;

        settings = {
            tools = {
                java = "temurin-21";
                python = "latest";
            };
        };
    };
}
