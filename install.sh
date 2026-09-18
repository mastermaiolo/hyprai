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
    [pt:bind_found]="✓ Atalho SUPER + I já configurado em binds.lua" [en:bind_found]="✓ Keybind SUPER + I already configured in binds.lua"
    [pt:bind_add]="Adicionando atalho SUPER + I ao binds.lua..."    [en:bind_add]="Adding SUPER + I keybind to binds.lua..."
    [pt:bind_ok]="✓ Atalho SUPER + I adicionado com sucesso"        [en:bind_ok]="✓ SUPER + I keybind added successfully"
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
    [pt:layerrule_manual]="windowrules.lua não encontrado — adicione manualmente ao seu hyprland.conf:" \
    [en:layerrule_manual]="windowrules.lua not found — add this to your hyprland.conf by hand:"
    [pt:layerrule_noninteractive]="Instalação não interativa — para ativar a exceção de vidro, adicione isto a windowrules.lua:" \
    [en:layerrule_noninteractive]="Non-interactive install — to enable the glass exception, add this to windowrules.lua:"
    [pt:done]="── Concluído! Pressione Super+I ou execute 'hyprai' no terminal ──" \
    [en:done]="── Done! Press Super+I or run 'hyprai' in terminal ──"
)
t() { printf -- "${T[$L:$1]:-${T[pt:$1]:-$1}}" "${2:-}"; }

echo "$(t title)"

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

echo "$(t installed_ok "$DEST")"

# 3. Estado para a ponte de cor tonal (Noctalia grava aqui em runtime)
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hyprai"
mkdir -p "$STATE_DIR"

# 4. Registra o template de cor tonal no Noctalia, se instalado
NOCTALIA_CONF="$HOME/.config/noctalia/config.toml"
if [[ -f "$NOCTALIA_CONF" ]]; then
    if grep -q "theme.templates.user.hyprai" "$NOCTALIA_CONF" 2>/dev/null; then
        echo "$(t noctalia_found)"
    else
        cat >> "$NOCTALIA_CONF" <<EOF

    [theme.templates.user.hyprai]
    input_path = "$DEST/theme/noctalia.rasi.tmpl"
    output_path = "$STATE_DIR/noctalia-colors.rasi"
EOF
        echo "$(t noctalia_ok)"
    fi
fi

# 5. Cria link simbólico em ~/.local/bin/hyprai
ln -sf "$DEST/ui/launcher.sh" "$BIN_TARGET"
chmod +x "$BIN_TARGET"
echo "$(t bin_ok "$BIN_TARGET")"

# 6. Configuração de atalho no binds.lua
if [[ -f "$BINDS_FILE" ]]; then
    if grep -q "hyprai" "$BINDS_FILE" 2>/dev/null; then
        echo "$(t bind_found)"
    else
        echo "$(t bind_add)"
        # Insere antes da seção HARDWARE CONTROLS ou no final da seção LAUNCHER
        if grep -F -q "LAUNCHER" "$BINDS_FILE"; then
            sed -i '/HARDWARE CONTROLS/i hl.bind(mainMod .. " + I",          hl.dsp.exec_cmd(launchPrefix .. os.getenv("HOME") .. "/.local/bin/hyprai"))' "$BINDS_FILE"
            echo "$(t bind_ok)"
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
if [[ -f "$WINDOWRULES_FILE" ]]; then
    if grep -q 'namespace = "\^rofi\$"' "$WINDOWRULES_FILE" 2>/dev/null; then
        # A regra existe — mas versões anteriores (e a regra do Noctalia, de
        # onde esta foi copiada) traziam xray = true, que mata o vidro em
        # desktops onde o wallpaper é uma camada. Avisa em vez de dar por
        # configurado e deixar o bug de pé.
        if awk '/namespace = "\^rofi\$"/,/\}\)/' "$WINDOWRULES_FILE" \
             | grep -qE 'xray[[:space:]]*=[[:space:]]*true'; then
            echo "$(t layerrule_xray_warn)"
        else
            echo "$(t layerrule_found)"
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
                echo "$(t layerrule_ok)"
                ;;
            *)
                echo "$(t layerrule_skip)"
                ;;
        esac
    else
        # Não interativo (ex.: instalação automatizada) — não decide por conta
        # própria, só mostra o que adicionar manualmente.
        echo "$(t layerrule_noninteractive)"
        printf 'hl.layer_rule({ name = "hyprai", match = { namespace = "^rofi$" }, no_anim = true, ignore_alpha = 0.2, blur = true, blur_popups = true, xray = false })\n'
    fi
else
    echo "$(t layerrule_manual)"
    cat <<'EOF'
layerrule = ignorealpha 0.2, ^rofi$
layerrule = blur, ^rofi$
layerrule = xray 0, ^rofi$
EOF
fi

# 7. Recarrega Hyprland se estiver em execução
if command -v hyprctl &>/dev/null && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    hyprctl reload >/dev/null 2>&1 || true
    echo "$(t reloaded)"
fi

echo ""
echo "$(t done)"
