{ user, ... }:

{
    # Determinate already manages Nix daemon so nix-darwin doesn't need to do it again
    nix.enable = false;

    # Allows installation of non free packages
    nixpkgs.config.allowUnfree = true;

    # aarch64-darwin for Apple Silicone
    # x86_64-darwin for Intel
    nixpkgs.hostPlatform = "aarch64-darwin";

    system.primaryUser = user;
    users.users.${user} = {
        home = "/Users/${user}";
    };
    system.stateVersion = 6;
    system.defaults = {
            NSGlobalDomain = {
            AppleInterfaceStyle = "Dark";
            KeyRepeat = 2;
            InitialKeyRepeat = 15;
            AppleShowAllExtensions = true;
        };
	# Disables mouse acceleration natively (macOS Sonoma+)
	CustomUserPreferences.NSGlobalDomain."com.apple.mouse.linear" = true;
        dock.autohide = true;
        # Finder default to list view
        finder.FXPreferredViewStyle = "Nlsv";
        # Clean desktop
        finder.CreateDesktop = false;
        trackpad.Clicking = true;
    };
    nix-homebrew = {
        enable = true;
        inherit user;
	# Automatically migrate existing Homebrew installation
	autoMigrate = true;
    };
    homebrew = {
        enable = true;
        # Remove anything no listed here
        # onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.extraFlags = [ "--force" ];
        casks = [
            "ghostty"
            "google-chrome"
            "jetbrains-toolbox"
            "linearmouse"
            "logi-options+"
            "sublime-text"
            "sublime-merge"
            "zed"
        ];
    };
}
