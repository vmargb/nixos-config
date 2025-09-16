{ config, pkgs, ... }:

{ # Base system config - things you're never going to change
  time.timeZone = "BST";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;
  networking.networkmanager.enable = true;

  # Audio (PipeWire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Desktop basics
  services.xserver.enable = true;
  services.libinput.enable = true;
  hardware.opengl.enable = true;

  # Fonts
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

  # User account
  users.users.vmargb = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    shell = pkgs.fish; # make fish default shell at login
  };

  # Shared system packages (appendable)
  environment.systemPackages = lib.mkAfter (with pkgs; [
    git
    wget
    curl
    btop
  ]);
}

