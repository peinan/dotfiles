---
title: Submodules
description: Description and setup methods for submodules
---

# Submodules

This repository manages editor and terminal configurations as submodules.

## Overview

::: tip
**What are Submodules?**

Submodules allow you to include another Git repository within a Git repository. This enables managing each configuration as an independent repository while integrating them into the dotfiles repository.

**Initialization:** `git submodule update --init --recursive`
:::

## tmux {#tmux}

Configuration files for the terminal multiplexer tmux

### Repository Information

- **Path:** `src/.config/tmux`
- **Repository:** [https://github.com/peinan/tmux.git](https://github.com/peinan/tmux.git)
- **Branch:** `main`

### Setup Instructions

```bash
# Initialize submodule (if not already done)
git submodule update --init --recursive src/.config/tmux

# Create symbolic link
ln -s ~/.dotfiles/src/.config/tmux ~/.config/tmux

# Or, if existing configuration exists, backup first
mv ~/.config/tmux ~/.config/tmux.backup
ln -s ~/.dotfiles/src/.config/tmux ~/.config/tmux
```

### Update Instructions

```bash
# Update submodule to latest state
cd ~/.dotfiles
git submodule update --remote src/.config/tmux

# Commit changes
git add src/.config/tmux
git commit -m "Update tmux submodule"
```

## Neovim {#nvim}

Neovim editor configuration and plugin management

### Repository Information

- **Path:** `src/.config/nvim`
- **Repository:** [https://github.com/peinan/nvim.git](https://github.com/peinan/nvim.git)
- **Branch:** `main`


### Setup Instructions

```bash
# Initialize submodule (if not already done)
git submodule update --init --recursive src/.config/nvim

# Create symbolic link
ln -s ~/.dotfiles/src/.config/nvim ~/.config/nvim

# Launch Neovim to install plugins
nvim
```

When you first launch Neovim, the plugin manager (Lazy.nvim, etc.) will automatically install plugins.

### Update Instructions

```bash
# Update submodule to latest state
cd ~/.dotfiles
git submodule update --remote src/.config/nvim

# Commit changes
git add src/.config/nvim
git commit -m "Update nvim submodule"
```

## Vim {#vim}

Configuration files for the traditional Vim editor

### Repository Information

- **Path:** `src/.config/vim`
- **Repository:** [https://github.com/peinan/vim.git](https://github.com/peinan/vim.git)
- **Branch:** `main`

### Setup Instructions

```bash
# Initialize submodule (if not already done)
git submodule update --init --recursive src/.config/vim

# Link .vimrc with symbolic link
ln -s ~/.dotfiles/src/.config/vim/.vimrc ~/.vimrc

# Copy color scheme (if needed)
mkdir -p ~/.config/vim/colors
cp ~/.dotfiles/src/.config/vim/Tomorrow-Night-Eighties.vim ~/.config/vim/colors/
```

### Update Instructions

```bash
# Update submodule to latest state
cd ~/.dotfiles
git submodule update --remote src/.config/vim

# Commit changes
git add src/.config/vim
git commit -m "Update vim submodule"
```

## Managing Submodules

### Initialize All Submodules

```bash
git submodule update --init --recursive
```

### Update All Submodules

```bash
# Update all submodules to latest state
git submodule update --remote

# Commit changes
git add src/.config/*
git commit -m "Update all submodules"
```

### Check Submodule Status

```bash
# Check submodule status
git submodule status

# Display detailed information
git submodule foreach git status
```

### Working Inside Submodules

```bash
# Navigate to submodule directory
cd src/.config/nvim

# Normal Git operations are possible
git status
git checkout -b feature-branch
git commit -m "Update config"

# Return to parent repository and commit changes
cd ../..
git add src/.config/nvim
git commit -m "Update nvim submodule"
```

