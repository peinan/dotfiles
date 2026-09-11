<div align="center">
    
# dotfiles

[Peinan](https://github.com/peinan)'s collection of configuration files for setting up a development environment.

</div>


## What's Included

- **Shell**: [Zsh](https://www.zsh.org/), [Starship](https://starship.rs/), [Sheldon](https://sheldon.cli.rs/)
- **Git**: [lazygit](https://github.com/jesseduffield/lazygit), [delta](https://dandavison.github.io/delta/), [rp](https://github.com/peinan/rp)
- **Editors**: [Neovim](https://neovim.io/)
- **Terminal**: [Ghostty](https://ghostty.org/), [Herdr](https://herdr.dev/)
- **Package Management**: [Homebrew](https://brew.sh/), [mise](https://mise.jdx.dev/)
- **macOS**: [Karabiner-Elements](https://karabiner-elements.pqrs.org/), [BetterTouchTool](https://folivora.ai/)
- **Font**: [Kusunoki Mono](https://peinan.github.io/kusunoki-mono/)


## Quick Start

> [!Caution]
> This dotfiles is designed for macOS.

> [!Note]
> The installer asks for your password once, at the start — Homebrew, two `.pkg`
> casks and Docker Desktop's symlinks into `/usr/local/bin` all need root, and
> taking the sudo timestamp up front collapses them into a single prompt.
>
> Karabiner-Elements, Docker Desktop and Google Drive will each ask again in a
> GUI dialog the first time they launch, for a system extension, a privileged
> helper and a file provider extension respectively. Those come from macOS and
> cannot be pre-authorised by a script, so expect them after the install rather
> than during it.

```bash
# The easiest way
curl -fsSL https://dotfiles.peinan.cc/install | bash
# or
wget -qO- https://dotfiles.peinan.cc/install | bash
# or via GitHub
curl -fsSL https://raw.githubusercontent.com/peinan/dotfiles/HEAD/scripts/install.sh | bash

# or you can install stow and setup step-by-step by yourself
brew install stow
git clone https://github.com/peinan/dotfiles && cd dotfiles
brew bundle install
stow -v -t ~ src
```


## Usage

This repository uses [GNU Stow](https://www.gnu.org/software/stow/) to manage symlinks.
All configuration files are located in the `src/` directory, which mirrors the structure of the home directory.

### Directory Structure

We use an "All-in-One" package strategy. The `src/` directory is treated as a single package that maps directly to `$HOME`.

That mapping holds without exception: everything under `src/` is linked into
`$HOME`. Anything that should not be linked belongs outside `src/` rather than
ignored inside it — see [Ignoring Files](#advanced-usage-ignoring-files) for why.

```text
dotfiles/
├── src/                <-- Maps to $HOME
│   ├── .zshrc          <-- Links to ~/.zshrc
│   └── .config/        <-- Links to ~/.config/
│       ├── git/        <-- Links to ~/.config/git
│       ├── ghostty/    <-- Links to ~/.config/ghostty
│       └── gh/         <-- Links to ~/.config/gh
├── misc/               <-- GUI app exports & templates (Not stowed)
├── scripts/            <-- Setup scripts (Not stowed)
└── Brewfile            <-- Homebrew bundle (Not stowed)
```

### Workflow

#### How to add a new config file

1.  **Move** the file from your home directory to the `src` directory (maintaining the structure).
2.  Run `stow` again to create the link.

```bash
# Example: Adding .editorconfig
mv ~/.editorconfig src/
stow -v -t ~ src
```

Check first that the value belongs in a public repository — see
[Machine-Local Values](#advanced-usage-machine-local-values).

#### How to edit configurations

Since they are symlinked, you can edit the files in your home directory directly. The changes will be reflected in the repository.

```bash
vim ~/.zshrc
# Changes are automatically applied to src/.zshrc
```

#### Advanced Usage: Editor and Terminal Configs

Neovim and tmux are **not** part of `src/`. They live in their own repositories
([peinan/nvim](https://github.com/peinan/nvim), [peinan/tmux](https://github.com/peinan/tmux))
cloned under `ghq root`, and `~/.config/{nvim,tmux}` are symlinks pointing at those clones.
Stow never touches them. See the [Config Repos page](https://dotfiles.peinan.cc/config-repos) for details.

#### Advanced Usage: Ignoring Files

There is no `.stow-local-ignore` here, so stow applies its built-in ignore list:
`.git`, `.gitignore`, `.gitmodules`, `*~`, `#*#`, and — only at the top of the
package — `README.*`, `LICENSE.*` and `COPYING`.

Adding a `.stow-local-ignore` would **replace** that built-in list rather than
extend it, so prefer keeping files out of `src/` over ignoring them. `misc/`
sits at the repository root for exactly this reason: it holds exported GUI app
settings that no application reads from `$HOME`, and moving it out of `src/`
was cheaper than teaching stow to skip it.

#### Advanced Usage: Machine-Local Values

This repository is public, so values that embed an account (a mail address, a
user id, a host name) and names from a non-public environment cannot be
committed here. They live in a separate private repository, and this one keeps
only two hooks that load it: `~/.alias.local`, sourced at the end of
`src/.alias`, and `~/.zsh/local/*.zsh`, globbed by sheldon. Both are no-ops
when absent, so a machine without access to that repository still works.

See the [Config Repos page](https://dotfiles.peinan.cc/config-repos) before
adding anything account-specific.

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
