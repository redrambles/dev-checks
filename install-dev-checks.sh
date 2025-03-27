#!/bin/bash

# Exit on error
set -e

# Check if curl is available
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required but not installed. Please install curl first."
    exit 1
fi

# Determine the user's home directory
USER_HOME="$HOME"
BIN_DIR="$USER_HOME/.local/bin"
SCRIPT_NAME="dev-checks"

echo "Installing dev-checks..."

# Create .local/bin if it doesn't exist
if [ ! -d "$BIN_DIR" ]; then
    echo "Creating $BIN_DIR directory..."
    mkdir -p "$BIN_DIR"
fi

# Copy the script
cat > "$BIN_DIR/$SCRIPT_NAME" << 'EOL'
#!/bin/bash

# Function to check if Homebrew is installed
check_brew() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is not installed. This script requires Homebrew to install and manage dependencies."
        echo -n "Would you like to install Homebrew now? [y/N] "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            echo "This script requires Homebrew to install tmux. Please install Homebrew and try again."
            exit 1
        fi
    fi
}

# Function to check if tmux is installed
check_tmux() {
    if ! command -v tmux >/dev/null 2>&1; then
        echo "tmux is not installed. Installing via Homebrew..."
        brew install tmux
    fi
}

# Function to check if jq is installed
check_jq() {
    if ! command -v jq >/dev/null 2>&1; then
        echo "jq is not installed. Installing via Homebrew..."
        brew install jq
    fi
}

# Check for required dependencies
check_brew
check_tmux
check_jq

# Function to check if tmux session exists
session_exists() {
    tmux has-session -t dev-checks 2>/dev/null
}

# Function to kill existing session
kill_session() {
    tmux kill-session -t dev-checks
}

# Function to check if a script exists in package.json
has_script() {
    local script=$1
    if ! jq -e ".scripts.\"$script\"" package.json >/dev/null 2>&1; then
        echo "Warning: '$script' script not found in package.json"
        return 1
    fi
    return 0
}

# Get the directory where the script was called from
LAUNCH_DIR="$(pwd)"

# Check if package.json exists
if [ ! -f "${LAUNCH_DIR}/package.json" ]; then
    echo "Error: No package.json found in current directory"
    exit 1
fi

# Check if this is a yarn project
if [ ! -f "${LAUNCH_DIR}/yarn.lock" ]; then
    echo "Error: This doesn't appear to be a yarn project (no yarn.lock found)"
    exit 1
fi

# Check for required scripts
MISSING_SCRIPTS=0
SCRIPTS=("type-check" "lint" "test:all" "knip")

for script in "${SCRIPTS[@]}"; do
    if ! has_script "$script"; then
        MISSING_SCRIPTS=1
    fi
done

if [ $MISSING_SCRIPTS -eq 1 ]; then
    echo -n "Some scripts are missing. Continue anyway? [y/N] "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# If session exists, kill it
if session_exists; then
    echo "Existing dev-checks session found. Killing it..."
    kill_session
fi

# Start a new tmux session (detached) with custom config
tmux new-session -d -s dev-checks

# Set tmux options for better visibility and navigation
tmux set -g pane-border-style 'fg=colour240,bold'
tmux set -g pane-active-border-style 'fg=yellow,bold'
tmux set -g pane-border-lines double
tmux set -g mouse on
tmux set -g pane-border-status off
tmux set -g synchronize-panes off

# Add Alt+arrow key bindings for pane navigation
tmux bind -n M-Left select-pane -L
tmux bind -n M-Right select-pane -R
tmux bind -n M-Up select-pane -U
tmux bind -n M-Down select-pane -D

# Split the window into four panes (using percentages for precise splits)
tmux split-window -h -p 50
tmux select-pane -t 0
tmux split-window -v -p 50
tmux select-pane -t 2
tmux split-window -v -p 50

# Send commands to each pane with labels
# Pane 0: type-check
tmux select-pane -t 0
tmux send-keys "echo '=== Type Check ===' && cd ${LAUNCH_DIR} && yarn type-check" C-m

# Pane 1: lint
tmux select-pane -t 1
tmux send-keys "echo '=== Lint ===' && cd ${LAUNCH_DIR} && yarn lint" C-m

# Pane 2: test:all
tmux select-pane -t 2
tmux send-keys "echo '=== Tests ===' && cd ${LAUNCH_DIR} && yarn test:all" C-m

# Pane 3: knip
tmux select-pane -t 3
tmux send-keys "echo '=== Knip ===' && cd ${LAUNCH_DIR} && yarn knip" C-m

# Print usage instructions
cat << 'EOF'

🔍 TMux Controls:
  • Mouse: Click to select panes or use scroll wheel (mouse mode is enabled)
  • Keyboard Navigation:
    - Quick pane switching: 
      o Alt + Arrow Keys (←↑↓→) to move between panes
      o Numbers 1-4 for direct pane selection (after Ctrl-b)
      o 'o' to cycle through panes (after Ctrl-b)
      o 'q' to show pane numbers briefly (after Ctrl-b)
    - To detach (leave session running): press Ctrl-b, then d
    - To quit completely: press Ctrl-b, then type :kill-session and press Enter
    - To zoom into a pane: press Ctrl-b, then z (press again to zoom out)
    - To scroll in a pane: press Ctrl-b, then [ (use arrow keys/PageUp/PageDown, press q to exit scroll mode)

Starting dev checks... Press Ctrl-b then ? at any time to see all tmux commands.

EOF

# Attach to the session
tmux attach-session -t dev-checks
EOL

# Make the script executable
chmod +x "$BIN_DIR/$SCRIPT_NAME"

# Check if PATH already includes .local/bin
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    # Add to .zshrc if it exists, otherwise .bashrc
    if [ -f "$USER_HOME/.zshrc" ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$USER_HOME/.zshrc"
        echo "Added $BIN_DIR to PATH in .zshrc"
        echo "Please run 'source ~/.zshrc' to update your current session"
    elif [ -f "$USER_HOME/.bashrc" ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$USER_HOME/.bashrc"
        echo "Added $BIN_DIR to PATH in .bashrc"
        echo "Please run 'source ~/.bashrc' to update your current session"
    else
        echo "Warning: Could not find .zshrc or .bashrc. Please manually add $BIN_DIR to your PATH"
    fi
fi

# Add success message with usage instructions
echo "✨ Installation complete! ✨"
echo
echo "To start using dev-checks:"
echo "1. Run: source ~/.zshrc (or open a new terminal)"
echo "2. Navigate to any yarn project"
echo "3. Run: dev-checks"
echo
echo "For help, run dev-checks and check the displayed instructions."

# Clean up the installer script if it was downloaded directly
if [ -f "$(pwd)/install-dev-checks.sh" ]; then
    rm "$(pwd)/install-dev-checks.sh"
    echo "✨ Cleaned up installer script"
fi 