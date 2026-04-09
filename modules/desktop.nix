{ config, pkgs, inputs, ... }:

{
  # Hardware graphics (OpenGL) for Wayland to run smoothly
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # touchpad support 
  services.libinput.enable = true;

  programs.niri.enable = true;

  security.polkit.enable = true; # Polkit needed for Wayland compositors
  
  # XDG Desktop Portals for screen sharing, file pickers, etc
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    configPackages = [ pkgs.niri ];
  };

  # Keyring and SSH Agent (needed for GitHub, SSH keys, secrets)
  services.gnome.gnome-keyring.enable = true;
  programs.ssh.startAgent = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Enable pipewire for audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Fonts
  fonts.packages = with pkgs; [
    iosevka
    (nerdfonts.override { fonts = [ "Iosevka" ]; })
  ];

  # Home Manager Wayland/Niri specific setups
  home-manager.users.vmargb = { pkgs, ... }: {
    # Configure some default Wayland tools
    home.packages = with pkgs; [
      alacritty    # Terminal emulator
      wl-clipboard # Wayland clipboard tools
      xwayland-satellite # X11 compatibility layer
      imv          # image viewer
      dms-shell    # Dank Material Shell
      qutebrowser  # vim browser
      nemo-with-extensions # file explorer
    ];

    # configured for optimal hardware decoding
    programs.mpv = {
      enable = true;
      config = {
        hwdec = "auto";
        vo = "gpu";
        profile = "gpu-hq";
      };
      bindings = {
        WHEEL_UP = "seek 10";
        WHEEL_DOWN = "seek -10";
      };
    };
  };
}
