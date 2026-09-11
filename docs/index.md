---
title: peinan's dotfiles
description: Configuration files for OS, shell, Neovim, tmux and others
---

# peinan's dotfiles

A collection of configuration files for setting up a development environment on macOS.

## Quick Start

::: warning
This dotfiles is designed for **macOS only**.
:::

```bash
# One-liner install (recommended)
curl -fsSL https://dotfiles.peinan.cc/install | bash

# or via GitHub
curl -fsSL https://raw.githubusercontent.com/peinan/dotfiles/HEAD/scripts/install.sh | bash
```

For manual installation, see the [installation page](/installation-guide).

## What's Included

- **Shell**: [Zsh](https://www.zsh.org/) (`.zshrc`, `.zshenv`, `.alias`)
    - **Prompt**: [Starship](https://starship.rs/)
    - **Plugin Manager**: [Sheldon](https://sheldon.cli.rs/)
- **Git**: Git configuration (`.gitconfig`) and [delta](https://dandavison.github.io/delta/) for beautiful diffs
- **Editors**: [Neovim](https://neovim.io/) (standalone repository)
- **Terminal**: [Ghostty](https://ghostty.org/)
- **Multiplexing**: [tmux](https://github.com/tmux/tmux) (standalone repository)
- **Package Management**: [Homebrew](https://brew.sh/) (`Brewfile`)
- **Font**: [Kusunoki Mono](https://github.com/peinan/kusunoki-mono)

## Repository Structure

This repository uses [GNU Stow](https://www.gnu.org/software/stow/) to manage symlinks. All configuration files are located in the `src/` directory:

```text
dotfiles/
├── src/                <-- Maps to $HOME
│   ├── .zshrc          <-- Links to ~/.zshrc
│   ├── .gitconfig      <-- Links to ~/.gitconfig
│   └── .config/        <-- Links to ~/.config/
│       ├── ghostty/    <-- Links to ~/.config/ghostty
│       └── starship/   <-- Links to ~/.config/starship
├── misc/               <-- GUI app exports & templates (Not stowed)
├── scripts/            <-- Setup scripts (Not stowed)
└── Brewfile            <-- Homebrew bundle (Not stowed)
```

Everything under `src/` is linked; anything that should not be belongs outside
it. Values that cannot go in a public repository live in a separate private
one — see [Config Repositories](/config-repos).
