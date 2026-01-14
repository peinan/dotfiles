#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
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

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    error "This script is only supported on macOS"
fi

echo ""
echo "=================================="
echo "   Peinan's dotfile installer"
echo "=================================="
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

# Step 4: Initialize submodules
info "Initializing submodules..."
cd "$DOTFILES_DIR"
git submodule update --init --recursive
success "Submodules initialized"

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

# Step 6: Create symbolic links using stow
info "Creating symbolic links..."

# Backup existing files if they exist (not symlinks)
backup_if_exists() {
    local file="$1"
    if [[ -f "$file" && ! -L "$file" ]]; then
        warn "Backing up existing $file to ${file}.backup"
        mv "$file" "${file}.backup"
    fi
}

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
