#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Backup an existing file or directory (symlinks are left alone)
backup_if_exists() {
    local path="$1"
    if [[ -e "$path" && ! -L "$path" ]]; then
        local backup="${path}.backup"
        # `mv dir existing.backup` nests the directory inside the old backup
        # instead of replacing it, so pick a fresh name when it is taken.
        if [[ -e "$backup" ]]; then
            backup="${path}.backup.$(date +%Y%m%d%H%M%S)"
        fi
        warn "Backing up existing $path to $backup"
        mv "$path" "$backup"
    fi
}

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    error "This script is only supported on macOS"
fi

# Logo generated with `cfonts "dotfiles" -f block`, inlined because cfonts is
# not available before the Brewfile is installed.
echo ""
echo -e "${BLUE} ██████╗   ██████╗  ████████╗ ███████╗ ██╗ ██╗      ███████╗ ███████╗"
echo -e " ██╔══██╗ ██╔═══██╗ ╚══██╔══╝ ██╔════╝ ██║ ██║      ██╔════╝ ██╔════╝"
echo -e " ██║  ██║ ██║   ██║    ██║    █████╗   ██║ ██║      █████╗   ███████╗"
echo -e " ██║  ██║ ██║   ██║    ██║    ██╔══╝   ██║ ██║      ██╔══╝   ╚════██║"
echo -e " ██████╔╝ ╚██████╔╝    ██║    ██║      ██║ ███████╗ ███████╗ ███████║"
echo -e " ╚═════╝   ╚═════╝     ╚═╝    ╚═╝      ╚═╝ ╚══════╝ ╚══════╝ ╚══════╝${NC}"
echo -e "${GRAY}                peinan's macOS development environment${NC}"
echo ""

# Step 0: Take the sudo timestamp once, up front.
#
# Four things here need root: Homebrew's own installer (creating and chowning
# /opt/homebrew, installing the Command Line Tools), the google-drive and
# karabiner-elements casks, whose .pkg installers run as root, and
# docker-desktop, whose `binary` artifacts symlink into the root-owned
# /usr/local/bin and /usr/local/cli-plugins.
#
# Left alone that is several password prompts rather than one, for two reasons
# that reordering the Brewfile cannot fix: Homebrew's installer invalidates the
# sudo timestamp on exit, and the Brewfile download phase runs far longer than
# sudo's five-minute default. `brew bundle install` also batches every cask
# into a single `brew install`, which downloads everything before installing
# anything, so the three are already consecutive.
#
# Acquiring the timestamp before Step 1 also stops Homebrew from invalidating
# it: its installer only arms `trap 'sudo -k' EXIT` when `sudo -n -v` fails,
# i.e. when the timestamp was not already valid on entry.
info "Administrator access is required for this install:"
echo "    - Homebrew itself (/opt/homebrew and the Command Line Tools)"
echo "    - the google-drive and karabiner-elements casks (.pkg installers)"
echo "    - docker-desktop (symlinks into the root-owned /usr/local/bin)"
sudo -v || error "This install needs sudo access; $USER must be an administrator"

# Keep the timestamp warm for the rest of the run. `|| true` because this
# subshell inherits `set -e` and a refresh that loses the race must not kill
# the loop; `kill -0 "$$"` so the loop cannot outlive the script if it is
# killed without the trap running.
while true; do
    sudo -n true 2>/dev/null || true
    sleep 50
    kill -0 "$$" 2>/dev/null || exit
done &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null; sudo -k' EXIT

warn "Karabiner-Elements, Docker Desktop and Google Drive will ask for your"
warn "password again in a GUI dialog when they first launch. Those prompts come"
warn "from macOS itself and cannot be pre-authorised from here."
echo ""

# Step 1: Install Homebrew if not exists
info "Checking Homebrew..."
if ! command -v brew &> /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    success "Homebrew installed"
else
    success "Homebrew is already installed"
fi

# Step 2: Install essential tools (git, ghq, stow)
info "Installing essential tools (git, ghq, stow)..."
brew install git ghq stow 2>/dev/null || true
success "Essential tools installed"

# Step 3: Clone dotfiles repository using ghq
DOTFILES_DIR="$(ghq root)/github.com/peinan/dotfiles"

info "Cloning dotfiles repository..."
if [[ -d "$DOTFILES_DIR" ]]; then
    warn "dotfiles already exists at $DOTFILES_DIR"
    info "Pulling latest changes..."
    cd "$DOTFILES_DIR"
    git pull origin main
else
    ghq get peinan/dotfiles
fi
success "dotfiles repository ready"

# Step 4: Set up the nvim and tmux configs from their own repositories
# They are standalone repositories, not submodules: the ghq clone is the only
# working copy and ~/.config/<name> is just a symlink pointing at it.
GHQ_ROOT="$(ghq root)"

# ~/.config has to be a real directory before the symlinks below are created.
# On a fresh machine it does not exist yet, and stow (Step 6) would then fold
# the whole tree into `~/.config -> src/.config`, which would put these
# symlinks inside the dotfiles repository instead of $HOME.
mkdir -p "$HOME/.config"

setup_config_repo() {
    local repo="$1"           # e.g. peinan/nvim
    local name="${repo##*/}"
    local repo_dir="$GHQ_ROOT/github.com/$repo"
    local link="$HOME/.config/$name"

    info "Setting up $name config..."
    if [[ -d "$repo_dir" ]]; then
        warn "$name already exists at $repo_dir"
    else
        ghq get "$repo"
    fi

    # peinan/tmux still carries its plugins as nested submodules. `ghq get`
    # recurses by default, but doing it explicitly documents the requirement
    # and repairs a partially initialized clone on re-runs.
    if [[ -f "$repo_dir/.gitmodules" ]]; then
        git -C "$repo_dir" submodule update --init --recursive
    fi

    if [[ -e "$link" && ! -L "$link" ]]; then
        warn "$link is a real directory, not a symlink; it may hold uncommitted work"
    fi
    backup_if_exists "$link"
    ln -sfn "$repo_dir" "$link"

    success "$name config ready: $link -> $repo_dir"
}

setup_config_repo peinan/nvim
setup_config_repo peinan/tmux

# Step 5a: Install all packages from Brewfile
info "Installing packages from Brewfile..."
brew bundle install --file "$DOTFILES_DIR/Brewfile"
success "Packages installed"

# Step 5b: Setup node env
info "Setting up node environment with mise..."

# Install mise packages
mise install

# Uninstall homebrew's node
if brew list node &>/dev/null; then
    info "Uninstalling brew's node..."
    brew uninstall node --ignore-dependencies
fi

# Create symbolic link
if [[ "$(uname -m)" == "arm64" ]]; then
    BREW_CELLAR="/opt/homebrew/Cellar"
else
    BREW_CELLAR="/usr/local/Cellar"
fi

MISE_NODE_PATH="$(mise where node)"

info "Creating symbolic link for Homebrew compatibility..."
mkdir -p "$BREW_CELLAR/node"
ln -sfn "$MISE_NODE_PATH" "$BREW_CELLAR/node"

# Remove existing opt link/directory before brew link
if [[ "$(uname -m)" == "arm64" ]]; then
    rm -rf /opt/homebrew/opt/node
else
    rm -rf /usr/local/opt/node
fi

# Link to homebrew's node to enable brew packages that require brew's node work
brew link --overwrite node

# Not let homebrew upgrade node
brew pin node

success "Node environment setup complete (managed by mise)"

# Step 5c: Install Claude Code with the native installer
# Not from Homebrew: the native build auto-updates in the background, while a
# cask stays pinned until `brew upgrade` runs.
info "Installing Claude Code..."
if [[ -x "$HOME/.local/bin/claude" ]]; then
    success "Claude Code is already installed"
else
    curl -fsSL https://claude.ai/install.sh | bash
    success "Claude Code installed"
fi

# Step 6: Create symbolic links using stow
info "Creating symbolic links..."

# Check for common files that might conflict
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.zshenv"
backup_if_exists "$HOME/.zprofile"
backup_if_exists "$HOME/.alias"
backup_if_exists "$HOME/.gitconfig"

# Run stow
cd "$DOTFILES_DIR"
stow -v -t "$HOME" src
success "Symbolic links created"

echo ""
echo "=================================="
echo -e "${GREEN}  Installation complete!${NC}"
echo "=================================="
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo '  2. Run `nvim` and install plugins'
echo ""
echo "Documentation: https://peinan.github.io/dotfiles/"
echo ""
