<div align="center">
    
# dotfiles

[Peinan](https://github.com/peinan)'s collection of configuration files for setting up a development environment.

</div>


## What's Included

- **Shell**: [Zsh](https://www.zsh.org/) (`.zshrc`, `.zshenv`, `.alias`)
    - **Prompt**: [Starship](https://starship.rs/)
    - **Plugin Manager**: [Sheldon](https://sheldon.cli.rs/)
- **Git**: Git configuration (`.gitconfig`) and [delta](https://dandavison.github.io/delta/) for beautiful diffs
- **Editors**: [Neovim](https://neovim.io/) (submodule)
- **Terminal**: [Ghostty](https://ghostty.org/)
- **Multiplexing**: [tmux](https://github.com/tmux/tmux) (submodule)
- **Package Management**: [Homebrew](https://brew.sh/) (`Brewfile`)
- **Font**: [SF Mono Square](https://github.com/delphinus/homebrew-sfmono-square)


## Quick Start

> [!Caution]
> This dotfiles is designed for macOS.

```bash
# The easiest way
curl -fsSL https://dotfiles.peinan.cc/install | bash
# or
wget -qO- https://dotfiles.peinan.cc/install | bash
# or via GitHub
curl -fsSL https://raw.githubusercontent.com/peinan/dotfiles/HEAD/scripts/install.sh | bash

# or you can install stow and setup step-by-step by yourself
brew install stow
git clone --recursive https://github.com/peinan/dotfiles && cd dotfiles
brew bundle install
stow -v -t ~ src
```


## Usage

This repository uses [GNU Stow](https://www.gnu.org/software/stow/) to manage symlinks.
All configuration files are located in the `src/` directory, which mirrors the structure of the home directory.

### Directory Structure

We use an "All-in-One" package strategy. The `src/` directory is treated as a single package that maps directly to `$HOME`.

```text
dotfiles/
├── src/                <-- Maps to $HOME
│   ├── .zshrc          <-- Links to ~/.zshrc
│   ├── .gitconfig      <-- Links to ~/.gitconfig
│   └── .config/        <-- Links to ~/.config/
│       ├── nvim/       <-- Links to ~/.config/nvim (Directory link)
│       └── gh/         <-- Links to ~/.config/gh
├── scripts/            <-- Setup scripts (Not stowed)
└── Brewfile            <-- Homebrew bundle (Not stowed)
```

### Workflow

#### How to add a new config file

1.  **Move** the file from your home directory to the `src` directory (maintaining the structure).
2.  Run `stow` again to create the link.

```bash
# Example: Adding .tmux.conf
mv ~/.tmux.conf src/
stow -v -t ~ src
```

#### How to edit configurations

Since they are symlinked, you can edit the files in your home directory directly. The changes will be reflected in the repository.

```bash
vim ~/.zshrc
# Changes are automatically applied to src/.zshrc
```

#### Advanced Usage: Handling Submodules (e.g., Neovim)

Directories that are Git submodules (like `src/.config/nvim`) are linked as a **single directory symlink**.
For this to work cleanly, ensure the target directory (e.g., `~/.config/nvim`) does not exist before running stow.

#### Advanced Usage: Ignoring Files

Files listed in `src/.stow-local-ignore` are excluded from symlinking.
(e.g., `Brewfile`, `README.md`, `.DS_Store`)

#### Advanced Usage: Check Link Status

To verify which files are managed by stow:

```bash
ls -la ~ | grep "dotfiles/src"
# Output example:
# .zshrc -> .../dotfiles/src/.zshrc
```

For detailed installation instructions, see the [documentation site](https://dotfiles.peinan.cc).

## Activities

![Alt](https://repobeats.axiom.co/api/embed/3f518f6c17b4e2bc5c627bf58b2ec248d09cad08.svg "Repobeats analytics image")

## License

This repository is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.
