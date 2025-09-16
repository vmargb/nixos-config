{ config, pkgs, ... }:

{ # Base system config - things you're never going to change
  time.timeZone = "BST";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;
  networking.networkmanager.enable = true;

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
      fonts = [ "FiraCode" "Iosevka" "JetBrainsMono" "GeistMono" ];
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
    shell = pkgs.fish; # make fish default shell at LOGIN
  };

  # shared system packages (appendable)
  environment.systemPackages = lib.mkAfter (with pkgs; [
    git
    wget
    curl
    btop # task manager

    # media controls
    brightnessctl # brightness control
    playerctl
    libnotify # media notifications
  ]);
}

