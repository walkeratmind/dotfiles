<div align="center">
  <h1>🏠 Dotfiles</h1>
  <p>Personal dotfiles and system configuration managed with <a href="https://chezmoi.io">chezmoi</a></p>
</div>

## 📁 What's Inside

This repository contains my personal dotfiles and system configuration for macOS, featuring:

- **Shell Configuration**: Zsh with custom profiles and configurations
- **Development Tools**: Git, tmux, curl, and IDE configurations
- **Neovim Setup**: External repository management with multiple configurations
- **Automated Scripts**: System setup, app installation, and configuration scripts

## 🗂️ Structure

```
.
├── chezmoi.toml              # Chezmoi configuration
├── .chezmoiexternal.toml     # External repository management
├── .chezmoiignore            # Files to exclude from home directory
├── home/                     # Dotfiles (will be moved to root)
│   ├── dot_config/           # ~/.config/ directory
│   ├── dot_curlrc            # ~/.curlrc
│   ├── dot_env               # ~/.env
│   ├── dot_gitconfig         # ~/.gitconfig
│   ├── dot_gitmessage        # ~/.gitmessage
│   ├── dot_ideavimrc         # ~/.ideavimrc
│   ├── dot_shellrc.d/        # ~/.shellrc.d/
│   ├── dot_tmux.conf         # ~/.tmux.conf
│   ├── dot_zprofile          # ~/.zprofile
│   ├── dot_zshrc             # ~/.zshrc
│   └── dot_zshrc.d/          # ~/.zshrc.d/
└── scripts/                  # Setup and configuration scripts
    ├── bat-theme.sh          # Bat theme configuration
    ├── brewinstall.sh        # Homebrew package installation
    ├── fontinstall.sh        # Font installation
    ├── macapps.sh            # macOS applications setup
    ├── macconfig.sh          # macOS system configuration
    ├── setup.sh              # Main setup script
    ├── extras/               # Additional utilities
    └── programs/             # Program-specific configurations
```

## 🚀 Quick Start

### Prerequisites

- macOS
- [Homebrew](https://brew.sh/) installed
- Git configured with your credentials

### Installation

1. **Install chezmoi:**
   ```bash
   brew install chezmoi
   ```

2. **Initialize with this repository:**
   ```bash
   chezmoi init --apply walkeratmind/dotfiles
   ```

3. **Run setup scripts (optional):**
   ```bash
   # Install Homebrew packages
   ~/.local/share/chezmoi/scripts/brewinstall.sh
   
   # Configure macOS settings
   ~/.local/share/chezmoi/scripts/macconfig.sh
   
   # Install fonts
   ~/.local/share/chezmoi/scripts/fontinstall.sh
   
   # Install macOS applications
   ~/.local/share/chezmoi/scripts/macapps.sh
   ```

## ⚙️ Neovim Configuration

This setup includes external Neovim configurations managed externally using [.chezmoiexternal](.chezmoiexternal.toml):

- **Main Config**: `~/.config/nvim` - Primary Neovim setup
- **LazyVim Config**: `~/.config/nvim-lazy` - LazyVim distribution setup

The configurations are pulled from my separate [nvim-config repository](https://github.com/walkeratmind/nvim) using chezmoi's external feature.

### Switching Between Neovim Configs

```bash
# Use main config
nvim

# Use LazyVim config
NVIM_APPNAME=nvim-lazy nvim
```

## 🔄 Daily Usage

### Update dotfiles
```bash
chezmoi update
```

### Update external repositories (including Neovim configs)
```bash
chezmoi apply --refresh-externals
# or shorter:
chezmoi -R apply
```

### Edit configuration
```bash
# Edit a dotfile
chezmoi edit ~/.zshrc

# Add a new dotfile
chezmoi add ~/.new-config-file
```

### Check what would change
```bash
chezmoi diff
```

## 🛠️ Scripts

| Script | Description |
|--------|-------------|
| `setup.sh` | Main setup script for new system |
| `brewinstall.sh` | Install Homebrew packages and casks |
| `macconfig.sh` | Configure macOS system preferences |
| `fontinstall.sh` | Install programming fonts |
| `macapps.sh` | Install and configure macOS applications |
| `bat-theme.sh` | Configure bat syntax highlighting theme |

## 📝 Customization

1. **Fork this repository**
2. **Update personal information** in `chezmoi.toml`
3. **Modify configurations** to match your preferences
4. **Update external repositories** in `.chezmoiexternal.toml`
5. **Customize scripts** in the `scripts/` directory

## 🔗 External Dependencies

- [Neovim Configuration](https://github.com/walkeratmind/nvim-config) - Separate repository for Neovim setup
- [Homebrew](https://brew.sh/) - Package manager for macOS
- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework (if used)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [chezmoi](https://chezmoi.io) for excellent dotfiles management
- [LazyVim](https://lazyvim.org) for the amazing Neovim distribution
- The open-source community for inspiration and tools

---

<div align="center">
  <p>⭐ Star this repo if you find it helpful!</p>
</div>
