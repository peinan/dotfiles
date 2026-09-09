---
title: Config Repositories
description: Editor and terminal configurations that live in their own repositories
---

# Config Repositories

Neovim and tmux are configured from their own GitHub repositories rather than
from `src/`. The clone under `ghq root` is the only working copy, and
`~/.config/<name>` is a symlink pointing at it.

## Why they are not submodules

They used to be Git submodules under `src/.config/`. That gave every repository
two working copies, and a machine migration that copied `~/.config` verbatim
turned `~/.config/nvim` into a third one — the one Neovim actually reads.

Editing `src/.config/nvim` then had no effect. A markdown indent setting sat
broken for months because of it: the fix was committed to a copy nothing loaded.
The submodule pins had also drifted 32 commits behind, so they were not buying
reproducibility either.

Every other GitHub repository here is managed with `ghq`. These are now too.

## Layout

| Config | Repository | Working copy | Symlink |
|---|---|---|---|
| Neovim | [peinan/nvim](https://github.com/peinan/nvim) | `~/ghq/github.com/peinan/nvim` | `~/.config/nvim` |
| tmux | [peinan/tmux](https://github.com/peinan/tmux) | `~/ghq/github.com/peinan/tmux` | `~/.config/tmux` |

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
- The Ghostty cursor shaders in `src/.config/ghostty/shaders/` are a vendored
  copy of a third-party repository, not a submodule. See
  `src/.config/ghostty/shaders/UPSTREAM.md`.
