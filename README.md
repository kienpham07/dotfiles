# kienpham07's Dotfiles

A collection of configuration files (dotfiles) to customize and automate the setup of Zsh, Tmux, Neovim (LazyVim), VS Code, Zed Editor, Ghostty, and Fastfetch. It includes a cross-platform bootstrap script that automatically configures Linux distros (Ubuntu, Debian, Fedora, Arch) and macOS.

---

## Project Structure

```text
.
├── LICENSE             # MIT License
├── README.md           # This documentation file
├── fastfetch/          # Custom fastfetch system info configurations
│   └── config.jsonc    # System information layout configurations
├── ghostty/            # Ghostty terminal settings
│   ├── config          # Terminal font, style, and window config
│   └── shaders/        # Custom GLSL shaders (e.g. cursor smear)
├── nvim/               # Complete LazyVim setup
│   ├── init.lua        # Neovim entry point
│   ├── lazyvim.json    # Installed extras/plugins configuration
│   └── lua/            # Custom keymaps, options, and plugin settings
├── script/             # Installation and environment set up scripts
│   ├── bootstrap.sh    # Distro-agnostic package & dependency installer
│   └── install.sh      # Safe symlink setup script with automatic backups
├── tmux/               # Tmux terminal multiplexer settings
│   └── .tmux.conf      # Prefix shortcuts, plugins, and styling
├── vscode/             # VS Code preferences & keybindings
│   ├── settings.json   # VS Code configuration preferences
│   ├── keybindings.json# Key mapping adjustments
│   └── custom-vscode.css# Styling customizations
├── zed/                # Zed editor configuration
│   └── settings.json   # Font size, icons, themes, and formatter configs
└── zsh/                # Shell customization configurations
    ├── .zshrc          # Primary shell startup configurations and aliases
    └── .p10k.zsh       # Powerlevel10k theme prompt configurations
```

---

## Installation

### Option 1: Full System Bootstrap (Recommended for new setups)
Run the bootstrap script. It will automatically detect your OS, install system dependencies, download shell plugins (Oh My Zsh, Powerlevel10k, syntax highlighting, autosuggestions), install Tmux Plugin Manager, change your default shell to Zsh, and create all symlinks.

```bash
./script/bootstrap.sh
```

### Option 2: Symlinks Only (If dependencies are already installed)
If you already have Zsh, Neovim, and other packages installed and only want to apply the configuration links:

```bash
./script/install.sh
```

> [!IMPORTANT]
> **Safety Backups:** If a configuration file (like `~/.zshrc`) already exists, `install.sh` will move it to a backup directory `~/.dotfiles_backup/YYYYMMDD_HHMMSS/` before creating a symlink. Your original configurations are never lost.

---

## Post-Install Steps

To finish setting up all features:

1. **Restart your Shell / Terminal:**
   Log out and log back in, or launch a new terminal window to apply the switch to Zsh.

2. **Load Tmux Plugins:**
   Start Tmux by running `tmux`. Press `Ctrl + s` followed by `I` (capital `i`) to trigger Tmux Plugin Manager (TPM) to install configured plugins.

3. **Initialize Neovim Plugins:**
   Open Neovim by running `nvim`. LazyVim will automatically launch and fetch all configured language servers (LSP), diagnostics tools, and formatting libraries.

---

## License

This project is licensed under the [MIT License](file:///home/kienpham07/Downloads/Disk%20D%20Window/dotfiles/LICENSE).
