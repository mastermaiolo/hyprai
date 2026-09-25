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

# Escreve por cima do conteúdo em vez de mv/sed -i: um arquivo que seja
# symlink (stow, repositório de dotfiles) continua symlink.
write_through() {   # $1=arquivo  stdin=conteúdo novo
    local tmp; tmp="$(mktemp)"
    cat > "$tmp" && cat "$tmp" > "$1"
    rm -f "$tmp"
}

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
    awk '
      /^[[:space:]]*\[theme\.templates\.user\.hyprai\][[:space:]]*$/ { skip=1; next }
      skip && /^[[:space:]]*\[/ { skip=0 }
      !skip
    ' "$NOCTALIA_CONF" | write_through "$NOCTALIA_CONF"
    echo "✓ Bloco removido de $NOCTALIA_CONF"
fi

# 4. Limpeza do atalho — nos mesmos dois arquivos onde o install.sh o põe.
# Tira o bloco entre "-- hyprai:begin/end" (e a linha em branco que o
# instalador pôs antes dele) e, para instalações antigas sem marcadores,
# só linhas hl.bind(...) que chamem o binário — não qualquer menção a ele.
for f in "$BINDS_FILE" "$HOME/.config/hypr/hyprland.lua"; do
    [[ -f "$f" ]] || continue
    grep -qE 'hyprai:begin|hl\.bind\(.*\.local/bin/hyprai' "$f" || continue
    backup_file "$f"
    awk '
        /^[[:space:]]*-- hyprai:begin[[:space:]]*$/ { blank = 0; skip = 1; next }
        skip { if ($0 ~ /^[[:space:]]*-- hyprai:end[[:space:]]*$/) skip = 0; next }
        /^[[:space:]]*hl\.bind\(.*\.local\/bin\/hyprai/ { next }
        /^[[:space:]]*$/ { if (blank) print ""; blank = 1; next }
        { if (blank) print ""; blank = 0; print }
        END { if (blank) print "" }
    ' "$f" | write_through "$f"
    echo "✓ Atalho removido de $f"
done

# 5. Limpeza da layer rule em windowrules.lua
if [[ -f "$WINDOWRULES_FILE" ]] && grep -qE 'name[[:space:]]*=[[:space:]]*"hyprai"' "$WINDOWRULES_FILE" 2>/dev/null; then
    backup_file "$WINDOWRULES_FILE"
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
    ' "$WINDOWRULES_FILE" | write_through "$WINDOWRULES_FILE"
    echo "✓ Regra de camada removida de $WINDOWRULES_FILE"
fi

# 6. Recarrega o Hyprland se em execução
if command -v hyprctl &>/dev/null && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    hyprctl reload >/dev/null 2>&1 || true
    echo "✓ Hyprland recarregado com sucesso"
fi

echo "✓ Hypr.AI desinstalado com sucesso."
