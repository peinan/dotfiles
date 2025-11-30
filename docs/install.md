---
title: Installation Guide
description: Installation and setup instructions for dotfiles
---

# Installation Guide

## Prerequisites

::: tip
The following tools must be installed:

- **Git**: Required for cloning the repository
- **Homebrew** (macOS): Used for package management
- **Zsh**: Required if using shell configuration
:::

## Step 1: Clone Repository

Clone the repository to `.dotfiles` in your home directory.

```bash
# Clone the repository
git clone https://github.com/peinan/dotfiles.git ~/.dotfiles

# Navigate to the directory
cd ~/.dotfiles
```

## Step 2: Initialize Submodules

This repository uses the following submodules. All must be initialized:

- `src/.config/tmux` - tmux configuration
- `src/.config/nvim` - Neovim configuration
- `src/.config/vim` - Vim configuration

```bash
# Initialize all submodules
git submodule update --init --recursive
```

You can also initialize each submodule individually by navigating to each submodule directory.

## Step 3: Install Homebrew Packages

Install required packages in bulk using the Brewfile.

```bash
# Install packages from Brewfile
brew bundle install --file ~/.dotfiles/src/Brewfile
```

::: info
**Note:** This command installs many packages and may take some time. To install only specific packages, edit the Brewfile.
:::

## Step 4: Setup Shell Configuration

Link Zsh configuration files with symbolic links.

```bash
# Link .zshrc
ln -s ~/.dotfiles/src/.zshrc ~/.zshrc

# Link .zshenv
ln -s ~/.dotfiles/src/.zshenv ~/.zshenv

# Link .alias
ln -s ~/.dotfiles/src/.alias ~/.alias
```

::: warning
**If existing configuration files exist:** Please backup existing files before creating links.
:::

## Step 5: Setup Git Configuration

Link the Git configuration file.

```bash
# Link .gitconfig
ln -s ~/.dotfiles/src/.gitconfig ~/.gitconfig
```

**Note:** Please edit `.gitconfig` to change the username and email address as needed.

## Step 6: Setup Editor Configurations

Neovim and Vim configurations are managed as submodules. Link the configuration directories.

```bash
# Link Neovim configuration
ln -s ~/.dotfiles/src/.config/nvim ~/.config/nvim

# Link Vim configuration (if using)
ln -s ~/.dotfiles/src/.config/vim ~/.config/vim
```

## Step 7: Setup Other Configurations

Link other configuration files as needed.

```bash
# Link Starship configuration
mkdir -p ~/.config/starship
ln -s ~/.dotfiles/src/.config/starship/starship.toml ~/.config/starship/starship.toml

# Link Sheldon configuration
mkdir -p ~/.config/sheldon
ln -s ~/.dotfiles/src/.config/sheldon/plugins.toml ~/.config/sheldon/plugins.toml

# Link tmux configuration
ln -s ~/.dotfiles/src/.config/tmux ~/.config/tmux
```

## Step 8: Restart Shell

Start a new shell session to apply the configuration.

```bash
# Reload current shell
source ~/.zshrc

# Or open a new terminal window
```

## Verification

Verify that the configuration is loaded correctly with the following commands:

```bash
# Check if Starship prompt is displayed
starship --version

# Check if Sheldon plugins are loaded
sheldon lock

# Check if Neovim starts
nvim --version
```

## Troubleshooting

### Common Issues

#### Submodule is empty

The submodule may not be initialized correctly. Run the following:

```bash
git submodule update --init --recursive
```

#### Cannot create symbolic link

If an existing file exists, backup and remove it first:

```bash
# Example: for .zshrc
mv ~/.zshrc ~/.zshrc.backup
ln -s ~/.dotfiles/src/.zshrc ~/.zshrc
```

#### Package installation fails

Homebrew may not be up to date. Run `brew update` and try again.

