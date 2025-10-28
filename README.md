
# 🗺️ A Bird's-eye view

My modular NixOS, Flakes & Home Manager config designed for multiple hosts. This setup is preprepared with Niri, Waybar, Rofi including other opinionated choices that I personally use. It is also [Expandable](#expanding) without adding complexity.

```
nix-config/
├─ flake.nix                      ← Root entry
├─ common/
│  ├─ system/
│  │  └─ base.nix                 ← rulebook for every host
│  └─ home/
│     ├─ default.nix
│     ├─ editors.nix              ← Emacs w/ evil > Neovim
│     ├─ foot.nix                 ← To balance out the Emacs bloat
│     ├─ shells.nix               ← POSIX-compliant... sometimes
│     ├─ niri.nix                 ← PaperWM but better
│     ├─ waybar.nix               ← A bar you will never look at
│     ├─ rofi.nix                 ← Telescope.nvim but for your apps
│     ├─ mako.nix                 ← Popups that politely ruin your focus
│     ├─ greetd.nix               ← A no-nonsense TUI greeter
│     └─ dev/                     ← Web-dev, Android & all your esoteric langs
├─ dotfiles/                      ← (symlinked by dotfiles.nix)
│  ├─ emacs/
│  ├─ neovim/
│  ├─ niri/
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

### Update Dependencies
```bash
nix flake update
```

## Architecture

- **Common Configuration**: Shared across all systems:
  - `base.nix`: Universal system packages and settings in `common/system/`
  - `default.nix`: Modular user-level configs (Waybar, Rofi, etc.) in `common/home/`
  
- **Host-Specific Profiles**: Isolated configurations for each machine (laptop, desktop, server) with their own:
  - `configuration.nix`: `system/base.nix` overrides and extra system settings
  - `home.nix`: `home/default.nix` overrides and extra home settings

## Expanding

### Adding a New Host
1. Create a directory under `hosts/` with `configuration.nix` and `home.nix`
2. Import necessary common modules in the configuration files
3. Add the host to `flake.nix` with: `{host} = mkHost "{host}" "x86_64-linux";`

### Creating New Modules
1. Add Nix module in `common/home/`
2. Either import it in `common/home/default.nix` or directly into `home.nix`

**Note:** If you don't want to use Nix, add the config to `dotfiles/`, `dotfiles.nix` will automatically handle the symlink for you on the next rebuild.

## 📁 Dotfiles
You'll notice that some dotfiles are configured with Nix in `common/home/`,
while others live in `dotfiles/` using native configuration (e.g., Lua, Elisp)

These are intentionally split into two parts:
- **Nix:** Modules that have simple configs(like toml) or require runtime changes (Stylix theming)
- **Native:** Modules that are tweaked regularly or have more complex configuration
