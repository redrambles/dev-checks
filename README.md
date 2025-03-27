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
- Yarn-based project
- curl (usually pre-installed on macOS)

The script will automatically install other dependencies (Homebrew, tmux, jq) if they're missing.

## Quick Install

```bash
curl -o- https://raw.githubusercontent.com/redrambles/dev-checks/main/install-dev-checks.sh | bash
```

This will install the `dev-checks` command to `~/.local/bin`. The installer script is downloaded, executed, and automatically cleaned up.

## Features

- 🖥️ Split terminal with 4 panes running different checks
- 🖱️ Mouse support for pane selection and scrolling
- ⌨️ Keyboard shortcuts (Alt + Arrow keys) for navigation
- 🎨 Clear visual indicators with yellow borders for active pane
- 🔄 Automatic session management
- ✨ Project validation (yarn, required scripts)
- 📦 Automatic dependency installation (Homebrew, tmux)

## Usage

After installation:

1. Navigate to any yarn project
2. Run `dev-checks`

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

1. Make sure you've reloaded your shell: `source ~/.zshrc`
2. Check that ~/.local/bin is in your PATH: `echo $PATH`

## Manual Installation

If you prefer to install manually:

1. Download the installer:
   ```bash
   curl -O https://raw.githubusercontent.com/redrambles/dev-checks/main/install-dev-checks.sh
   ```
2. Make it executable:
   ```bash
   chmod +x install-dev-checks.sh
   ```
3. Run it:
   ```bash
   ./install-dev-checks.sh
   ```
4. The installer will clean up after itself, but if it doesn't (e.g. if it was interrupted), you can remove it:
   ```bash
   rm install-dev-checks.sh
   ```
