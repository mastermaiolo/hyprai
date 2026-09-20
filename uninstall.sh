#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════
# Hypr.AI · Desinstalador
# Remoção simétrica e segura: limpa ficheiros, atalhos, regras e tema,
# preservando a curadoria do utilizador e criando backups prévios.
# ══════════════════════════════════════════════════════════════════════
set -euo pipefail

DEST="$HOME/.config/hypr/hyprai"
BIN_TARGET="$HOME/.local/bin/hyprai"
BINDS_FILE="$HOME/.config/hypr/config/binds.lua"
WINDOWRULES_FILE="$HOME/.config/hypr/config/windowrules.lua"
NOCTALIA_CONF="$HOME/.config/noctalia/config.toml"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hyprai"
BACKUP_DATE="$(date +%Y%m%d%H%M%S)"

echo "── Desinstalando Hypr.AI ──"

backup_file() {
    local f="$1"
    if [[ -f "$f" ]]; then
        local bkp="$f.hyprai-backup-$BACKUP_DATE"
        cp -a "$f" "$bkp"
        echo "→ Backup criado: $bkp"
    fi
}

# 1. Preservação de curadoria (sites.conf, tools.conf)
preserve_curation=1
if [[ -f "$DEST/config/sites.conf" || -f "$DEST/config/tools.conf" ]]; then
    if [[ -t 0 ]]; then
        read -r -p "Apagar também a tua curadoria (sites.conf, tools.conf)? [s/N] " cur_ans || true
        case "$cur_ans" in
            [sSyY]*) preserve_curation=0 ;;
            *)       preserve_curation=1 ;;
        esac
    fi
    if [[ "$preserve_curation" -eq 1 ]]; then
        CURATION_BACKUP="$HOME/.config/hypr/hyprai-backup-$BACKUP_DATE"
        mkdir -p "$CURATION_BACKUP"
        [[ -f "$DEST/config/sites.conf" ]] && cp -a "$DEST/config/sites.conf" "$CURATION_BACKUP/"
        [[ -f "$DEST/config/tools.conf" ]] && cp -a "$DEST/config/tools.conf" "$CURATION_BACKUP/"
        echo "→ Curadoria preservada em: $CURATION_BACKUP"
    fi
fi

# 2. Remoção de directórios e binário
rm -rf "$DEST" "$STATE_DIR"
rm -f "$BIN_TARGET"

# 3. Limpeza estrutural no Noctalia (config.toml)
if [[ -f "$NOCTALIA_CONF" ]] && grep -q "theme.templates.user.hyprai" "$NOCTALIA_CONF" 2>/dev/null; then
    backup_file "$NOCTALIA_CONF"
    tmp_noc="$(mktemp)"
    awk '
      /^[[:space:]]*\[theme\.templates\.user\.hyprai\][[:space:]]*$/ { skip=1; next }
      skip && /^[[:space:]]*\[/ { skip=0 }
      !skip
    ' "$NOCTALIA_CONF" > "$tmp_noc" && mv "$tmp_noc" "$NOCTALIA_CONF"
    echo "✓ Bloco removido de $NOCTALIA_CONF"
fi

# 4. Limpeza em binds.lua (apaga só linhas que apontem ao binário)
if [[ -f "$BINDS_FILE" ]] && grep -q "\.local/bin/hyprai" "$BINDS_FILE" 2>/dev/null; then
    backup_file "$BINDS_FILE"
    sed -i '\|\.local/bin/hyprai|d' "$BINDS_FILE"
    echo "✓ Atalho removido de $BINDS_FILE"
fi

# 5. Limpeza da layer rule em windowrules.lua
if [[ -f "$WINDOWRULES_FILE" ]] && grep -qE 'name[[:space:]]*=[[:space:]]*"hyprai"' "$WINDOWRULES_FILE" 2>/dev/null; then
    backup_file "$WINDOWRULES_FILE"
    tmp_wr="$(mktemp)"
    awk '
    BEGIN { in_hyprai=0; in_single=0 }
    /^[[:space:]]*--[[:space:]]*Hypr\.AI layer rule/ { in_hyprai=1; next }
    in_hyprai {
        if ($0 ~ /\}\)[[:space:]]*$/) { in_hyprai=0; next }
        next
    }
    /hl\.layer_rule\([[:space:]]*\{[[:space:]]*name[[:space:]]*=[[:space:]]*"hyprai"/ {
        if ($0 ~ /\}\)[[:space:]]*$/) { next }
        in_single=1
        next
    }
    in_single {
        if ($0 ~ /\}\)[[:space:]]*$/) { in_single=0; next }
        next
    }
    { print }
    ' "$WINDOWRULES_FILE" > "$tmp_wr" && mv "$tmp_wr" "$WINDOWRULES_FILE"
    echo "✓ Regra de camada removida de $WINDOWRULES_FILE"
fi

# 6. Recarrega o Hyprland se em execução
if command -v hyprctl &>/dev/null && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    hyprctl reload >/dev/null 2>&1 || true
    echo "✓ Hyprland recarregado com sucesso"
fi

echo "✓ Hypr.AI desinstalado com sucesso."
