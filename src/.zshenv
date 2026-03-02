export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:="$HOME/.config"}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:="$HOME/.cache"}
export XDG_DATA_HOME=${XDG_DATA_HOME:="$HOME/.local/share"}
export XDG_STATE_HOME=${XDG_STATE_HOME:="$HOME/.local/state"}
export XDG_BIN_HOME="$HOME/.local/bin"
export PATH="$XDG_BIN_HOME:$PATH"

# Deduplicate PATH
typeset -U path

# Remove unwanted PATH entries injected by installers
local -a _path_deny=(
  '*/Python.framework/*'
  '*/.cache/lm-studio/*'
  '*/.codeium/windsurf/*'
)
for _deny in "${_path_deny[@]}"; do
  path=("${path[@]:#${~_deny}}")
done
unset _deny _path_deny
