#!/usr/bin/env bash

# ==============================================================================
# install.sh - Dotfiles Symlink Installer
# ==============================================================================
# This script symlinks the configuration files from the dotfiles repository
# to their appropriate locations in the user's home directory.
#
# Safe for repeated runs: it checks if the link already exists and creates
# backups of any pre-existing configurations to prevent data loss.
#
# Usage:
#   ./script/install.sh
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

# Get the root directory of the dotfiles repository (parent of this script directory)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +'%Y%m%d_%H%M%S')"

info "Dotfiles root directory: ${BOLD}$DOTFILES_DIR${NC}"
info "Backup directory:   ${BOLD}$BACKUP_DIR${NC}"

# Function to safely symlink files or directories
# Usage: symlink_path <source_relative_path> <target_absolute_path>
symlink_path() {
    local rel_src="$1"
    local target="$2"
    local abs_src="$DOTFILES_DIR/$rel_src"

    # Verify source exists
    if [ ! -e "$abs_src" ]; then
        error "Source path $abs_src does not exist. Skipping."
        return 1
    fi

    # Create target parent directory if it doesn't exist
    local target_parent
    target_parent="$(dirname "$target")"
    if [ ! -d "$target_parent" ]; then
        info "Creating parent directory: $target_parent"
        mkdir -p "$target_parent"
    fi

    # Check if target already exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        # Check if it's already a symlink pointing to the correct location
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$abs_src" ]; then
            success "Already linked: $target -> $rel_src"
            return 0
        fi

        # Backup existing file/directory
        warn "Existing file/directory found at $target. Backing up to $BACKUP_DIR..."
        mkdir -p "$BACKUP_DIR"
        
        # Determine backup destination structure
        local backup_dest
        backup_dest="$BACKUP_DIR/$(basename "$target")"
        if [ -e "$backup_dest" ]; then
            # If name collision in backup, append unique suffix
            backup_dest="${backup_dest}_$(date +'%H%M%S')"
        fi
        
        mv "$target" "$backup_dest"
        info "Backed up to $backup_dest"
    fi

    # Create the symlink
    ln -s "$abs_src" "$target"
    success "Created link: $target -> $rel_src"
}

# Main linking logic
main() {
    # 1. Zsh configs
    info "Setting up Zsh configurations..."
    symlink_path "zsh/.zshrc" "$HOME/.zshrc"
    symlink_path "zsh/.p10k.zsh" "$HOME/.p10k.zsh"

    # 2. Fastfetch config
    info "Setting up Fastfetch configurations..."
    symlink_path "fastfetch" "$HOME/.config/fastfetch"

    # 3. Ghostty config
    info "Setting up Ghostty configurations..."
    symlink_path "ghostty" "$HOME/.config/ghostty"

    # 4. Neovim config
    info "Setting up Neovim configurations..."
    symlink_path "nvim" "$HOME/.config/nvim"

    # 5. Tmux config
    info "Setting up Tmux configurations..."
    symlink_path "tmux/.tmux.conf" "$HOME/.tmux.conf"

    # 6. Zed config
    info "Setting up Zed configurations..."
    symlink_path "zed/settings.json" "$HOME/.config/zed/settings.json"

    # 7. VS Code config (OS-dependent paths)
    info "Setting up VS Code configurations..."
    local vscode_target=""
    if [ "$(uname)" = "Darwin" ]; then
        vscode_target="$HOME/Library/Application Support/Code/User"
    elif [ "$(uname)" = "Linux" ]; then
        vscode_target="$HOME/.config/Code/User"
    fi

    if [ -n "$vscode_target" ]; then
        # Check if the folder contains settings files to link individually
        # to avoid replacing the entire User directory (which might contain state, databases, etc.)
        symlink_path "vscode/settings.json" "$vscode_target/settings.json"
        symlink_path "vscode/keybindings.json" "$vscode_target/keybindings.json"
        symlink_path "vscode/custom-vscode.css" "$vscode_target/custom-vscode.css"
    else
        warn "Could not determine VS Code settings path (unsupported OS: $(uname))"
    fi

    success "Symlinking complete!"
    if [ -d "$BACKUP_DIR" ]; then
        info "Any replaced files were backed up to: $BACKUP_DIR"
    fi
}

main "$@"
