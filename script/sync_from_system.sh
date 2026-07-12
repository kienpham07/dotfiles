#!/usr/bin/env bash

# ==============================================================================
# sync_from_system.sh - Dotfiles Sync Script (System -> Dotfiles Repository)
# ==============================================================================
# This script copies the current configurations from your local system into the
# dotfiles repository so they can be saved, committed, and pushed.
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

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
info "Dotfiles repository directory: ${BOLD}$DOTFILES_DIR${NC}"

# Function to safely copy a folder
# Usage: sync_folder <source_absolute_path> <destination_relative_path>
sync_folder() {
    local src="$1"
    local dest_rel="$2"
    local dest="$DOTFILES_DIR/$dest_rel"

    if [ ! -d "$src" ]; then
        warn "Source directory $src does not exist. Skipping."
        return 1
    fi

    info "Syncing directory: $src -> $dest_rel"
    mkdir -p "$(dirname "$dest")"
    
    # Clean old destination folder in repository if it exists
    if [ -d "$dest" ]; then
        rm -rf "$dest"
    fi
    
    cp -r "$src" "$dest"
    success "Synced directory: $dest_rel"
}

# Function to safely copy a file
# Usage: sync_file <source_absolute_path> <destination_relative_path>
sync_file() {
    local src="$1"
    local dest_rel="$2"
    local dest="$DOTFILES_DIR/$dest_rel"

    if [ ! -f "$src" ]; then
        warn "Source file $src does not exist. Skipping."
        return 1
    fi

    info "Syncing file: $src -> $dest_rel"
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    success "Synced file: $dest_rel"
}

# Main syncing logic
main() {
    # 1. Fastfetch config
    sync_folder "$HOME/.config/fastfetch" "fastfetch"

    # 2. Ghostty config
    sync_folder "$HOME/.config/ghostty" "ghostty"

    # 3. Tmux config
    sync_file "$HOME/.tmux.conf" "tmux/.tmux.conf"

    # 4. VS Code config
    local vscode_src=""
    if [ "$(uname)" = "Darwin" ]; then
        vscode_src="$HOME/Library/Application Support/Code/User"
    elif [ "$(uname)" = "Linux" ]; then
        vscode_src="$HOME/.config/Code/User"
    fi

    if [ -d "$vscode_src" ]; then
        info "Syncing VS Code settings..."
        sync_file "$vscode_src/settings.json" "vscode/settings.json"
        sync_file "$vscode_src/keybindings.json" "vscode/keybindings.json"
        sync_file "$vscode_src/custom-vscode.css" "vscode/custom-vscode.css"
        if [ -d "$vscode_src/snippets" ]; then
            sync_folder "$vscode_src/snippets" "vscode/snippets"
        fi
    else
        warn "VS Code config directory not found."
    fi

    # 5. Zsh config
    sync_file "$HOME/.zshrc" "zsh/.zshrc"
    sync_file "$HOME/.p10k.zsh" "zsh/.p10k.zsh"

    # 6. Yazi config
    sync_folder "$HOME/.config/yazi" "yazi"

    # 7. Niri, Noctalia, Kuro
    sync_folder "$HOME/.config/niri" "niri"
    sync_folder "$HOME/.config/noctalia" "noctalia"
    sync_folder "$HOME/.local/share/plasma/look-and-feel/a2n.kuro" "kuro/a2n.kuro"

    # 8. Portal File Picker
    sync_file "$HOME/.config/xdg-desktop-portal/portals.conf" "xdg-desktop-portal/portals.conf"
    sync_folder "$HOME/.config/xdg-desktop-portal-termfilechooser" "xdg-desktop-portal-termfilechooser"

    # 9. Zoom config
    sync_file "$HOME/.config/zoom.conf" "zoom/zoom.conf"
    sync_file "$HOME/.config/zoomus.conf" "zoom/zoomus.conf"

    # 10. Neovim config
    # Exclude .git and backup files when copying nvim
    if [ -d "$HOME/.config/nvim" ]; then
        info "Syncing Neovim config (excluding binary/cache/temp)..."
        local nvim_dest="$DOTFILES_DIR/nvim"
        mkdir -p "$nvim_dest"
        # Use rsync if available, else copy and delete unwanted files
        if command -v rsync &>/dev/null; then
            rsync -av --delete --exclude='.git' --exclude='node_modules' --exclude='.replit' "$HOME/.config/nvim/" "$nvim_dest/"
        else
            rm -rf "$nvim_dest"
            cp -r "$HOME/.config/nvim" "$nvim_dest"
            rm -rf "$nvim_dest/.git"
        fi
        success "Synced Neovim config"
    else
        warn "Neovim config directory not found."
    fi

    success "Sync from system completed! Run 'git status' in $DOTFILES_DIR to see the changes."
}

main "$@"
