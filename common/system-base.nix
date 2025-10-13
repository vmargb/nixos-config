{ config, pkgs, ... }:  # Base system config - things you're never going to change

{
  # shared system packages
  environment.systemPackages = with pkgs; [
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

  time.timeZone = "BST";
  i18n.defaultLocale = "en_US.UTF-8";

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
      fonts = [ "FiraCode" "Iosevka" "Lilex" "GeistMono" ];
    })
    inter
    noto-fonts
    roboto
  ];

  # Stylix theming
  stylix = {
    enable = true;
    image = "/home/vmargb/.wallpapers/gruvbox.png";
    #base16Scheme = "gruvbox-dark"; # (set theme manually)
    fonts = {
      serif = "Noto Serif";
      sansSerif = "Noto Sans";
      monospace = "Iosevka";
    };
  };

  # user account
  users.users.vmargb = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    shell = pkgs.bash; # make bash default shell at LOGIN
  };
}

