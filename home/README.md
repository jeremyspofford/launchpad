# Dotfiles Management with GNU Stow

This directory (`home/`) is designed to be managed with [GNU Stow](https://www.gnu.org/software/stow/). Stow is a symlink farm manager that allows you to keep your dotfiles in a version-controlled directory and then symlink them into your home directory (`~`).

## Why GNU Stow?

-   **Cleanliness:** Keeps your home directory tidy by symlinking configuration files from a central, version-controlled location.
-   **Portability:** Easily deploy your dotfiles across multiple machines.
-   **Modularity:** Each subdirectory within `home/` (e.g., `config`, `git`, `wezterm`) is treated as a separate "package," allowing you to selectively manage which dotfiles are symlinked.

## Installation

First, ensure you have GNU Stow installed on your system.

Stow is installed via Ansible as part of the dotfiles setup.

## Usage

To use Stow, navigate to the `home/` directory within your dotfiles repository.

```bash
cd /Users/jeremyspofford/workspace/dotfiles/home
```

### Stowing a Package

To symlink a package (e.g., `config`, `git`, `wezterm`) into your home directory, run `stow` followed by the package name:

```bash
stow <package_name>
# Example: stow config
# This will symlink files from home/config into ~/.config
```

For example, to stow your Zsh configuration:

```bash
stow config
stow git
stow wezterm
stow vim
stow hushlogin
stow shell_configuration_files
```

### Unstowing a Package

To remove the symlinks created by Stow for a specific package, use the `-D` (delete) flag:

```bash
stow -D <package_name>
# Example: stow -D config
```

### Dry Run

Before making any changes, it's highly recommended to perform a dry run to see what `stow` will do:

```bash
stow -nv <package_name>
# -n: dry run
# -v: verbose output
```

### Important Considerations

-   **Conflicts:** If a file or directory already exists in your home directory that `stow` wants to create a symlink for, it will report a conflict. You'll need to resolve these manually (e.g., move the existing file, back it up, or delete it) before `stow` can proceed.
-   **Target Directory:** By default, `stow` symlinks to the parent directory of where it's run. Since you'll be running `stow` from `/Users/jeremyspofford/workspace/dotfiles/home`, it will correctly symlink to `/Users/jeremyspofford/workspace/dotfiles/` which is not your home directory. To make it symlink to your actual home directory, you need to specify the target directory using the `-t` flag:

    ```bash
    stow -t "$HOME" <package_name>
    # Example: stow -t "$HOME" config
    ```
    **Always use `-t "$HOME"` when running stow from this directory.**

-   **Selective Stowing:** You can choose to stow only specific packages. For instance, if you only want your `git` configuration:

    ```bash
    stow -t "$HOME" git
    ```

This README provides a quick start to managing your dotfiles with GNU Stow.
