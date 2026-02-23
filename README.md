# A Bird's-eye view

My modular NixOS, Flakes & Home Manager config with multiple hosts. This setup uses Niri, Sway, Waybar, Fuzzel as well as other opinionated choices that I personally use. It is easily [Expandable](#expanding).

```
nix-config/
├─ flake.nix                      ← Root entry
├─ common/
│  ├─ system/
│  │  └─ base.nix                 ← config for every host
│  └─ home/
│     ├─ default.nix
│     ├─ editors.nix              ← Emacs w/ evil > Neovim
│     ├─ foot.nix                 ← To balance out the Emacs bloat
│     ├─ shells.nix
│     ├─ niri.nix
│     ├─ waybar.nix
│     ├─ fuzzel.nix
│     ├─ mako.nix
│     ├─ greetd.nix
│     └─ dev/                     ← Web-dev, Android & all your esoteric langs
├─ dotfiles/                      ← (symlinked by dotfiles.nix)
│  ├─ emacs/
│  ├─ nvim/
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
Remember to add your own `hardware-configuration.nix` and
adjust `hostname` to match one of the hosts(or create your own)

### Update Dependencies
```bash
nix flake update
```

## Expanding

### Adding a New Host
1. Create a directory under `hosts/` with `configuration.nix`, `home.nix` and your generated `hardware-configuration.nix`
2. Import necessary common modules in both configuration files
3. Add the host to `flake.nix` with: `{host} = mkHost { name = "{host}"; system = "{system}"; }`

### Creating New Modules
1. Add Nix module in `common/home/` and import it into your `home.nix`

**Note:** If you don't want to use Nix, add the config to `dotfiles/`, `dotfiles.nix` will automatically handle the symlink for you on the next rebuild.

## 📁 Dotfiles
You'll notice that some dotfiles are configured with Nix in `common/home/`,
while others live in `dotfiles/`

These are intentionally split apart:
- **Nix:** Modules that have simple configs(like toml) or require runtime changes (like stylix)
- **Native:** Modules that are tweaked regularly or have more complex configuration
