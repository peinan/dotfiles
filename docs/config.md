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
- Pre-expanded `brew shellenv` output, to save about 50ms per startup
- Sheldon plugin manager initialization
- Alias loading
- Completion settings

Everything else is a sheldon plugin rather than a line here — the prompt,
zoxide, atuin and this repository's own Zsh files included. See
[Sheldon](#sheldon).

**Location:** `src/.zshrc`

### .zshenv

Environment variable configuration file that is loaded in all Zsh sessions.

**Location:** `src/.zshenv`

### .alias

File defining aliases for commonly used commands. Main aliases:

- `ls` aliases (la, ll, lla)
- `cd` aliases (_, ...., ......)
- `vi` → `nvim`
- Python-related aliases (py, ipy, pyc)
- Browser launch aliases (chrome, safari)

The last line sources `~/.alias.local` if it exists. Aliases whose values embed
an account — the Google Drive named directories, for instance — live there
instead of here; see [Config Repositories](/config-repos).

**Location:** `src/.alias`

## Git {#git}

### config

Git configuration file. It includes the following features:

- **User Information:** Name and email address
- **Aliases:** Shortcuts for commonly used Git commands (st, br, co, cm, df, wt)
- **Delta:** Settings for beautiful diff display
  - Side-by-side display
  - Line numbers
  - Decorations, plus a separate feature set for interactive diffs
- **Credentials:** `gh auth git-credential` as the helper for GitHub
- **ghq:** `~/ghq` as the clone root
- **Git LFS:** Large file management

**Location:** `src/.config/git/config`

This is the XDG path, not `~/.gitconfig`. Git reads both, but only this one is
managed here — if a `~/.gitconfig` also exists it wins for any key it sets.

**Note:** Please change the username and email address before use.

```ini
[init]
    defaultBranch = main

[user]
    email = peinan7@gmail.com
    name  = peinan

[alias]
    st = status -u
    br = branch
    co = checkout

[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only --features=interactive

[delta]
    features = decorations
    line-numbers = true
    side-by-side = true

[fetch]
    prune = true
    pruneTags = true

[ghq]
    root = ~/ghq
```

An excerpt; the full file also carries the `delta` colour settings, the Git LFS
filter and the GitHub credential helpers.

### ignore

The global gitignore, listing `.DS_Store`.

**Location:** `src/.config/git/ignore`

## Starship {#starship}

### starship.toml

Starship is a fast and customizable prompt. The left prompt is deliberately
short — hostname, username, and the prompt character — with everything
informational moved to `right_format` so the cursor stays near the left margin:

- **Left:** hostname (shown when connected over SSH), username, prompt character
- **Right:** command duration, Python and Rust versions, the Git user from a
  custom module, and the directory path

**Location:** `src/.config/starship/starship.toml`

```toml
add_newline = true

format = """
$hostname\
$username\
$character
"""

right_format = """
$cmd_duration\
$python\
$rust\
${custom.gituser}\
$directory
"""

[character]
error_symbol = '[](red) '
success_symbol = '[](green) '
```

::: info
The prompt character uses nerd font glyphs, so a patched font is required.
[Kusunoki Mono](https://github.com/peinan/kusunoki-mono) is the one the Brewfile
installs.
:::

## Sheldon {#sheldon}

### plugins.toml

Sheldon is a Zsh plugin manager. Some of the plugins it manages:

- **fast-syntax-highlighting:** Fast syntax highlighting
- **zsh-autosuggestions:** Command autosuggestion
- **zsh-completions:** Additional completion features

It also loads this repository's own Zsh files as plugins, by pointing at a
local directory and globbing `*.zsh`. Most of them are applied through
`zsh-defer`, so they do not cost shell startup time:

- **zsh-configs:** `~/.zsh/configs`, loaded immediately
- **zsh-configs-lazy:** `~/.zsh/configs-lazy`, deferred
- **zsh-configs-local:** `~/.zsh/local`, deferred. Not part of this repository
  — see [Config Repositories](/config-repos). Sheldon skips the plugin when the
  directory is absent, so nothing breaks on a machine without it.

**Location:** `src/.config/sheldon/plugins.toml`

An excerpt — the file has eleven plugin blocks:

```toml
[plugins.zsh-configs-lazy]
local = "~/.zsh/configs-lazy"
use = ["*.zsh"]
apply = ["defer"]

[plugins.zsh-configs-local]
local = "~/.zsh/local"
use = ["*.zsh"]
apply = ["defer"]
```

## Brewfile {#brewfile}

### Brewfile

List of packages to install with Homebrew. Categorized as follows:

- **Brew:** Command-line tools (neovim, tmux, git-delta, starship, etc.)
- **Cask:** GUI applications (1password, docker-desktop, ghostty, raycast, etc.)
- **Mac App Store:** App Store apps (installed with mas command)

Node and the tools installed through npm are not here — [mise](#mise) owns
those. A tool declared in both places is worse than either: the copies shadow
each other on `PATH`, so the one you edit may not be the one that runs.

**Location:** `Brewfile` (repository root)

**Installation:** `brew bundle install`

::: tip
**Main packages:** neovim, tmux, starship, git-delta, sheldon, zoxide, ripgrep, bat, eza, gh, uv, and more
:::

## mise {#mise}

### config.toml

[mise](https://mise.jdx.dev/) owns the runtimes and the tools installed through
them — Node, Deno, Rust, Bun, and the npm and cargo packages that depend on
them. The installer removes Homebrew's Node in Step 5b so there is one source
of truth.

**Location:** `src/.config/mise/config.toml`

This file holds the global `[tools]` table only. `mise use -g` writes to it, so
expect mise to reformat it.

### mise.toml (project template)

`[env]` and `[tasks.*]` resolve against `config_root`, so they only make sense
per project: in the global config the tasks surface in every directory. They
live in a template instead, to copy into a repository root as `mise.toml`.

**Location:** `misc/mise/mise.toml`

## Additional Configuration

Other configuration files and directories:

- `src/.ideavimrc` - Vim configuration for IntelliJ IDEA / PyCharm
- `misc/` - Exported GUI app settings (AltTab, BetterTouchTool, Vimium) and the
  mise project template. Nothing reads these from `$HOME`, so unlike `src/`
  this directory is never linked; it is a place to keep the exports under
  version control.

Neovim and tmux are not in `src/`. They live in their own repositories cloned
under `ghq root`, and `~/.config/{nvim,tmux}` are symlinks pointing at those
clones. See the [Config Repos page](/config-repos).

