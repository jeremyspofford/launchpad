# 🚀 dotfiles

A modern dotfiles configuration for developers focused on Zsh, Neovim, and productivity tools.

## ✨ Core Features

- Modern Zsh configuration with Oh-My-Zsh
- Neovim setup with LazyVim
- Version management with mise (formerly rtx)
- Git configuration with SSH key setup
- Dotfile management using stow

## 📦 Optional Components

The following tools are included but not activated by default:

- Bash configuration (alternative to Zsh)
- Starship prompt
- Tmux terminal multiplexer
- Kitty terminal emulator
- Custom themes
- [Fabric](https://github.com/danielmiessler/fabric) - AI-powered CLI tools

## 🛠️ Prerequisites

- Git
- Zsh
- A terminal that supports Unicode and Nerd Fonts
- 1Password CLI (optional)

## 🚀 Quick Start

1. Clone the repository:
```bash
git clone https://github.com/jeremyspofford/dotfiles.git
```

2. Run the installation script:
```bash
./dotfiles/init.sh
```

## 🤔 Installation Process

You'll be prompted for the following during installation:

1. **GitHub Email**: Used for SSH key generation and Git configuration
2. **SSH Key Setup**: After generation, you'll need to add the key to GitHub
3. **1Password CLI**: Optional integration for secret management

## 🔄 Switching Shells

This configuration uses Zsh by default. To switch back to Bash:

```bash
chsh -s /bin/bash
```

## 📚 Additional Resources

- [LazyVim Documentation](https://lazyvim.github.io/)
- [Spaceship Prompt Configuration](https://spaceship-prompt.sh/config/intro)
- [Fabric Documentation](https://github.com/danielmiessler/fabric)

## 🤝 Contributing

Feel free to fork this repository and customize it for your needs. Pull requests for improvements are welcome!

```bash
git clone https://github.com/jeremyspofford/dotfiles.git
./dotfiles/init.sh
```
