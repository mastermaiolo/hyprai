#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════
# Hypr.AI · Instalador
# Menu de atalhos e portais de IA para Hyprland / Rofi
# ══════════════════════════════════════════════════════════════════════
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.config/hypr/hyprai"
BIN_DIR="$HOME/.local/bin"
BIN_TARGET="$BIN_DIR/hyprai"
BINDS_FILE="$HOME/.config/hypr/config/binds.lua"

# ── i18n: pt / en ──
case "${LC_ALL:-${LC_MESSAGES:-${LANG:-pt_BR}}}" in
    pt*) L=pt ;;
    *)   L=en ;;
esac

declare -A T=(
    [pt:title]="── Hypr.AI · Instalador ──"                          [en:title]="── Hypr.AI · Installer ──"
    [pt:installing]="Instalando arquivos em %s..."                  [en:installing]="Installing files to %s..."
    [pt:installed_ok]="✓ Arquivos instalados em %s"                 [en:installed_ok]="✓ Files installed to %s"
    [pt:bin_ok]="✓ Link simbólico criado em %s"                     [en:bin_ok]="✓ Symlink created at %s"
    [pt:bind_found]="✓ Atalho já configurado em %s"                 [en:bind_found]="✓ Keybind already configured in %s"
    [pt:bind_add]="Adicionando o atalho %s a %s..."                 [en:bind_add]="Adding the %s keybind to %s..."
    [pt:bind_ok]="✓ Atalho %s adicionado com sucesso"               [en:bind_ok]="✓ %s keybind added successfully"
    [pt:bind_conflict]="⚠ %s já está atribuído a outra coisa."      [en:bind_conflict]="⚠ %s is already bound to something else."
    [pt:bind_prompt]="  Outra tecla (uma letra ou número; Enter para não criar atalho): " \
    [en:bind_prompt]="  Another key (one letter or digit; Enter to skip the keybind): "
    [pt:bind_invalid]="  Tecla inválida — use uma letra ou um número." \
    [en:bind_invalid]="  Invalid key — use one letter or digit."
    [pt:bind_skip]="→ Atalho não criado, para não duplicar uma tecla já em uso. Escolha uma livre e adicione à mão:" \
    [en:bind_skip]="→ Keybind not created, so as not to duplicate a key already in use. Pick a free one and add by hand:"
    [pt:bind_nofile]="→ Nem binds.lua nem hyprland.lua encontrados. Adicione o atalho à sua config do Hyprland:" \
    [en:bind_nofile]="→ Neither binds.lua nor hyprland.lua found. Add the keybind to your Hyprland config:"
    [pt:bind_manual]="→ Não consegui inserir o atalho em %s. Adicione à mão:" \
    [en:bind_manual]="→ Couldn't insert the keybind into %s. Add it by hand:"
    [pt:reloaded]="✓ Hyprland recarregado com sucesso"              [en:reloaded]="✓ Hyprland reloaded successfully"
    [pt:noctalia_ok]="✓ Ponte de cor tonal registrada no Noctalia"  [en:noctalia_ok]="✓ Tonal color bridge registered with Noctalia"
    [pt:noctalia_found]="✓ Ponte de cor tonal já registrada no Noctalia" [en:noctalia_found]="✓ Tonal color bridge already registered with Noctalia"
    [pt:layerrule_found]="✓ Exceção de vidro já configurada em windowrules.lua" \
    [en:layerrule_found]="✓ Glass exception already configured in windowrules.lua"
    [pt:layerrule_xray_warn]="⚠ A regra de vidro em windowrules.lua tem 'xray = true' — troque para 'xray = false'. Com xray, o blur salta a camada do wallpaper e o vidro desaparece (o wallpaper atravessa nítido)." \
    [en:layerrule_xray_warn]="⚠ The glass rule in windowrules.lua has 'xray = true' — change it to 'xray = false'. With xray on, the blur skips the wallpaper layer and the glass disappears (the sharp wallpaper shows straight through)."
    [pt:layerrule_ask]="Camadas layer-shell não recebem blur no Hyprland sem uma regra explícita — sem isto o menu fica opaco em vez de translúcido. Adicionar uma exceção para o namespace 'rofi' em windowrules.lua (blur + ignore_alpha, sem xray)? Não mexe no blur global. [s/N] " \
    [en:layerrule_ask]="Layer-shell surfaces get no blur in Hyprland without an explicit rule — without this the menu ends up opaque instead of translucent. Add an exception for the 'rofi' namespace in windowrules.lua (blur + ignore_alpha, no xray)? It never touches your global blur. [y/N] "
    [pt:layerrule_ok]="✓ Exceção de vidro adicionada a windowrules.lua"    [en:layerrule_ok]="✓ Glass exception added to windowrules.lua"
    [pt:layerrule_skip]="→ Sem exceção — o menu usa o blur global, tal como está"  [en:layerrule_skip]="→ No exception — the menu uses the global blur as-is"
    [pt:layerrule_manual]="windowrules.lua não encontrado — adicione manualmente à sua config Lua do Hyprland:" \
    [en:layerrule_manual]="windowrules.lua not found — add this to your Hyprland Lua config by hand:"
    [pt:layerrule_noninteractive]="Instalação não interativa — para ativar a exceção de vidro, adicione isto a windowrules.lua:" \
    [en:layerrule_noninteractive]="Non-interactive install — to enable the glass exception, add this to windowrules.lua:"
    [pt:dep_missing_rofi]="✗ Erro: 'rofi' não foi encontrado no PATH. O Hypr.AI necessita do Rofi para funcionar." \
    [en:dep_missing_rofi]="✗ Error: 'rofi' was not found in PATH. Hypr.AI requires Rofi to run." \
    [pt:dep_warn_cli]="⚠ Aviso: '%s' não encontrado. Os agentes CLI necessitam de fish e kitty para funcionar." \
    [en:dep_warn_cli]="⚠ Warning: '%s' not found. CLI agents require fish and kitty to run." \
    [pt:dep_note_notify]="→ Nota: 'notify-send' não encontrado (opcional, usado para notificações)." \
    [en:dep_note_notify]="→ Note: 'notify-send' not found (optional, used for notifications)." \
    [pt:finished_key]="── Concluído! Pressione Super+%s ou execute 'hyprai' no terminal ──" \
    [en:finished_key]="── Done! Press Super+%s or run 'hyprai' in terminal ──" \
    [pt:finished]="── Concluído! Execute 'hyprai' no terminal ──" \
    [en:finished]="── Done! Run 'hyprai' in terminal ──"
)
# shellcheck disable=SC2059  # o formato É a tradução (leva %s)
t() { printf -- "${T[$L:$1]:-${T[pt:$1]:-$1}}" "${@:2}"; }
say() { t "$@"; echo; }

say title

# 0. Verificação de dependências
if ! command -v rofi &>/dev/null; then
    say dep_missing_rofi >&2
    exit 1
fi

missing_cli=()
for dep in fish kitty; do
    if ! command -v "$dep" &>/dev/null; then
        missing_cli+=("$dep")
    fi
done
if [[ "${#missing_cli[@]}" -gt 0 ]]; then
    say dep_warn_cli "${missing_cli[*]}"
fi

if ! command -v notify-send &>/dev/null; then
    say dep_note_notify
fi

# 1. Cria diretório de destino
mkdir -p "$DEST"/{config,rofi,ui,theme,svg} "$BIN_DIR"

# 2. Copia arquivos de tema e launcher (preserva sites.conf existente se já houver)
cp -f "$SRC/rofi/hyprai.rasi" "$DEST/rofi/"
cp -f "$SRC/ui/launcher.sh" "$DEST/ui/"
cp -f "$SRC/theme/noctalia.rasi.tmpl" "$DEST/theme/"
chmod +x "$DEST/ui/launcher.sh"
cp -f "$SRC/"*.md "$DEST/" 2>/dev/null || true
# *.svg cobria só SVG — um ícone PNG (ex.: extraído de ~/.local/share/icons)
# ficava pra trás da cópia e o item caía silenciosamente no fallback de
# emoji, sem erro nenhum pra avisar.
for ext in svg png; do
    cp -f "$SRC/svg/"*."$ext" "$DEST/svg/" 2>/dev/null || true
done

if [[ ! -f "$DEST/config/sites.conf" ]]; then
    cp "$SRC/config/sites.conf" "$DEST/config/"
fi
if [[ ! -f "$DEST/config/tools.conf" ]]; then
    cp "$SRC/config/tools.conf" "$DEST/config/"
fi

say installed_ok "$DEST"

# 3. Estado para a ponte de cor tonal (Noctalia grava aqui em runtime)
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hyprai"
mkdir -p "$STATE_DIR"

# 4. Registra o template de cor tonal no Noctalia, se instalado
NOCTALIA_CONF="$HOME/.config/noctalia/config.toml"
if [[ -f "$NOCTALIA_CONF" ]]; then
    if grep -q "theme.templates.user.hyprai" "$NOCTALIA_CONF" 2>/dev/null; then
        say noctalia_found
    else
        cat >> "$NOCTALIA_CONF" <<EOF

    [theme.templates.user.hyprai]
    input_path = "$DEST/theme/noctalia.rasi.tmpl"
    output_path = "$STATE_DIR/noctalia-colors.rasi"
EOF
        say noctalia_ok
    fi
fi

# 5. Cria link simbólico em ~/.local/bin/hyprai
ln -sf "$DEST/ui/launcher.sh" "$BIN_TARGET"
chmod +x "$BIN_TARGET"
say bin_ok "$BIN_TARGET"

# 6. Configuração de atalho
#
# O bloco vai entre marcadores "-- hyprai:begin/end", para o uninstall.sh
# tirar só o que o instalador pôs. Antes de injectar, confirma se a combinação
# já está ocupada — senão criava-se um conflito silencioso, com duas acções na
# mesma tecla e nenhum aviso. modmask 64 = SUPER.
bind_taken() {   # $1=modmask  $2=tecla → 0 se já existir um bind nessa combinação
    command -v hyprctl &>/dev/null || return 1
    hyprctl -j binds 2>/dev/null | awk -v want_mod="$1" -v want_key="$2" '
        /"modmask":/ { m = $0; gsub(/[^0-9]/, "", m); mod = m }
        /"key":/ {
            k = $0; sub(/.*"key": *"/, "", k); sub(/".*/, "", k)
            if (mod == want_mod && tolower(k) == tolower(want_key)) found = 1
        }
        END { exit !found }
    '
}

# Linha do bind. mainMod/launchPrefix só se o arquivo os definir — são
# convenção de alguns dotfiles, não do Hyprland; numa config sem eles, a
# linha antiga dava "attempt to concatenate a nil value" e o Lua inteiro
# deixava de carregar. Sem launchPrefix não se perde nada: o launcher já
# abre cada ferramenta via uwsm quando há sessão uwsm.
bind_line() {   # $1=tecla  $2=arquivo alvo (pode não existir)
    local mod='"SUPER + '"$1"'"' cmd='os.getenv("HOME") .. "/.local/bin/hyprai"'
    if [[ -f "$2" ]]; then
        grep -qE '^[[:space:]]*(local[[:space:]]+)?mainMod[[:space:]]*=' "$2" \
            && mod='mainMod .. " + '"$1"'"'
        grep -qE '^[[:space:]]*(local[[:space:]]+)?launchPrefix[[:space:]]*=' "$2" \
            && cmd="launchPrefix .. $cmd"
    fi
    printf 'hl.bind(%s, hl.dsp.exec_cmd(%s))' "$mod" "$cmd"
}

# Escreve por cima do conteúdo em vez de mv/sed -i: um binds.lua que seja
# symlink (stow, repositório de dotfiles) continua symlink, e a mudança cai
# no arquivo real em vez de o substituir por uma cópia solta.
write_through() {   # $1=arquivo  stdin=conteúdo novo
    local tmp; tmp="$(mktemp)"
    cat > "$tmp" && cat "$tmp" > "$1"
    rm -f "$tmp"
}

# binds.lua dedicado (layout config/*.lua) ou, na falta dele, o hyprland.lua.
BINDS_TARGET=""
for f in "$BINDS_FILE" "$HOME/.config/hypr/hyprland.lua"; do
    [[ -f "$f" ]] && { BINDS_TARGET="$f"; break; }
done

MENU_KEY="I"
BIND_ADDED=0
if [[ -n "$BINDS_TARGET" ]] && grep -qE 'hyprai:begin|hl\.bind\(.*\.local/bin/hyprai' "$BINDS_TARGET"; then
    # Procura o bind em si, não a palavra "hyprai" — um comentário a citar o
    # projeto dava o atalho por configurado sem ele existir.
    say bind_found "$BINDS_TARGET"
    MENU_KEY="$(grep -E 'hl\.bind\(.*\.local/bin/hyprai' "$BINDS_TARGET" | head -1 \
                | sed -n 's/.*+ *\([[:alnum:]]\)".*/\1/p')"
    BIND_ADDED=1
else
    # Conflito só é verificável dentro de uma sessão Hyprland a correr.
    # Com terminal, pergunta até ter uma tecla livre (verificando cada uma);
    # sem terminal, não cria o atalho — duplicar em silêncio é pior que não ter.
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        while bind_taken 64 "$MENU_KEY"; do
            say bind_conflict "SUPER + $MENU_KEY"
            MENU_KEY="" NEW_KEY=""
            while [[ -t 0 ]]; do
                printf '%s' "$(t bind_prompt)"
                read -r NEW_KEY || NEW_KEY=""
                [[ -z "$NEW_KEY" || "$NEW_KEY" =~ ^[[:alnum:]]$ ]] && break
                say bind_invalid
            done
            [[ -z "$NEW_KEY" ]] && break
            MENU_KEY="${NEW_KEY^^}"
        done
    fi

    if [[ -z "$MENU_KEY" ]]; then
        say bind_skip
        printf '  %s\n' "$(bind_line I "$BINDS_TARGET")"
    elif [[ -z "$BINDS_TARGET" ]]; then
        say bind_nofile
        printf '  %s\n' "$(bind_line "$MENU_KEY" "")"
    else
        BIND_LINE="$(bind_line "$MENU_KEY" "$BINDS_TARGET")"
        say bind_add "SUPER + $MENU_KEY" "$BINDS_TARGET"
        bind_bkp="$BINDS_TARGET.hyprai-backup-$(date +%Y%m%d%H%M%S)"
        cp -a "$BINDS_TARGET" "$bind_bkp"
        echo "→ Backup: $bind_bkp"

        # No fim do arquivo — ou antes de um "return" final, onde nada depois
        # dele correria (e um Lua com código após o return nem compila).
        awk -v line="$BIND_LINE" '
            { buf[++n] = $0 }
            END {
                last = n; while (last > 0 && buf[last] ~ /^[[:space:]]*$/) last--
                at = (last > 0 && buf[last] ~ /^[[:space:]]*return([[:space:]]|$)/) ? last : n + 1
                for (i = 1; i <= n + 1; i++) {
                    if (i == at) { print ""; print "-- hyprai:begin"; print line; print "-- hyprai:end" }
                    if (i <= n) print buf[i]
                }
            }
        ' "$BINDS_TARGET" | write_through "$BINDS_TARGET"

        if grep -qF -- "-- hyprai:begin" "$BINDS_TARGET"; then
            say bind_ok "SUPER + $MENU_KEY"
            BIND_ADDED=1
        else
            say bind_manual "$BINDS_TARGET"
            printf '  %s\n' "$BIND_LINE"
        fi
    fi
fi

# 6.5. Exceção de vidro no Hyprland (windowrules.lua) — opcional, com consentimento
#
# O blur global (decoration.blur.vibrancy/contrast/brightness em decorations.lua)
# passa por cima de QUALQUER janela/layer que não tenha o tratamento oposto — e
# é isso que faz o vidro do menu ficar opaco/sem cor no ecrã real mesmo quando
# rofi/hyprai.rasi e o screenshot parecem corretos (screenshot não passa pelo
# blur do compositor da mesma forma que o scanout real). A mesma regra já existe
# para os painéis do Noctalia (ver o layer_rule "noctalia" no mesmo arquivo);
# esta só estende o mesmo tratamento ao namespace "rofi", nunca ao blur global.
WINDOWRULES_FILE="$HOME/.config/hypr/config/windowrules.lua"
# Versão numa linha da regra abaixo, para os casos em que o instalador não a
# escreve sozinho — mesma sintaxe Lua do resto da config, não o hyprland.conf antigo.
LAYER_RULE_LINE='hl.layer_rule({ name = "hyprai", match = { namespace = "^rofi$" }, no_anim = true, ignore_alpha = 0.2, blur = true, blur_popups = true, xray = false })'
if [[ -f "$WINDOWRULES_FILE" ]]; then
    if grep -q 'namespace = "\^rofi\$"' "$WINDOWRULES_FILE" 2>/dev/null; then
        # A regra existe — mas versões anteriores (e a regra do Noctalia, de
        # onde esta foi copiada) traziam xray = true, que mata o vidro em
        # desktops onde o wallpaper é uma camada. Avisa em vez de dar por
        # configurado e deixar o bug de pé.
        if awk '/namespace = "\^rofi\$"/,/\}\)/' "$WINDOWRULES_FILE" \
             | grep -qE 'xray[[:space:]]*=[[:space:]]*true'; then
            say layerrule_xray_warn
        else
            say layerrule_found
        fi
    elif [[ -t 0 ]]; then
        read -r -p "$(t layerrule_ask)" LAYERRULE_ANS
        case "$LAYERRULE_ANS" in
            [sSyY]*)
                cat >> "$WINDOWRULES_FILE" <<'EOF'

-- Hypr.AI layer rule — vidro real para o launcher, sem tocar no blur global.
--
-- xray fica FALSE de propósito (ao contrário da regra do Noctalia, que o usa):
-- xray manda o blur saltar as camadas intermédias e ir buscar o fundo. Em
-- desktops onde o wallpaper é ele próprio uma camada (ex.: noctalia-wallpaper,
-- a ocupar o ecrã inteiro), o xray salta justamente o que devia desfocar — o
-- wallpaper atravessa nítido pela transparência e o vidro desaparece sem erro
-- nenhum. O mesmo vale para widgets de desktop que fiquem atrás do menu.
hl.layer_rule({
  name = "hyprai",
  match = { namespace = "^rofi$" },
  no_anim = true,
  ignore_alpha = 0.2,
  blur = true,
  blur_popups = true,
  xray = false,
})
EOF
                say layerrule_ok
                ;;
            *)
                say layerrule_skip
                ;;
        esac
    else
        # Não interativo (ex.: instalação automatizada) — não decide por conta
        # própria, só mostra o que adicionar manualmente.
        say layerrule_noninteractive
        printf '%s\n' "$LAYER_RULE_LINE"
    fi
else
    say layerrule_manual
    printf '%s\n' "$LAYER_RULE_LINE"
fi

# 7. Recarrega Hyprland se estiver em execução
if command -v hyprctl &>/dev/null && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    hyprctl reload >/dev/null 2>&1 || true
    say reloaded
fi

echo ""
if [[ "$BIND_ADDED" -eq 1 && -n "$MENU_KEY" ]]; then
    say finished_key "$MENU_KEY"
else
    say finished
fi
