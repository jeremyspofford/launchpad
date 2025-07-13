# Array of files to source
files_to_source=(
  "$HOME/.bashrc"
  "$HOME/.bash_aliases"
  "$HOME/.profile"
  "$HOME/.config/.env"
  "$HOME/.config/custom/pattern_aliases"
)

# Loop through the array and source each file if it exists
for file in "${files_to_source[@]}"; do
  if [[ -f "$file" ]]; then
    source "$file"
  fi
done
