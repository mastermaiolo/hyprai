#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════
# Hypr.AI · Desinstalador
# Remove ~/.config/hypr/hyprai, binário e o atalho em binds.lua
# ══════════════════════════════════════════════════════════════════════
set -euo pipefail

DEST="$HOME/.config/hypr/hyprai"
BIN_TARGET="$HOME/.local/bin/hyprai"
BINDS_FILE="$HOME/.config/hypr/config/binds.lua"
NOCTALIA_CONF="$HOME/.config/noctalia/config.toml"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hyprai"

echo "── Desinstalando Hypr.AI ──"

rm -rf "$DEST" "$STATE_DIR"
rm -f "$BIN_TARGET"

if [[ -f "$BINDS_FILE" ]]; then
    sed -i '/hyprai/d' "$BINDS_FILE"
fi

if [[ -f "$NOCTALIA_CONF" ]]; then
    sed -i '/\[theme\.templates\.user\.hyprai\]/,/^\s*output_path = .*noctalia-colors\.rasi"$/d' "$NOCTALIA_CONF"
fi

if command -v hyprctl &>/dev/null && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    hyprctl reload >/dev/null 2>&1 || true
fi

echo "✓ Hypr.AI desinstalado com sucesso."
