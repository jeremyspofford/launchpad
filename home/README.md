# Dotfiles Management with GNU Stow

This directory (`home/`) contains all dotfiles and is designed to be managed with [GNU Stow](https://www.gnu.org/software/stow/). Stow is a symlink farm manager that creates symlinks from your home directory (`~`) to these version-controlled dotfiles.

## Why GNU Stow?

- **Cleanliness:** Keeps your home directory tidy by symlinking configuration files from this central, version-controlled location.
- **Portability:** Easily deploy your dotfiles across multiple machines with a single command.
- **Transparency:** Files appear in your home directory as if they were there normally, but are actually symlinked.
- **Automatic Management:** The setup script handles all stow operations automatically.

## Automatic Installation (Recommended)

The dotfiles setup script handles everything automatically:

```bash
cd ~/dotfiles
./scripts/setup.sh
```

This script will:

- Install GNU Stow (via Ansible)
- Automatically run `stow home` to create all necessary symlinks
- Handle any conflicts or issues

## Manual Stow Operations (Advanced)

If you need to manage stow manually, navigate to the repository root:

```bash
cd ~/dotfiles
```

### Stowing the Home Package

The entire `home/` directory is treated as a single stow package:

```bash
stow home
# This creates symlinks for ALL files in home/ to corresponding locations in ~/
```

For example, this creates:

- `home/.zshrc` → `~/.zshrc`
- `home/.config/nvim/init.lua` → `~/.config/nvim/init.lua`
- `home/.gitconfig` → `~/.gitconfig`

### Unstowing (Removing Symlinks)

To remove all dotfiles symlinks:

```bash
stow -D home
```

### Dry Run (Preview Changes)

To see what stow would do without making changes:

```bash
stow -nv home
# -n: dry run (don't make changes)
# -v: verbose output
```

## Current File Structure

The `home/` directory mirrors your home directory structure exactly:

```
home/
├── .commonrc              # Shared bash/zsh configuration
├── .zshrc                # Zsh-specific configuration  
├── .bashrc               # Bash-specific configuration
├── .bash_profile         # Bash login shell setup
├── .gitconfig            # Main git config with conditional includes
├── .gitconfig.*          # Work/personal git identities  
├── .vimrc               # Vim configuration
├── .wezterm.lua         # WeZTerm terminal configuration
├── .hushlogin           # Suppress login messages
└── .config/             # Application configurations
    ├── nvim/            # LazyVim Neovim setup
    │   ├── init.lua     # Neovim entry point
    │   ├── lazy-lock.json
    │   └── lua/         # Lua configuration modules
    ├── git/             # Git conditional configs
    │   ├── personal.gitconfig
    │   └── work.gitconfig
    └── zsh/             # Modular zsh configuration
        ├── aliases.zsh
        ├── completion.zsh  
        ├── env.zsh
        ├── path.zsh
        ├── plugins.zsh
        └── os/          # OS-specific configurations
            ├── darwin.zsh
            ├── linux.zsh
            └── wsl.zsh
```

## Important Notes

- **Conflicts:** If files already exist in `~`, stow will report conflicts. The setup script handles these automatically
- **All-or-nothing:** The current setup treats `home/` as a single package - all files are linked together
- **Symlinks are transparent:** Applications work normally with symlinked files
- **Changes are immediate:** Editing files in `home/` immediately affects your live configuration

## Troubleshooting

If you have issues:

1. **Use the setup script first:** `./scripts/setup.sh` handles most problems
2. **Check for conflicts:** `stow -nv home` shows what would happen  
3. **Manual unstow/restow:** `stow -D home && stow home`
4. **Check symlinks:** `ls -la ~ | grep '\->'` shows current symlinks
