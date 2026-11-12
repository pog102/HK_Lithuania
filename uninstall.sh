#!/usr/bin/env bash
# Remove the Hollow Knight Lithuanian translation mod (restores the backed up files).
#
#   ./uninstall.sh [path-to-Hollow-Knight]

set -euo pipefail

GAME="${1:-}"
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

restore_file() {
    local rel="$1"
    local dst="$DATA/$rel"
    if [ -f "$dst.orig" ]; then
        mv -f "$dst.orig" "$dst"
        echo "  restored $rel"
    elif [ -f "$dst" ]; then
        echo "  no backup for $rel, leaving it alone"
    fi
}

echo "Removing the Lithuanian translation from $GAME"
restore_file "resources.assets"
restore_file "sharedassets0.assets"
restore_file "globalgamemanagers"
restore_file "Managed/Assembly-CSharp.dll"

echo "Done."
