# Dev Checks

> ⚠️ **Note**: This tool is designed for macOS only. It uses Homebrew for package management and assumes a macOS environment.

A utility script that opens a tmux session with four panes running common development checks:

- Type checking
- Linting
- Tests
- Knip (unused exports)

## System Requirements

- macOS
- Terminal that supports tmux
- Yarn-based project with the following scripts in package.json:
  - `type-check`
  - `lint`
  - `test:all`
  - `knip`
- curl (usually pre-installed on macOS)

The script will automatically install other dependencies (Homebrew, tmux, jq) if they're missing.

## Installation

### Quick Install (Recommended)

```bash
curl -o- https://raw.githubusercontent.com/redrambles/dev-checks/main/install-dev-checks | bash
```

This will:

- Create `~/.local/bin` if it doesn't exist
- Download the script and make it executable
- Add `~/.local/bin` to your PATH (if not already there)
- Detect your shell and update the appropriate rc file
- Clean up the installation script automatically

### Manual Installation

If you prefer to install manually, you can download the script directly:

```bash
# Download the script
curl -o ~/.local/bin/dev-checks https://raw.githubusercontent.com/redrambles/dev-checks/main/dev-checks
# Make it executable
chmod +x ~/.local/bin/dev-checks
```

Make sure `~/.local/bin` is in your PATH. If it isn't, add this to your `~/.zshrc` or `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Alternatively, you can download and run the script from any directory you choose - just make sure that directory is in your PATH.

## Usage

```bash
dev-checks              # Run all checks once
dev-checks -h          # Show help information
dev-checks --help      # Same as above
```

## Features

### TMux Controls

- Mouse support enabled for pane selection and scrolling
- Keyboard Navigation:
  - Alt + Arrow Keys (←↑↓→) to move between panes
  - After pressing Ctrl-b:
    - Numbers 1-4 for direct pane selection
    - 'o' to cycle through panes
    - 'q' to show pane numbers briefly
    - 'z' to zoom into/out of pane
    - 'd' to detach (leave session running)
    - '[' to enter scroll mode (use arrow keys/PageUp/PageDown, 'q' to exit)
  - Type ':kill-session' after Ctrl-b to quit completely

### Other Features

- ✨ Automatic dependency installation
- 🔍 Project validation
- 📦 Double-width pane borders for better visibility
- 🖱️ Full mouse support
- ❓ Comprehensive help system

For more detailed information, run `dev-checks --help`

## Navigation

- **Mouse**: Click any pane to select it
- **Keyboard**:
  - Alt + Arrow keys to switch panes
  - Ctrl-b then:
    - z to zoom into a pane (press again to zoom out)
    - d to detach (leave session running)
    - [ to enter scroll mode (q to exit scroll mode)

## Troubleshooting

If you see "command not found":

1. Make sure you've either reloaded your shell or opened a new terminal window:

   ```bash
   # Option 1: Reload your current shell
   # For zsh users:
   source ~/.zshrc

   # For bash users:
   source ~/.bashrc

   # Option 2: Simply open a new terminal window
   ```

2. Check that ~/.local/bin is in your PATH: `echo $PATH`
