#!/usr/bin/env bash
set -euo pipefail

# FORGE CLI installer — symlinks bin/forge to ~/.local/bin

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORGE_BIN="$SCRIPT_DIR/bin/forge"
INSTALL_DIR="$HOME/.local/bin"

if [ ! -f "$FORGE_BIN" ]; then
    echo "Error: bin/forge not found at $SCRIPT_DIR"
    exit 1
fi

mkdir -p "$INSTALL_DIR"

# Symlink
if [ -L "$INSTALL_DIR/forge" ] || [ -f "$INSTALL_DIR/forge" ]; then
    rm "$INSTALL_DIR/forge"
fi
ln -s "$FORGE_BIN" "$INSTALL_DIR/forge"
echo "Linked: $INSTALL_DIR/forge -> $FORGE_BIN"

# PATH check
if ! echo "$PATH" | tr ':' '\n' | grep -q "$INSTALL_DIR"; then
    SHELL_RC=""
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_RC="$HOME/.bashrc"
    fi

    if [ -n "$SHELL_RC" ]; then
        echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
        echo "Added $INSTALL_DIR to PATH in $SHELL_RC"
        echo "Run: source $SHELL_RC"
    else
        echo "Add to your shell profile: export PATH=\"$INSTALL_DIR:\$PATH\""
    fi
fi

echo ""
echo "Installed. Run: forge --version"
