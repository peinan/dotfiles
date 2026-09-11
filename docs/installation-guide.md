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
curl -fsSL https://dotfiles.peinan.cc/install | bash

# or via GitHub
curl -fsSL https://raw.githubusercontent.com/peinan/dotfiles/HEAD/scripts/install.sh | bash
```

The script will:
1. Install Homebrew (if not installed)
2. Install essential tools (git, ghq, stow)
3. Clone the repository using ghq
4. Clone the nvim/tmux config repositories and link them into `~/.config`
5. Clone the private machine-local repository and link `~/.zsh/local` and
   `~/.alias.local`, warning and continuing if it is unavailable
6. Install all packages from Brewfile
7. Set up the Node environment with mise and remove Homebrew's Node
8. Install Claude Code with its native installer
9. Create symbolic links using stow

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
git clone https://github.com/peinan/dotfiles.git
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

### Step 4: Link Machine-Local Overrides

Values that cannot live in this public repository come from a separate private
one. Skip this step if you do not have access to it — everything else works
without it.

```bash
ghq get peinan/dotfiles-local

# Must exist as a real directory before Step 5, or stow folds the whole tree
# into ~/.zsh -> src/.zsh and these links land inside the repository.
mkdir -p ~/.zsh

L="$(ghq root)/github.com/peinan/dotfiles-local"
ln -sfn "$L/zsh-local"   ~/.zsh/local
ln -sfn "$L/alias.local" ~/.alias.local
```

See [Config Repositories](/config-repos) for what belongs there.

### Step 5: Create Symbolic Links

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

### Step 6: Restart Shell

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

### `~/.config/nvim` is a real directory

`~/.config/nvim` and `~/.config/tmux` must be symlinks into the ghq clones.
A machine migration that copied `~/.config` verbatim leaves them as real
directories, and the config you edit in the repository then has no effect.

Check what is actually loaded, then relink:

```bash
git -C ~/.config/nvim rev-parse --show-toplevel   # should print the ghq path

mv ~/.config/nvim ~/.config/nvim.backup
ln -s "$(ghq root)/github.com/peinan/nvim" ~/.config/nvim
```

Push anything you have only in the old directory before deleting the backup.
See the [Config Repos page](/config-repos).

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
