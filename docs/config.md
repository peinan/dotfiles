---
title: Configuration Files
description: Description of main configuration files
---

# Configuration Files

Description of the main configuration files included in this repository.

## Shell {#shell}

### .zshrc

The main Zsh configuration file. It includes the following features:

- Environment variable settings (PAGER, HISTFILE, HISTSIZE, etc.)
- Starship prompt initialization
- Sheldon plugin manager initialization
- Alias loading
- Initialization of various tools (zoxide, fzf, walk, etc.)
- Completion settings

**Location:** `~/.dotfiles/src/.zshrc`

### .zshenv

Environment variable configuration file that is loaded in all Zsh sessions.

**Location:** `~/.dotfiles/src/.zshenv`

### .alias

File defining aliases for commonly used commands. Main aliases:

- `ls` aliases (la, ll, lla)
- `cd` aliases (_, ...., ......)
- `vi` → `nvim`
- Python-related aliases (py, ipy, pyc)
- Browser launch aliases (chrome, safari)

**Location:** `~/.dotfiles/src/.alias`

## Git {#git}

### .gitconfig

Git configuration file. It includes the following features:

- **User Information:** Name and email address
- **Aliases:** Shortcuts for commonly used Git commands (st, br, co)
- **Delta:** Settings for beautiful diff display
  - Side-by-side display
  - Line numbers
  - Decorations
- **Git LFS:** Large file management

**Location:** `~/.dotfiles/src/.gitconfig`

**Note:** Please change the username and email address before use.

```ini
[user]
  email = peinan7@gmail.com
  name = Peinan Zhang

[alias]
  st = status -u
  br = branch
  co = checkout

[core]
  pager = delta

[delta]
  features = decorations
  line-numbers = true
  side-by-side = true
```

## Starship {#starship}

### starship.toml

Starship is a fast and customizable prompt. This configuration enables the following features:

- OS symbol display
- Hostname display (special display when SSH connected)
- Directory path display
- Git branch and status display
- Python environment display
- Time display

**Location:** `~/.dotfiles/src/.config/starship/starship.toml`

```toml
format = '''$os $hostname [󰉋 ](cyan) $directory $git_branch $git_status $python
$time$character'''

[character]
error_symbol = '[▶](bold red)'
success_symbol = '[▶](bold green)'

[git_branch]
symbol = "  "
format = '[$symbol$branch(:$remote_branch)]($style) '
```

## Sheldon {#sheldon}

### plugins.toml

Sheldon is a Zsh plugin manager. It manages the following plugins:

- **fast-syntax-highlighting:** Fast syntax highlighting
- **zsh-autosuggestions:** Command autosuggestion
- **zsh-completions:** Additional completion features

**Location:** `~/.dotfiles/src/.config/sheldon/plugins.toml`

```toml
[plugins.fast-syntax-highlighting]
github = 'zdharma/fast-syntax-highlighting'

[plugins.zsh-autosuggestions]
github = 'zsh-users/zsh-autosuggestions'

[plugins.zsh-completions]
github = "zsh-users/zsh-completions"
```

## Brewfile {#brewfile}

### Brewfile

List of packages to install with Homebrew. Categorized as follows:

- **Brew:** Command-line tools (node, neovim, tmux, git-delta, starship, etc.)
- **Cask:** GUI applications (1password, docker, cursor, raycast, etc.)
- **Mac App Store:** App Store apps (installed with mas command)

**Location:** `~/.dotfiles/src/Brewfile`

**Installation:** `brew bundle install --file src/Brewfile`

::: tip
**Main packages:** neovim, tmux, starship, git-delta, sheldon, zoxide, ripgrep, bat, eza, gh, node, yarn, and more
:::

## Additional Configuration

Other configuration files and directories:

- `src/.ideavimrc` - Vim configuration for IntelliJ IDEA / PyCharm
- `src/.config/tmux/` - tmux configuration (submodule)
- `src/.config/nvim/` - Neovim configuration (submodule)
- `src/.config/vim/` - Vim configuration (submodule)

For details about submodules, see the [Submodules page](/submodules).

