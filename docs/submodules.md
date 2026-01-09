---
title: Submodules
description: Description and setup methods for submodules
---

# Submodules

This repository manages editor and terminal configurations as Git submodules.

## Overview

::: tip
**What are Submodules?**

Submodules allow you to include another Git repository within a Git repository. This enables managing each configuration as an independent repository while integrating them into the dotfiles repository.
:::

When you run `stow -v -t ~ src`, submodule directories are linked as **directory symlinks**:

```text
~/.config/nvim -> dotfiles/src/.config/nvim
~/.config/tmux -> dotfiles/src/.config/tmux
~/.config/vim  -> dotfiles/src/.config/vim
```

## Included Submodules

| Submodule | Path | Repository |
|-----------|------|------------|
| Neovim | `src/.config/nvim` | [peinan/nvim](https://github.com/peinan/nvim) |
| tmux | `src/.config/tmux` | [peinan/tmux](https://github.com/peinan/tmux) |
| Vim | `src/.config/vim` | [peinan/vim](https://github.com/peinan/vim) |

## Initialize Submodules

If you cloned without `--recursive`, initialize submodules manually:

```bash
git submodule update --init --recursive
```

## Update Submodules

### Update all submodules

```bash
# Fetch and update all submodules to latest
git submodule update --remote

# Commit the changes
git add src/.config/*
git commit -m "Update submodules"
```

### Update a specific submodule

```bash
# Example: update nvim only
git submodule update --remote src/.config/nvim

git add src/.config/nvim
git commit -m "Update nvim submodule"
```

## Working Inside Submodules

You can work inside submodules like normal Git repositories:

```bash
# Navigate to submodule
cd src/.config/nvim

# Make changes and commit
git checkout -b feature-branch
# ... edit files ...
git commit -m "Add new feature"
git push origin feature-branch

# Return to parent repository
cd ../../..

# Update submodule reference
git add src/.config/nvim
git commit -m "Update nvim submodule"
```

## Check Submodule Status

```bash
# Show submodule status
git submodule status

# Show detailed status for each submodule
git submodule foreach git status
```

## Troubleshooting

### Submodule directory is empty

```bash
git submodule update --init --recursive
```

### Stow fails because target directory exists

If `~/.config/nvim` already exists (not as a symlink), remove or backup it first:

```bash
mv ~/.config/nvim ~/.config/nvim.backup
stow -v -t ~ src
```

### Submodule is in detached HEAD state

This is normal. Submodules track specific commits, not branches. To update:

```bash
git submodule update --remote
```
