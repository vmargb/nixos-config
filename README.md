
# 🗺️ A Bird's-eye view

A modular NixOS, Flakes and Home Manager config designed for reproducibility across multiple machines. This setup is preprepared with Niri, Cosmic and useful dev tools as well some other opinionated choices that I personally use. However, this system is completely [Expandable](#expanding) without adding complexity.

```
nix-config/
├─ flake.nix                     ← The conductor, orchestrates everything
├─ common/
│  ├─ system-base.nix             ← The rulebook everyone has to follow
│  └─ modules/
│     ├─ default.nix              ← The rulebook you can choose to follow
│     ├─ emacs.nix                ← Spacemacs? Doom? Vanilla? Your choice
│     ├─ foot.nix                 ← Foo + term => foot, (not feet)
│     ├─ shells.nix               ← Bash, zsh, fish? one-stop to have them all
│     ├─ cosmic.nix               ← Gnome but better
│     ├─ niri.nix                 ← PaperWM but better
│     ├─ waybar.nix               ← A status bar you will never look at
│     ├─ rofi.nix                 ← Telescope.nvim but for your apps
│     ├─ mako.nix                 ← Popups that politely ruin your concentration
│     ├─ greetd.nix               ← A no-nonsense TUI greeter
│     └─ dev/                     ← Web-dev, Android, 
├─ dotfiles/                      ← Raw configs (symlinked by dotfiles.nix)
│  ├─ emacs/config.org
│  ├─ fish/config.fish
│  ├─ zsh/.zshrc
│  ├─ starship/starship.toml
│  ├─ niri/config.kdl
└─ hosts/                         ← Per-machine personalities
   ├─ laptop/
   │  ├─ configuration.nix        ← System-level config
   │  └─ home.nix                 ← User-level config
   ├─ desktop/
   │  ├─ configuration.nix
   │  └─ home.nix
   └─ server/
      ├─ configuration.nix
      └─ home.nix
```

## 🛠️ Installation

For complete, step-by-step NixOS installation (partitioning, formatting, disk encryption etc), see my guide on Notion: [NixOS installation guide](https://www.notion.so/Installation-part-1-2401ea842a24801397f9f70795379bc2?source=copy_link)

```bash
git clone https://github.com/vmargb/nixos-config.git
cd nixos-config
sudo nixos-rebuild switch --flake .#hostname
```
or
```bash
sudo nixos-rebuild switch --flake github:vmargb/nixos-config#hostname
```

Remember to adjust `hostname` to match one of the hosts(or create your own)


## Architecture

### Core Components
- **Flake Foundation**: The `flake.nix` serves as the entry point, coordinating between NixOS system configurations and Home Manager user environments.

- **Common Configuration**: Shared across all systems:
  - `system-base.nix`: Universal system packages and settings in `common/`
  - `default.nix`: Modular user-level configs (Waybar, Rofi, etc.) in `common/modules/`
  
  Uses **conditional-logic** to override each option per-host.

- **Host-Specific Profiles**: Isolated configurations for each machine type (laptop, desktop, server) with their own:
  - `configuration.nix`: System-level settings and `system-base.nix` overrides
  - `home.nix`: User-level settings and `default.nix` overrides

- **Dotfile Management**: Static configuration files are stored in `dotfiles/` and symlinked in `default.nix`.

## Usage

### Building for a Specific Host
```bash
# Build and switch to the laptop configuration
nixos-rebuild switch --flake ~/nixos-config#laptop

# Or build for desktop
nixos-rebuild switch --flake ~/nixos-config#desktop
```

### Update Dependencies
```bash
nix flake update
```

## Expanding

### Adding a New Host
1. Create a directory under `hosts/` with `configuration.nix` and `home.nix`
2. Import necessary common modules in the configuration files
3. Add the host to `flake.nix` with: `{host} = mkHost "{host}" "x86_64-linux";`

### Creating New Modules
1. Add Nix module in `common/modules/`
2. Either import it in `common/modules/default.nix` or directly into `home.nix`

**Note:** If it's a static module, add the config to `dotfiles/`, `dotfiles.nix` will automatically handle the symlink for you.

## Design Philosophy

### 📁 Dotfiles
You'll notice that some dotfiles are configured with Nix dynamically,
while others are static configurations symlinked into `dotfiles/`

These are intentionally split into two parts:
- **Dynamic:** Modules that require runtime changes (Stylix theming, host-specific tweaks)
- **Static:** Modules that work everywhere (editor configs, scripts, vanilla settings)
