---
title: peinan's dotfiles
description: Configuration files for OS, shell, Neovim, tmux and others
---

# peinan's dotfiles

A collection of configuration files and scripts for OS, shell, Neovim, tmux, and more

## Quick Start

```bash
# Clone the repository
git clone https://github.com/peinan/dotfiles.git ~/.dotfiles

# Navigate to the directory
cd ~/.dotfiles

# Initialize submodules
git submodule update --init --recursive

# Create symbolic links (as needed)
# Example: .zshrc
ln -s ~/.dotfiles/src/.zshrc ~/.zshrc
```

For detailed installation instructions, see the [installation page](/install).

## Repository Structure

This repository contains a collection of configuration files for efficiently setting up a development environment. The main configurations include:

- **Shell Configuration**: .zshrc, .zshenv, .alias, and more
- **Git Configuration**: .gitconfig with beautiful diff display using delta
- **Editor Configuration**: Neovim and Vim settings (submodules)
- **Terminal Configuration**: tmux settings (submodule)
- **Prompt**: Starship configuration
- **Package Management**: Homebrew Brewfile

