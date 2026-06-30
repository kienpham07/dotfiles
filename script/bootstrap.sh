#!/usr/bin/env bash

# ==============================================================================
# bootstrap.sh - Dotfiles Environment Bootstrapper
# ==============================================================================
# This script installs all required packages and dependencies for the dotfiles
# across different operating systems (macOS, Debian/Ubuntu, Fedora, Arch Linux).
#
# It automatically:
#   1. Detects the OS and installs system packages (Zsh, Git, Neovim, tmux, etc.)
#   2. Installs Homebrew if on macOS and not already installed
#   3. Installs Oh My Zsh, Powerlevel10k, and required Zsh plug-ins
#   4. Installs Tmux Plugin Manager (TPM)
#   5. Configures Zsh as the default shell
#   6. Executes install.sh to link all config files
#
# Usage:
#   ./script/bootstrap.sh
# ==============================================================================

set -euo pipefail

# Text styling
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper output functions
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Detect OS
OS="$(uname -s)"

# ------------------------------------------------------------------------------
# 1. Install System Dependencies
# ------------------------------------------------------------------------------
setup_mac() {
    info "Configuring macOS environment..."
    
    # Check for Homebrew
    if ! command -v brew &>/dev/null; then
        info "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Load brew in the current shell session
        eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"
    else
        info "Homebrew is already installed."
    fi

    info "Updating Homebrew packages..."
    brew update

    info "Installing package dependencies..."
    # Base packages + development dependencies for Neovim/Zsh configuration
    brew install git zsh tmux neovim fastfetch fzf fd jq curl ripgrep make gcc unzip go
}

setup_linux() {
    info "Configuring Linux environment..."

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID=$ID
        OS_LIKE=${ID_LIKE:-""}
    else
        OS_ID="unknown"
        OS_LIKE=""
    fi

    info "Detected Linux distribution: ${BOLD}$OS_ID${NC} (like: $OS_LIKE)"

    # Debian / Ubuntu / Mint
    if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" || "$OS_LIKE" == *"debian"* || "$OS_LIKE" == *"ubuntu"* ]]; then
        info "Updating apt index..."
        sudo apt update

        info "Installing package dependencies via apt..."
        sudo apt install -y git zsh tmux neovim curl jq fzf fd-find ripgrep build-essential unzip golang-go

        # Resolve 'fdfind' vs 'fd' executable name discrepancy on Debian-based systems
        if command -v fdfind &>/dev/null; then
            info "Creating symlink for fd-find as 'fd' in ~/.local/bin..."
            mkdir -p "$HOME/.local/bin"
            ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
        fi

        # Install fastfetch (available in Ubuntu 24.04+ repos; download .deb for older releases)
        if ! command -v fastfetch &>/dev/null; then
            info "Checking for fastfetch availability in apt..."
            if sudo apt install -y fastfetch &>/dev/null; then
                success "fastfetch installed successfully via apt."
            else
                warn "fastfetch package not found in repositories. Attempting direct GitHub install..."
                local ff_url
                ff_url=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep "browser_download_url.*linux-amd64.deb" | head -n 1 | cut -d '"' -f 4)
                if [ -n "$ff_url" ]; then
                    info "Downloading deb package: $ff_url"
                    curl -sL "$ff_url" -o /tmp/fastfetch.deb
                    sudo apt install -y /tmp/fastfetch.deb || true
                    rm -f /tmp/fastfetch.deb
                else
                    warn "Could not fetch fastfetch automatically. Please install it manually: https://github.com/fastfetch-cli/fastfetch"
                fi
            fi
        fi

    # Fedora / RHEL / CentOS
    elif [[ "$OS_ID" == "fedora" || "$OS_LIKE" == *"fedora"* || "$OS_LIKE" == *"rhel"* || "$OS_LIKE" == *"centos"* ]]; then
        info "Installing package dependencies via dnf..."
        sudo dnf install -y git zsh tmux neovim fastfetch fzf fd-find ripgrep make gcc unzip golang jq curl

    # Arch Linux / Manjaro
    elif [[ "$OS_ID" == "arch" || "$OS_LIKE" == *"arch"* ]]; then
        info "Installing package dependencies via pacman..."
        sudo pacman -Syu --noconfirm git zsh tmux neovim fastfetch fzf fd ripgrep make gcc unzip go jq curl

    else
        error "Unsupported Linux distribution: $OS_ID"
        warn "Skipping system package install. Please ensure you have the following installed:"
        warn "git, zsh, tmux, neovim, fastfetch, fzf, fd, ripgrep, jq, curl, make, gcc, unzip, golang"
    fi
}

# Execute system-specific setup
if [ "$OS" = "Darwin" ]; then
    setup_mac
elif [ "$OS" = "Linux" ]; then
    setup_linux
else
    error "Unsupported OS: $OS. Bootstrapping aborted."
    exit 1
fi

# ------------------------------------------------------------------------------
# 2. Oh My Zsh Setup
# ------------------------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh (unattended)..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
    success "Oh My Zsh installed."
else
    info "Oh My Zsh is already installed. Skipping."
fi

# ------------------------------------------------------------------------------
# 3. Zsh Plugins and Themes Installation
# ------------------------------------------------------------------------------
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Powerlevel10k Theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    info "Powerlevel10k theme already installed. Skipping."
fi

# Zsh Plugins
install_zsh_plugin() {
    local name="$1"
    local repo="$2"
    if [ ! -d "$ZSH_CUSTOM/plugins/$name" ]; then
        info "Installing Zsh plugin: $name..."
        git clone "$repo" "$ZSH_CUSTOM/plugins/$name"
    else
        info "Zsh plugin $name is already installed. Skipping."
    fi
}

install_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
install_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"

# ------------------------------------------------------------------------------
# 4. Tmux Plugin Manager (TPM) Setup
# ------------------------------------------------------------------------------
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    info "Tmux Plugin Manager (TPM) is already installed. Skipping."
fi

# ------------------------------------------------------------------------------
# 5. Set Default Shell to Zsh
# ------------------------------------------------------------------------------
CURRENT_SHELL="$(basename "$SHELL")"
if [ "$CURRENT_SHELL" != "zsh" ]; then
    info "Changing your default shell to Zsh..."
    ZSH_PATH="$(command -v zsh)"
    if [ -n "$ZSH_PATH" ]; then
        # Ensure zsh is listed in /etc/shells
        if ! grep -q "$ZSH_PATH" /etc/shells; then
            info "Registering Zsh in /etc/shells (requires sudo)..."
            echo "$ZSH_PATH" | sudo tee -a /etc/shells
        fi
        chsh -s "$ZSH_PATH"
        success "Shell changed successfully. Please log out and back in for shell changes to fully take effect."
    else
        warn "Could not locate Zsh path. Please change your shell manually to Zsh using: chsh -s <path-to-zsh>"
    fi
else
    info "Zsh is already your default shell."
fi

# ------------------------------------------------------------------------------
# 6. Execute Dotfiles Installer (install.sh)
# ------------------------------------------------------------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "Triggering configuration installer..."
if [ -f "$DOTFILES_DIR/install.sh" ]; then
    bash "$DOTFILES_DIR/install.sh"
else
    error "Could not locate install.sh in $DOTFILES_DIR!"
    exit 1
fi

success "Environment bootstrapping completed successfully!"
info "For Tmux: Open tmux and press 'Prefix (Ctrl+S) + I' to download the tmux plugins."
info "For Neovim: Launch 'nvim' to let Lazy.nvim install all Neovim plugins automatically."
info "Please restart your terminal or log out & back in to start using your configured Zsh!"
