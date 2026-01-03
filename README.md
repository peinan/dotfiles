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

```bash
# Clone the repository
git clone https://github.com/peinan/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Initialize submodules
git submodule update --init --recursive

# Install packages
brew bundle install --file src/Brewfile

# Create symbolic links (example)
ln -s ~/.dotfiles/src/.zshrc ~/.zshrc
```

For detailed installation instructions, see the [documentation site](https://peinan.github.io/dotfiles/install).

## Documentation

**[Full Documentation](https://peinan.github.io/dotfiles/)** - Complete installation guide and configuration details

## Repository Structure

All configuration files are located in the `src/` directory:
- `src/.zshrc`, `src/.zshenv`, `src/.alias` - Shell configuration
- `src/.gitconfig` - Git configuration
- `src/.config/` - Application-specific configurations (Neovim, tmux, Starship, etc.)
- `src/Brewfile` - Homebrew package list

## Activities

![Alt](https://repobeats.axiom.co/api/embed/3f518f6c17b4e2bc5c627bf58b2ec248d09cad08.svg "Repobeats analytics image")

## License

This repository is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.
