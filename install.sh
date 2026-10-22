#!/bin/bash
# Sets up the editor environment on a Mac. Safe to run again.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

# link <path in repo> <target>: symlink, moving any existing file aside first
link() {
  local src="$DIR/$1" dst="$2"
  [ "$(readlink "$dst" 2>/dev/null)" = "$src" ] && return 0
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.backup-$(date +%Y%m%d-%H%M%S)"
    echo "backed up $dst"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "linked $dst"
}

# Homebrew and the Brewfile
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
brew bundle --file "$DIR/Brewfile"
[ "${1:-}" = "--infra" ] && brew bundle --file "$DIR/Brewfile.infra"

# Claude Code, with the native installer (it updates itself)
if ! command -v claude >/dev/null && [ ! -x "$HOME/.local/bin/claude" ]; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# oh-my-zsh, keeping our .zshrc
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# tmux: tpm for plugins, catppuccin cloned at a fixed release
[ -d "$HOME/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
CATPPUCCIN="$HOME/.config/tmux/plugins/catppuccin/tmux"
[ -d "$CATPPUCCIN" ] || git clone -b v2.3.2 https://github.com/catppuccin/tmux.git "$CATPPUCCIN"

link zsh/.zshrc "$HOME/.zshrc"
link zsh/.zprofile "$HOME/.zprofile"
link zsh/robbyrussell-aws.zsh-theme "$HOME/.oh-my-zsh/custom/themes/robbyrussell-aws.zsh-theme"
link tmux/.tmux.conf "$HOME/.tmux.conf"
link nvim "$HOME/.config/nvim"
link iterm/dev-env.json "$HOME/Library/Application Support/iTerm2/DynamicProfiles/dev-env.json"

"$HOME/.tmux/plugins/tpm/bin/install_plugins"

# Claude settings are copied, not linked: Claude Code writes to this file itself
if [ -e "$HOME/.claude/settings.json" ]; then
  echo "kept existing ~/.claude/settings.json (compare with claude/settings.json)"
else
  mkdir -p "$HOME/.claude"
  cp "$DIR/claude/settings.json" "$HOME/.claude/settings.json"
  echo "copied ~/.claude/settings.json"
fi

echo "Done. In iTerm2, set the dev-env profile as default (Settings > Profiles)."
echo "Start nvim once to install plugins, then run :MasonInstall terraform-ls tflint."
