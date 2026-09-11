---
title: Config Repositories
description: Configuration that lives in its own repository rather than in src/
---

# Config Repositories

Some configuration lives in its own GitHub repository rather than in `src/`.
The clone under `ghq root` is the only working copy, and the path it replaces
under `$HOME` is a symlink pointing at it.

Two unrelated reasons put configuration here. Neovim and tmux moved out because
they were submodules and that went badly. `peinan/dotfiles-local` exists
because this repository is public and some values cannot be.

## Why they are not submodules

They used to be Git submodules under `src/.config/`. That gave every repository
two working copies, and a machine migration that copied `~/.config` verbatim
turned `~/.config/nvim` into a third one — the one Neovim actually reads.

Editing `src/.config/nvim` then had no effect. A markdown indent setting sat
broken for months because of it: the fix was committed to a copy nothing loaded.
The submodule pins had also drifted 32 commits behind, so they were not buying
reproducibility either.

Every other GitHub repository here is managed with `ghq`. These are now too.

## What must not live in this repository

This repository is public. Two kinds of value therefore cannot be committed
here, however convenient it would be:

- **Values that embed an account.** A path containing a mail address, a user
  id, or a host name publishes it. The Google Drive named directories are the
  example: their paths carry three addresses.
- **Names from a non-public environment.** Internal repositories, hosts and
  platform tooling should not be published even when the contents stay behind
  an access check. A link that 404s still confirms what exists.

`peinan/dotfiles-local` holds these, and this repository keeps only the hooks
that load it. There are two:

- **`~/.alias.local`**, sourced at the end of `src/.alias` behind a `-f` test.
- **`~/.zsh/local/*.zsh`**, globbed by the `zsh-configs-local` sheldon plugin.

Both hooks do nothing when their target is missing, so a machine that cannot
reach the private repository still gets a working shell — it just misses these
values. Name files there after the concern they configure, matching
`src/.zsh/configs-lazy/`.

`scripts/sanitize-email.sh` runs on `src/.alias` at pre-commit and rewrites any
Google Drive path that still carries an address. It is a safety net for the
first rule, not the mechanism: nothing should reach it.

## Layout

| Config | Repository | Working copy | Symlink |
|---|---|---|---|
| Neovim | [peinan/nvim](https://github.com/peinan/nvim) | `~/ghq/github.com/peinan/nvim` | `~/.config/nvim` |
| tmux | [peinan/tmux](https://github.com/peinan/tmux) | `~/ghq/github.com/peinan/tmux` | `~/.config/tmux` |
| Machine-local | `peinan/dotfiles-local` (private) | `~/ghq/github.com/peinan/dotfiles-local` | `~/.zsh/local`, `~/.alias.local` |

## How the installer sets this up

`scripts/install.sh` Step 4 runs `ghq get` for each repository and then links it
into `~/.config`.

Two details matter:

- **It runs before stow (Step 6).** On a fresh machine `~/.config` does not
  exist, and stow folds the whole tree into `~/.config -> src/.config`. The
  symlinks would then be created *inside* the dotfiles repository. Step 4 calls
  `mkdir -p "$HOME/.config"` first for the same reason.
- **`ghq get` runs without `-u`.** A config repository can hold unpushed
  commits, and `-u` is `--ff-only`, so it would abort the installer under
  `set -e`. Updating is a manual decision.

Step 4b does the same for `peinan/dotfiles-local`, with three differences:

- **It creates `~/.zsh` first**, for the reason Step 4 creates `~/.config`:
  without it stow folds the tree into `~/.zsh -> src/.zsh` and the link lands
  inside this repository.
- **Its `ghq get` sits inside an `if`.** The repository is optional, so under
  `set -e` a bare failure would abort the whole installer. A machine without
  access gets a warning and continues.
- **It links two paths rather than one**, `~/.zsh/local` and `~/.alias.local`.

## Updating

The symlink is transparent, so work in `~/.config/nvim` directly:

```bash
cd ~/.config/nvim
git pull
git push
```

## Migrating a machine that still has real directories

Push everything that exists only in the old directory **first** — it may be the
only copy on the machine.

```bash
cd ~/.config/nvim
git status                      # commit anything you want to keep
git push origin main

ghq get peinan/nvim             # or `git -C "$(ghq root)/github.com/peinan/nvim" pull`
```

Carry over anything untracked or gitignored that you still want (for Neovim that
is `lazy-lock.json`, so plugin versions do not drift), then swap in the symlink:

```bash
mv ~/.config/nvim ~/.config/nvim.backup
ln -s "$(ghq root)/github.com/peinan/nvim" ~/.config/nvim
```

Keep the backup until you have used the editor for a while.

## Troubleshooting

Check which directory is actually loaded:

```bash
readlink ~/.config/nvim
git -C ~/.config/nvim rev-parse --show-toplevel
nvim --headless -c 'lua print(vim.fn.resolve(vim.fn.stdpath("config")))' -c q
```

All three should point at the ghq clone. If `readlink` prints nothing,
`~/.config/nvim` is a real directory — see the migration steps above.

## Notes

- `peinan/tmux` still carries its plugins as nested submodules, but tpm loads
  them from `$XDG_DATA_HOME/tmux/plugins` at runtime, so
  `~/.config/tmux/plugins/` is unused. The installer initializes them anyway to
  keep a partially cloned checkout repairable.
- Vim was dropped from this repository. `~/.config/vim` did not exist and
  [peinan/vim](https://github.com/peinan/vim) needs a `~/.vimrc` symlink on top
  of it to load at all; the repository still exists on GitHub.
- The Ghostty cursor shader in `src/.config/ghostty/shaders/` is a vendored copy
  of a third-party file, not a submodule. Credit and the upstream commit are in
  `src/.config/ghostty/README.md`.
- `~/.claude/settings.json` is the one file under `src/` that is a real copy
  rather than a symlink, and it cannot be fixed. Claude Code rewrites it with an
  atomic rename, which replaces a symlink with a regular file. The marketplace
  entries naming internal repositories cannot move to `~/.claude/settings.local.json`
  either: `extraKnownMarketplaces` is documented as readable from any settings
  file but is ignored there. The durable fix is an organization-deployed managed
  settings file, not this repository.
