# Structure

Dendritic NixOS, Flakes & Home Manager config with multiple hosts. This setup uses Niri & DMS as well as other opinionated choices that I personally use, and is easily expandable.

```sh
.
├── flake.nix
├── hosts
│   ├── desktop
│   │   └── default.nix
│   └── laptop
│       └── default.nix
├── modules
│   ├── emacs/
│   ├── nvim/
│   ├── core.nix
│   ├── default.nix
│   ├── desktop.nix
│   ├── dev.nix
│   ├── emacs.nix
│   ├── neovim.nix
│   ├── shell.nix
│   ├── theme.nix
│   └── vcs.nix
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
Remember to add your own `hardware-configuration.nix` and
adjust `hostname` to match one of the hosts(or create your own)

### Update Dependencies
```bash
nix flake update
```

## 📁 Dotfiles
You'll notice that some dotfiles are configured with Nix
while others are symlinked to `~/.config/`

These are intentionally split apart:
- **Nix:** Modules that have simple configs(like toml) or require runtime changes (like stylix)
- **Native:** Modules that are tweaked regularly or have more complex configuration
