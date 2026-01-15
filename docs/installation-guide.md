---
title: Installation Guide
description: Installation and setup instructions for dotfiles
---

# Installation Guide

::: warning
This dotfiles is designed for **macOS only**.
:::

## One-liner Install (Recommended)

The easiest way to install is using the install script:

```bash
curl -fsSL https://dotfiles.peinan.cc/install.sh | bash

# or via GitHub
curl -fsSL https://raw.githubusercontent.com/peinan/dotfiles/HEAD/scripts/install.sh | bash
```

The script will:
1. Install Homebrew (if not installed)
2. Install essential tools (git, ghq, stow)
3. Clone the repository using ghq
4. Initialize submodules
5. Install all packages from Brewfile
6. Create symbolic links using stow

## Manual Installation

If you prefer to install manually, follow these steps:

### Step 1: Install Homebrew and Stow

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install stow
brew install stow
```

### Step 2: Clone Repository

```bash
# Clone with submodules
git clone --recursive https://github.com/peinan/dotfiles.git
cd dotfiles
```

::: tip
You can clone to any location. The install script uses `ghq` and clones to `~/ghq/github.com/peinan/dotfiles`.
:::

### Step 3: Install Packages

```bash
# Install all packages from Brewfile
brew bundle install
```

::: info
This installs many packages and may take some time. Edit the Brewfile to install only specific packages.
:::

### Step 4: Create Symbolic Links

```bash
# Create all symlinks using stow
stow -v -t ~ src
```

::: warning
If existing configuration files exist, stow will fail. Backup and remove them first:

```bash
# Example: backup existing .zshrc
mv ~/.zshrc ~/.zshrc.backup
```
:::

### Step 5: Restart Shell

```bash
# Reload shell configuration
source ~/.zshrc

# Or open a new terminal window
```

## Verification

Verify that the configuration is loaded correctly:

```bash
# Check symlinks
ls -la ~ | grep "dotfiles/src"

# Check if Starship prompt is working
starship --version

# Check if Neovim starts
nvim --version
```

## Troubleshooting

### Stow fails with "existing target" error

Stow won't overwrite existing files. Backup and remove them:

```bash
mv ~/.zshrc ~/.zshrc.backup
mv ~/.gitconfig ~/.gitconfig.backup
stow -v -t ~ src
```

### Submodules are empty

Initialize submodules:

```bash
git submodule update --init --recursive
```

### Package installation fails

Update Homebrew and try again:

```bash
brew update
brew bundle install
```

### Neovim plugins not installed

Launch Neovim and plugins will be installed automatically:

```bash
nvim
```
