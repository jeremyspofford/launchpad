# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/bash_profile.pre.bash" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/bash_profile.pre.bash"
# Array of files to source
files_to_source=(
  "$HOME/.bashrc"
  "$HOME/.bash_aliases"
  "$HOME/.profile"
)

# Loop through the array and source each file if it exists
for file in "${files_to_source[@]}"; do
  if [[ -f "$file" ]]; then
    source "$file"
  fi
done

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/bash_profile.post.bash" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/bash_profile.post.bash"
