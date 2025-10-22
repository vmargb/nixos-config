
# 🗺️ A Bird's-eye view

A modular NixOS, Flakes and Home Manager config designed for reproducibility across multiple machines. This setup is preprepared with Niri, Cosmic and useful dev tools as well some other opinionated choices that I personally use. However, this system is completely [Expandable](#expanding) without adding complexity.

```
nix-config/
├─ flake.nix                      ← Root entry
├─ common/
│  ├─ system-base.nix             ← The rulebook for everyone
│  └─ modules/
│     ├─ default.nix
│     ├─ editors.nix              ← Emacs w/ evil > Neovim
│     ├─ foot.nix                 ← To balance out the Emacs bloat
│     ├─ shells.nix               ← POSIX-compliant... sometimes
│     ├─ cosmic.nix               ← Gnome but better
│     ├─ niri.nix                 ← PaperWM but better
│     ├─ waybar.nix               ← A bar you will never look at
│     ├─ rofi.nix                 ← Telescope.nvim but for your apps
│     ├─ mako.nix                 ← Popups that politely ruin your focus
│     ├─ greetd.nix               ← A no-nonsense TUI greeter
│     └─ dev/                     ← Web-dev, Android & all your esoteric langs
├─ dotfiles/                      ← Raw configs (symlinked by dotfiles.nix)
│  ├─ emacs/
│  ├─ neovim/
│  ├─ fish/config.fish
│  ├─ zsh/.zshrc
│  ├─ starship/starship.toml
│  ├─ niri/config.kdl
└─ hosts/                         ← Per-machine overrides
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

- **Common Configuration**: Shared across all systems:
  - `system-base.nix`: Universal system packages and settings in `common/`
  - `default.nix`: Modular user-level configs (Waybar, Rofi, etc.) in `common/modules/`
  
- **Host-Specific Profiles**: Isolated configurations for each machine type (laptop, desktop, server) with their own:
  - `configuration.nix`: System-level settings and `system-base.nix` overrides
  - `home.nix`: User-level settings and `default.nix` overrides

 both files allow **conditional-logic** to override each option per-host.


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

**Note:** If you don't want to use Nix, add the config to `dotfiles/`, `dotfiles.nix` will automatically handle the symlink for you on the next rebuild.

## Design Philosophy

### 📁 Dotfiles
You'll notice that some dotfiles are configured with Nix dynamically,
while others are static configurations symlinked into `dotfiles/`

These are intentionally split into two parts:
- **Dynamic:** Modules that require runtime changes (Stylix theming, host-specific tweaks)
- **Static:** Modules that are tweaked regularly or have more complex configuration
