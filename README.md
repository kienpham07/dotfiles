# kienpham07's Dotfiles

A collection of configuration files (dotfiles) to customize and automate the setup of Zsh, Tmux, Neovim (LazyVim), Niri Window Manager, Noctalia Shell, Yazi, Vivaldi CSS Mod, VS Code, Zed Editor, Ghostty, Fastfetch, and more.

If you find this repository helpful, I’d appreciate it if you could give it a star! ⭐

---

## Project Structure

```text
.
├── LICENSE             # MIT License
├── README.md           # This documentation file
├── FedoraNiri-showcase-compressed.mp4 # Video showcase for Niri setup
├── fastfetch/          # Custom fastfetch system info configurations
│   ├── config.jsonc    # System information layout configurations
│   └── logo.txt        # Custom Fastfetch ASCII logo
├── ghostty/            # Ghostty terminal settings
│   ├── config          # Terminal font, style, and window config
│   └── shaders/        # Custom GLSL shaders (e.g. cursor smear)
├── kuro/               # Kuro splash screen settings
│   └── a2n.kuro/       # Look-and-feel package for custom splash screen
├── niri/               # Niri window manager configurations
│   ├── config.kdl      # Window layouts, keybindings, and startup apps
│   ├── noctalia.kdl    # Niri-specific settings for Noctalia
│   └── shaders/        # GLSL window animation shaders (e.g. inkwell drop)
├── noctalia/           # Noctalia widget and panel settings
│   ├── settings.json   # Layout, widgets, and panel configurations
│   └── plugins/        # Installed plugins (catwalk, clipper, model-usage, pomodoro, sticky-notes, usb-drive-manager)
├── nvim/               # Complete LazyVim setup
│   ├── init.lua        # Neovim entry point
│   ├── lazyvim.json    # Installed extras/plugins configuration
│   └── lua/            # Custom keymaps, options, and plugin settings
├── tmux/               # Tmux terminal multiplexer settings
│   └── .tmux.conf      # Prefix shortcuts, plugins, and styling
├── vivaldi-mods/       # Vivaldi browser customizations
│   └── customVivaldi.css # Custom CSS interface modifications
├── vscode/             # VS Code preferences & keybindings
│   ├── settings.json   # VS Code configuration preferences
│   ├── keybindings.json# Key mapping adjustments
│   ├── custom-vscode.css# Styling customizations
│   └── snippets/       # Custom code snippets
├── xdg-desktop-portal/ # Portal picker configuration
│   └── portals.conf    # Maps default portal handlers (termfilechooser)
├── xdg-desktop-portal-termfilechooser/ # Terminal file chooser settings
│   ├── config          # Window style, wrapper script and terminal cmd
│   └── yazi-wrapper.sh # Integrates yazi with termfilechooser
├── yazi/               # Yazi file manager configurations
│   ├── yazi.toml       # General behaviors and mime openers
│   ├── keymap.toml     # File manager navigation shortcuts
│   ├── theme.toml      # Custom icons and colors
│   └── flavors/        # Yazi UI theme flavors (noctalia.yazi)
├── zed/                # Zed editor configuration
│   └── settings.json   # Font size, icons, themes, and formatter configs
├── zoom/               # Zoom configurations
│   ├── zoom.conf       # Zoom initialization settings
│   └── zoomus.conf     # Zoom meeting, audio, and UI behavior
└── zsh/                # Shell customization configurations
    ├── .zshrc          # Primary shell startup configurations and aliases
    └── .p10k.zsh       # Powerlevel10k theme prompt configurations
```

---

## Video showcase for Niri setup

<video src="FedoraNiri-showcase-compressed.mp4" controls width="100%"></video>

https://github.com/user-attachments/assets/a9242492-98f3-4611-8a80-7c7b6988dce7

---

## License

This project is licensed under the [MIT License](file:///home/kienpham07/Downloads/Disk%20D%20Window/dotfiles/LICENSE).
