#!/usr/bin/env bash
# Install the Hollow Knight Lithuanian translation mod.
#
#   ./install.sh [path-to-Hollow-Knight]
#
# The game folder is auto detected (Steam) when no path is given.
# Original files are backed up as <file>.orig the first time.

set -euo pipefail

GAME="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$GAME" ]; then
    GAME="$(ls -d "$HOME/.local/share/Steam/steamapps/common/Hollow Knight" 2>/dev/null || true)"
    if [ -z "$GAME" ]; then
        GAME="$(ls -d "$HOME/.steam/steam/steamapps/common/Hollow Knight" 2>/dev/null || true)"
    fi
fi

if [ -z "$GAME" ] || [ ! -d "$GAME/hollow_knight_Data" ]; then
    echo "Could not find the Hollow Knight installation."
    echo "Usage: $0 /path/to/Hollow Knight"
    exit 1
fi

DATA="$GAME/hollow_knight_Data"
SRC="$SCRIPT_DIR/files/hollow_knight_Data"

install_file() {
    local rel="$1"
    local dst="$DATA/$rel"
    local src="$SRC/$rel"
    mkdir -p "$(dirname "$dst")"
    if [ -f "$dst" ] && [ ! -f "$dst.orig" ]; then
        echo "  backing up $rel"
        cp -p "$dst" "$dst.orig"
    fi
    cp -f "$src" "$dst"
    echo "  installed $rel"
}

echo "Installing the Lithuanian translation into $GAME"
install_file "resources.assets"
install_file "sharedassets0.assets"
install_file "globalgamemanagers"
install_file "Managed/Assembly-CSharp.dll"

echo
echo "Done.  Start the game and pick 'Lietuvių' in Options -> Game Options -> Language."
