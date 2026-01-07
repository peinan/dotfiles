# -------------------------------------
# Variables
# -------------------------------------

# Pager
export PAGER=/usr/bin/less
export MANPAGER=/usr/bin/less
export LESS='-RMi'

# History
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=10000000
export SAVEHIST=10000000

# Delete words with CTRL+W
# https://unix.stackexchange.com/a/392199
autoload -U select-word-style
select-word-style bash
export WORDCHARS='.-_'

set -o emacs

# Use nvim for the default editor
export EDITOR=nvim sheldon edit

# -------------------------------------
# Shell Initialization
# -------------------------------------

# zsh-autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# starship
eval "$(starship init zsh)"

# sheldon
eval "$(sheldon source)"

# alias
source "${HOME}/.alias"

# iTerm
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# -------------------------------------
# Functions
# -------------------------------------

## change iTerm tab title
#---------------------------
chpwd() { ls; }

## make directory and cd
#-----------------------
mkcd() { mkdir -p "$@" && cd "$@"; }

## change title
#--------------
title() { echo -ne "\e]1;$1\a"; }

## get timestamp
#--------------
ts() {
  date +'%Y%m%dt%H%M%S'
}

repo() {
    local action="${1:-cd}"
    
    case "$action" in
        "list"|"l")
            # List all repositories with fzf selection
            local selected_repo
            selected_repo=$(ghq list | fzf --height=~20% --preview="eza $(ghq root)/{} --color=always" --preview-window=down:3:wrap)
            if [[ -n "$selected_repo" ]]; then
                echo "Selected: $selected_repo"
                echo "Path: $(ghq root)/$selected_repo"
            fi
            ;;
        "cd"|"c")
            # Change directory to selected repository
            local selected_repo
            selected_repo=$(ghq list | fzf --height=~20% --preview="eza $(ghq root)/{} --color=always" --preview-window=down:3:wrap)
            if [[ -n "$selected_repo" ]]; then
                cd "$(ghq root)/$selected_repo" || return 1
            fi
            ;;
        "remove"|"rm"|"r")
            # Remove selected repository
            local selected_repo
            selected_repo=$(ghq list | fzf --height=50% --preview="eza $(ghq root)/{} --color=always" --preview-window=down:3:wrap --prompt="Select repository to remove: ")
            if [[ -n "$selected_repo" ]]; then
                printf "Are you sure you want to remove %s? (y/n [y]) " "$selected_repo"
                read -r confirm
                if [[ -z "$confirm" || "$confirm" =~ ^[Yy](es)?$ ]]; then
                    echo "yes"
                    rm -rf "$(ghq root)/$selected_repo"
                    echo "Removed: $selected_repo"
                else
                    echo "no"
                    echo "Cancelled"
                fi
            fi
            ;;
        "get"|"g")
            # Clone/get a new repository
            if [[ -z "$2" ]]; then
                # Interactive mode: show remote repositories via gh + fzf
                local selected_repo
                selected_repo=$(gh repo list --limit 100 --json nameWithOwner --jq '.[].nameWithOwner' | fzf --height=50% --preview="gh repo view {} --json description,url,pushedAt --template '{{.description}}\n{{.url}}\nLast updated: {{.pushedAt}}'" --preview-window=down:5:wrap --prompt="Select repository to clone: ")
                if [[ -n "$selected_repo" ]]; then
                    ghq get "github.com/$selected_repo" && cd $(ghq root)/github.com/$selected_repo
                fi
            else
                # Normalize URL to path format for ghq
                local repo_path="$2"
                repo_path="${repo_path#https://}"
                repo_path="${repo_path#http://}"
                repo_path="${repo_path#git@}"
                repo_path="${repo_path/://}"
                repo_path="${repo_path%.git}"
                # Remove GitHub-specific paths (/tree/branch, /blob/branch, etc.)
                repo_path="${repo_path%%/tree/*}"
                repo_path="${repo_path%%/blob/*}"

                ghq get "$2" && cd "$(ghq root)/$repo_path"
            fi
            ;;
        "create"|"new"|"n")
            # Create a new repository directory
            if [[ -z "$2" ]]; then
                echo "Usage: repo create <repository_path>"
                echo "Example: repo create github.com/user/new-repo"
                return 1
            fi
            local repo_path="$(ghq root)/$2"
            mkdir -p "$repo_path"
            cd "$repo_path" || return 1
            git init
            echo "Created and initialized: $2"
            ;;
        "open"|"o")
            # Open repository in editor (default: code)
            local editor="${2:-code}"
            local selected_repo
            selected_repo=$(ghq list | fzf --height=50% --preview="eza $(ghq root)/{} --color=always" --preview-window=down:3:wrap)
            if [[ -n "$selected_repo" ]]; then
                local repo_path="$(ghq root)/$selected_repo"
                if command -v "$editor" > /dev/null; then
                    "$editor" "$repo_path"
                else
                    echo "Editor '$editor' not found. Trying fallback editors..."
                    if command -v code > /dev/null; then
                        code "$repo_path"
                    elif command -v vim > /dev/null; then
                        vim "$repo_path"
                    else
                        echo "No suitable editor found (code, vim)"
                    fi
                fi
            fi
            ;;
        "help"|"h"|*)
            # Show help
            cat << 'EOF'
Repository management with ghq and fzf

Usage: repo <command> [args]

Commands:
  list, l         List repositories with fzf selection
  cd, c           Change directory to selected repository
  remove, rm, r   Remove selected repository (with confirmation)
  get, g [url]    Clone repository (interactive if no url)
  create, new, n  Create and initialize a new repository
  open, o [editor] Open repository in editor (default: code)
  help, h         Show this help message

Examples:
  repo                    # List repositories and change to the selected repository
  repo cd                 # Change to selected repository
  repo get                # Interactive repository selection
  repo get github.com/user/repo
  repo create github.com/user/new-repo
  repo remove             # Remove selected repository
  repo open               # Open repository in code (default)
  repo open vim           # Open repository in vim
  repo open nvim          # Open repository in neovim

Requirements: ghq, fzf, git, gh (for interactive get)
EOF
            ;;
    esac
}


nvims() {
  nvim_dirs=( ~/.config/nvim_*(/N) )
  items=( ${nvim_dirs#*/nvim_} )
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config: " --height=~30% --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config=""
  fi
  NVIM_APPNAME=nvim_$config nvim $@
}


# Append exclude rules to .gitignore file with selector (Require: gibo, fzf, bat)
gis() {
  local langs
  langs=(${(f)"$(gibo list | fzf --preview 'gibo dump {} | bat -l gitignore' --header 'Tab: Select, Enter: Confirm')"})

  if [[ -z "$langs" ]]; then
    echo "No language selected."
    return 1
  fi

  local filename
  echo -n "Save to (default: .gitignore): "
  read "filename"

  filename=${filename:-.gitignore}

  gibo dump $langs >> "$filename"
  echo "Dumped [ $langs ] to $filename"
}


# -------------------------------------
# zsh completions (Homebrew)
# -------------------------------------

fpath=(~/.zsh/completion $fpath)
#### use sheldon
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

# completions for docker
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

autoload -Uz compinit && compinit

# -------------------------------------
# fzf
# -------------------------------------

export FZF_DEFAULT_OPTS='
    --height ~100%
    --layout reverse
    --info "inline-right: "
    --info-command="echo -e \"$FZF_POS/$FZF_INFO\""
    --prompt ""
    --input-border=rounded
    --pointer " "
    --multi
    --marker " ▌"
    --scrollbar "▌"
    --color="bg+:-1,gutter:#2d2d2d,pointer:#99cc99,prompt:#81A1C1,info:#686868,spinner:#f2777a" --gutter " "
'
source <(fzf --zsh)
# TODO: enhance the UI of fzf-file-widget and fzf-cd-widget
if type rg > /dev/null 2>&1; then
  export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
fi
if type bat > /dev/null 2>&1; then
  export FZF_CTRL_T_OPTS='--preview "bat --style=numbers --color=always --style=header,grid --line-range :100 {}"'
fi
bindkey '^T' fzf-file-widget
bindkey '\ec' fzf-cd-widget

# -------------------------------------
# walk
# -------------------------------------

function lk {
  cd "$(walk --icons "$@")"
}
export WALK_EDITOR=nvim

# -------------------------------------
# zoxide
# -------------------------------------

eval "$(zoxide init zsh)"
zle -N __zoxide_zi
export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --height 10% --preview-window=down,50%,wrap --preview 'eza --color=always {2}'"
bindkey '^z' __zoxide_zi

# -------------------------------------
# bun
# -------------------------------------

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# -------------------------------------
# 1Password CLI
# -------------------------------------

eval "$(op completion zsh)"; compdef _op op
export OP_BIOMETRIC_UNLOCK_ENABLED=true

# -------------------------------------
# Google SDK
# -------------------------------------

# The next line updates PATH for the Google Cloud SDK.
if [ -f '$HOME/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# -------------------------------------
# Rust
# -------------------------------------

. "$HOME/.cargo/env"

# -------------------------------------
# Windsurf
# -------------------------------------

export PATH="$HOME/.codeium/windsurf/bin:$PATH"

# -------------------------------------
# LM Studio
# -------------------------------------

export PATH="$PATH:$HOME/.cache/lm-studio/bin"

# -------------------------------------
# Kiro
# -------------------------------------

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# -------------------------------------
# Neovim
# -------------------------------------

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# -------------------------------------
# Antigravity
# -------------------------------------

export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# -------------------------------------
# aicommit2
# -------------------------------------

export AICOMMIT_CONFIG_PATH="$HOME/.config/aicommit2/config.ini"

# -------------------------------------
# atuin
# -------------------------------------

eval "$(atuin init zsh --disable-up-arrow)"

# -------------------------------------
# Starship
# -------------------------------------

export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
export STARSHIP_CACHE=$HOME/.cache/starship

# -------------------------------------
# Coreutils
# -------------------------------------

PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
