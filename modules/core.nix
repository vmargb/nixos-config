{ config, pkgs, ... }:

{
  # System level core packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    btop
    glow
    fastfetch
    ripgrep
    fd
  ];

  nixpkgs.config.allowUnfree = true;

  users.users.vmargb = {
    isNormalUser = true;
    description = "vmargb";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Auto system optimise and garbage collection
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
    persistent = true;  # catch missed runs
  };

  # enable zram (compresses RAM instead of using disk swap)
  zramSwap = {
    enable = true;
    algorithm = "zstd";  # best for compression/speed
    memoryPercent = 30;  # ~half your RAM
  };

  # State version
  system.stateVersion = "25.11"; # does NOT need to be bumped when upgrading

  # Home Manager basic config
  home-manager.users.vmargb = { pkgs, ... }: {
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;

    # Basic configurations
  };
}
