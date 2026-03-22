# macOS Dotfiles

Tiling WM setup for macOS with a custom status bar, Gruvbox theming, and notification badges.

![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)

## What's Included

- **SketchyBar** — custom top bar with floating pill-style items, workspace indicators, app icons, battery, CPU/memory stats, and notification badges (Slack, Discord, Messages, Mail, Teams, etc.)
- **AeroSpace** — tiling window manager with Hyprland-style keybindings and per-monitor workspaces
- **Alacritty** — GPU-accelerated terminal
- **Zed** — editor settings
- **Zsh** — vi mode, eza aliases, zsh-autosuggestions, zsh-syntax-highlighting, Powerlevel10k prompt
- **Starship** — secondary prompt config

## Dependencies

Install everything with Homebrew:

```bash
brew bundle --file=Brewfile
```

## Installation

```bash
# Clone the bare repo
git clone --bare git@github.com:Swofty-Developments/macos-dotfiles.git $HOME/.dotfiles

# Checkout files into $HOME
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout

# Hide untracked files
git --git-dir=$HOME/.dotfiles --work-tree=$HOME config status.showUntrackedFiles no

# Add the alias to your shell
echo "alias dotfiles='git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME'" >> ~/.zshrc
```

If checkout fails due to existing files, back them up first:

```bash
mkdir -p ~/.dotfiles-backup
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout 2>&1 \
  | grep -E "^\s+" | awk '{print $1}' \
  | xargs -I{} mv {} ~/.dotfiles-backup/{}
```

Then run checkout again.

## Managing Dotfiles

```bash
dotfiles add ~/.config/sketchybar/sketchybarrc
dotfiles commit -m "update sketchybar config"
dotfiles push
```
