{ pkgs, ... }:  # Base system config - things you're never going to change

{
  # user account
  users.users.vmargb = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    shell = pkgs.bash; # make bash default shell at LOGIN
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;  # ignore uncommitted flake changes
    auto-optimise-store = true;  # deduplicate store paths automatically
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";  # or "03:15" daily, "Sun 04:00" Sundays
    options = "--delete-older-than 7d";  # keep 1 week of generations
    persistent = true;  # catch missed runs
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";  # best for compression/speed
    memoryPercent = 30;  # ~half your RAM
  };

  # shared system packages
  environment.systemPackages = with pkgs; [
    xwayland-satellite

    # terminal essentials
    git
    wget
    curl
    btop # task manager

    # media controls
    brightnessctl # brightness control
    playerctl # media player control

    # widgets
    pamixer # volume up and down
    pavucontrol # audio GUI
    acpi # battery info
    networkmanagerapplet # nm-connection-editor

    # sync and sharing
    tmux
    openssh
    rsync
  ];

  # enable and configure SSH
  services.openssh = {
    enable = true;
    permitRootLogin = "no";          # disable root login via SSH
    passwordAuthentication = false;  # disable password login (use SSH keys only)
    port = 2222;                     # SSH server port from default 22 to 2222
  };

  networking.networkmanager.enable = true; # enables wifi and network
  # sudo nmtui (to connect to wifi)
  # Activate a connection -> select your connection -> password
  
  # disable NetworkManager's internal DNS resolution
  networking.networkmanager.dns = "none";

  # these options are unnecessary when managing DNS ourselves
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  # Configure DNS servers manually (this example uses Cloudflare and Google DNS)
  # IPv6 DNS servers can be used here as well.
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  # audio (PipeWire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true; # pulseaudio
    jack.enable = true;
  };

  # basics
  services.xserver.enable = true;
  services.libinput.enable = true;
  hardware.opengl.enable = true;

  # fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [ "FiraCode" "Iosevka" "VictorMono" ];
    })
    inter
    noto-fonts
    roboto
  ];
}

