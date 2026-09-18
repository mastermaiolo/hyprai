#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════
# Hypr.AI · Launcher Rofi
# Menu de acesso rápido para assistentes CLI, apps desktop e portais de IA.
# Inspirado na arquitetura e design system do HyprVision.
# ══════════════════════════════════════════════════════════════════════
set -euo pipefail

REAL_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$REAL_SOURCE")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Determina localização do arquivo de configuração de sites
if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprai/config/sites.conf" ]]; then
    SITES_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprai/config/sites.conf"
elif [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/hyprai/sites.conf" ]]; then
    SITES_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/hyprai/sites.conf"
elif [[ -f "$BASE_DIR/config/sites.conf" ]]; then
    SITES_CONF="$BASE_DIR/config/sites.conf"
else
    SITES_CONF="$SCRIPT_DIR/sites.conf"
fi

# Determina localização do arquivo de ferramentas locais (CLI/apps detectadas)
if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprai/config/tools.conf" ]]; then
    TOOLS_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprai/config/tools.conf"
elif [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/hyprai/tools.conf" ]]; then
    TOOLS_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/hyprai/tools.conf"
elif [[ -f "$BASE_DIR/config/tools.conf" ]]; then
    TOOLS_CONF="$BASE_DIR/config/tools.conf"
else
    TOOLS_CONF="$SCRIPT_DIR/tools.conf"
fi

# Determina localização do tema Rofi
if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprai/rofi/hyprai.rasi" ]]; then
    ROFI_THEME="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprai/rofi/hyprai.rasi"
elif [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/hyprai/hyprai.rasi" ]]; then
    ROFI_THEME="${XDG_CONFIG_HOME:-$HOME/.config}/hyprai/hyprai.rasi"
else
    ROFI_THEME="$BASE_DIR/rofi/hyprai.rasi"
fi

# Determina localização dos ícones SVG (element-icon real do rofi, não emoji)
if [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprai/svg" ]]; then
    ICON_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprai/svg"
else
    ICON_DIR="$BASE_DIR/svg"
fi

# ── i18n ──────────────────────────────────────────────────────────────
# pt_PT, pt_BR, es, en (convenção britânica onde houver diferença) e zh.
# pt_BR vem antes de pt* no case porque o glob pt* apanharia os dois.
case "${LC_ALL:-${LC_MESSAGES:-${LANG:-pt_PT}}}" in
    pt_BR*) L=pt_BR ;;
    pt*)    L=pt_PT ;;
    es*)    L=es ;;
    zh*)    L=zh ;;
    *)      L=en ;;
esac

# Organizado por idioma, não por chave: com 5 idiomas, uma linha por chave
# com todos lado a lado fica ilegível e é onde se erra ao acrescentar mais um.
#
# Nomes em capitalização normal, com o fornecedor como subtexto — "Claude Code"
# / "Anthropic", não "CLAUDE CODE CLI". Maiúsculas destroem a forma da palavra,
# que é o que torna uma lista rápida de percorrer.
#
# Os rótulos de categoria (cat_*) são de UMA palavra de propósito: servem tanto
# aos chips como aos cabeçalhos de secção, e um rótulo longo parte a fileira de
# chips em duas linhas desalinhadas (coherent-design: "tab labels one word").
declare -A T=()

# ── Português (Portugal) ──
T+=(
    [pt_PT:title]="🧠 AI Hub"
    [pt_PT:search_placeholder]="pesquisar ferramenta ou site de IA..."
    [pt_PT:cat_cli]="Agentes CLI"
    [pt_PT:cat_desktop]="Aplicações"
    [pt_PT:cat_web]="Web"
    [pt_PT:cat_config]="Configuração"
    [pt_PT:name_ai_web]="Portais Web"
    [pt_PT:desc_ai_web]="%s sites"
    [pt_PT:edit_sites]="Definições"
    [pt_PT:desc_edit_sites]="sites.conf"
    [pt_PT:back]="Voltar"
    [pt_PT:web_hub_title]="Portais de IA na Web"
    [pt_PT:cat_chat]="Chat"
    [pt_PT:cat_search]="Pesquisa"
    [pt_PT:cat_write]="Escrita"
    [pt_PT:cat_dev]="Dev"
    [pt_PT:cat_code]="Código"
    [pt_PT:cat_media]="Média"
    [pt_PT:opening]="A abrir"
    [pt_PT:err_tool_missing]="Já não foi encontrado"
    [pt_PT:err_tool_missing_body]="Pode ter sido desinstalado"
)

# ── Português (Brasil) ──
T+=(
    [pt_BR:title]="🧠 AI Hub"
    [pt_BR:search_placeholder]="pesquisar ferramenta ou site de IA..."
    [pt_BR:cat_cli]="Agentes CLI"
    [pt_BR:cat_desktop]="Aplicativos"
    [pt_BR:cat_web]="Web"
    [pt_BR:cat_config]="Configuração"
    [pt_BR:name_ai_web]="Portais Web"
    [pt_BR:desc_ai_web]="%s sites"
    [pt_BR:edit_sites]="Configurações"
    [pt_BR:desc_edit_sites]="sites.conf"
    [pt_BR:back]="Voltar"
    [pt_BR:web_hub_title]="Portais de IA na Web"
    [pt_BR:cat_chat]="Chat"
    [pt_BR:cat_search]="Pesquisa"
    [pt_BR:cat_write]="Escrita"
    [pt_BR:cat_dev]="Dev"
    [pt_BR:cat_code]="Código"
    [pt_BR:cat_media]="Mídia"
    [pt_BR:opening]="Abrindo"
    [pt_BR:err_tool_missing]="Não encontrado"
    [pt_BR:err_tool_missing_body]="Pode ter sido desinstalado"
)

# ── Español (España) ──
T+=(
    [es:title]="🧠 AI Hub"
    [es:search_placeholder]="buscar herramienta o sitio de IA..."
    [es:cat_cli]="Agentes CLI"
    [es:cat_desktop]="Aplicaciones"
    [es:cat_web]="Web"
    [es:cat_config]="Configuración"
    [es:name_ai_web]="Portales web"
    [es:desc_ai_web]="%s sitios"
    [es:edit_sites]="Ajustes"
    [es:desc_edit_sites]="sites.conf"
    [es:back]="Volver"
    [es:web_hub_title]="Portales de IA en la web"
    [es:cat_chat]="Chat"
    [es:cat_search]="Búsqueda"
    [es:cat_write]="Escritura"
    [es:cat_dev]="Dev"
    [es:cat_code]="Código"
    [es:cat_media]="Medios"
    [es:opening]="Abriendo"
    [es:err_tool_missing]="Ya no se encuentra"
    [es:err_tool_missing_body]="Puede que se haya desinstalado"
)

# ── English (UK) ──
T+=(
    [en:title]="🧠 AI Hub"
    [en:search_placeholder]="search AI tool or website..."
    [en:cat_cli]="CLI agents"
    [en:cat_desktop]="Applications"
    [en:cat_web]="Web"
    [en:cat_config]="Configuration"
    [en:name_ai_web]="Web portals"
    [en:desc_ai_web]="%s sites"
    [en:edit_sites]="Settings"
    [en:desc_edit_sites]="sites.conf"
    [en:back]="Back"
    [en:web_hub_title]="AI web portals"
    [en:cat_chat]="Chat"
    [en:cat_search]="Search"
    [en:cat_write]="Writing"
    [en:cat_dev]="Dev"
    [en:cat_code]="Code"
    [en:cat_media]="Media"
    [en:opening]="Opening"
    [en:err_tool_missing]="No longer found"
    [en:err_tool_missing_body]="It may have been uninstalled"
)

# ── 中文 ──
T+=(
    [zh:title]="🧠 AI 中心"
    [zh:search_placeholder]="搜索 AI 工具或网站..."
    [zh:cat_cli]="命令行智能体"
    [zh:cat_desktop]="桌面应用"
    [zh:cat_web]="Web"
    [zh:cat_config]="配置"
    [zh:name_ai_web]="网页门户"
    [zh:desc_ai_web]="%s 个网站"
    [zh:edit_sites]="设置"
    [zh:desc_edit_sites]="sites.conf"
    [zh:back]="返回"
    [zh:web_hub_title]="AI 网页门户"
    [zh:cat_chat]="对话"
    [zh:cat_search]="搜索"
    [zh:cat_write]="写作"
    [zh:cat_dev]="开发"
    [zh:cat_code]="代码"
    [zh:cat_media]="多媒体"
    [zh:opening]="正在打开"
    [zh:err_tool_missing]="已找不到"
    [zh:err_tool_missing_body]="可能已被卸载"
)

# Chave em falta cai para o inglês, não para a chave crua — um rótulo
# "cat_media" na interface é pior que o termo em inglês.
t() { printf -- "${T[$L:$1]:-${T[en:$1]:-$1}}" "${2:-}"; }

# ── Cor tonal do sistema ──────────────────────────────────────────────
# TODOS os neutros seguem o wallpaper agora, não só o accent — bg0…fg3,
# chip-bg/chip-fg e o rim do vidro vêm todos do mesmo esquema tonal
# (ver theme/noctalia.rasi.tmpl para o mapeamento completo de papéis M3).
# É essa cobertura total, não só o accent, que faz o launcher ler-se como
# parte do mesmo sistema que o Noctalia/Caelestia já pintam no resto do
# desktop — em vez de um chrome fixo com um glifo colorido por cima.
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hyprai"
NOCTALIA_THEME="$STATE_DIR/noctalia-colors.rasi"
CAELESTIA_JSON="$HOME/.local/state/caelestia/scheme.json"

scheme_color() {
    [[ -f "$CAELESTIA_JSON" ]] || return 0
    sed -n "s/.*\"$1\": *\"\([0-9a-fA-F]\{6\}\)\".*/\1/p" "$CAELESTIA_JSON" | head -1
}

# Guarda de legibilidade: aceita um hex só se não for escuro a mais para
# servir de accent/primary em qualquer contexto (chip, prompt, scrollbar).
# Brilho percebido em aritmética inteira — aproximação grosseira, mas chega
# para rejeitar os casos maus sem puxar python só por causa disto.
_bright_enough() {
    local hex="$1" r g b
    r=$((16#${hex:0:2})); g=$((16#${hex:2:2})); b=$((16#${hex:4:2}))
    (( (r * 299 + g * 587 + b * 114) / 1000 >= 120 ))
}

dynamic_theme() {
    # 1) Noctalia — o próprio Noctalia já renderizou theme/noctalia.rasi.tmpl
    # inteiro (todos os tokens, não só o accent); basta repassar o arquivo.
    if [[ -s "$NOCTALIA_THEME" ]] && ! grep -q '{{' "$NOCTALIA_THEME"; then
        local accent; accent="$(sed -n 's/.*bg3:[[:space:]]*#\([0-9a-fA-F]\{6\}\).*/\1/p' "$NOCTALIA_THEME" | head -1)"
        if [[ -n "$accent" ]] && _bright_enough "$accent"; then
            cat "$NOCTALIA_THEME"
            return 0
        fi
    fi

    # 2) Caelestia (compat) — só JSON bruto, então remonta o mesmo conjunto
    # de tokens à mão a partir dos papéis M3 que o scheme.json expõe.
    if [[ -f "$CAELESTIA_JSON" ]]; then
        local primary; primary="$(scheme_color primary)"
        if [[ -n "$primary" ]] && _bright_enough "$primary"; then
            local background on_background surface_container_high surface_container \
                  on_surface_variant outline on_primary primary_container on_primary_container error
            background="$(scheme_color background)"
            on_background="$(scheme_color onBackground)"
            surface_container_high="$(scheme_color surfaceContainerHigh)"
            surface_container="$(scheme_color surfaceContainer)"
            on_surface_variant="$(scheme_color onSurfaceVariant)"
            outline="$(scheme_color outline)"
            on_primary="$(scheme_color onPrimary)"
            primary_container="$(scheme_color primaryContainer)"
            on_primary_container="$(scheme_color onPrimaryContainer)"
            error="$(scheme_color error)"

            if [[ -n "$background" && -n "$on_background" ]]; then
                cat <<RASI
* {
    bg0:        #${background}F2;
    bg1:        #${surface_container_high:-$background};
    bg2:        #${surface_container:-$background}99;
    bg3:        #${primary}F2;
    fg0:        #${on_background};
    fg2:        #${on_surface_variant:-$on_background};
    fg3:        #${outline:-$on_surface_variant};
    accent-fg:  #${on_primary:-000000};
    error:      #${error:-E97871}F2;
    sel:        #${primary}1F;
    sep:        #${outline:-$on_surface_variant};
    chip-bg:    #${primary_container:-$primary};
    chip-fg:    #${on_primary_container:-$on_background};
    rim-top:    #${on_background}38;
}
RASI
            else
                # Sem papéis suficientes para os neutros — só o accent, como
                # compat mínimo (a estrutura/grid do tema não muda).
                printf '* { bg3: #%sF2; }\nwindow { border-color: #%s38; }\n' "$primary" "$primary"
            fi
            return 0
        fi
    fi
}

# ── Construção das linhas ─────────────────────────────────────────────
# Texto e id em arrays paralelos. O rofi devolve o índice (-format i), por
# isso o id nunca precisa de aparecer no ecrã — nada de [claude_cli] a ocupar
# uma coluna em todas as linhas.
ROW_TEXT=()
ROW_ID=()
ROW_ICON=()

row()  { ROW_TEXT+=("$1"); ROW_ID+=("${2:-}"); ROW_ICON+=("${3:-}"); }

# Cabeçalho de secção: pequeno, discreto, sem preenchimento nem moldura.
sep()  { row "$(printf '<span size="small" weight="600" alpha="45%%" letter_spacing="900">%s</span>' "$(esc "$1")")"; }

# Pango markup: '&' e '<' num nome vindo do sites.conf partem a linha inteira.
esc() { printf '%s' "${1//&/&amp;}" | sed 's/</\&lt;/g'; }

# Resolve o tema dinâmico uma única vez por execução — run_menu() e os chips
# em pango partilham o mesmo resultado, para o badge do prompt (renderizado
# pelo próprio rofi, lê @chip-bg direto do .rasi) e os chips de categoria/ícone
# (texto pango, sem acesso a variáveis do tema) nunca dessincronizarem.
DYNAMIC_THEME_STR="$(dynamic_theme)"

_token() {
    sed -n "s/.*\b$1:[[:space:]]*\(#[0-9a-fA-F]\{6,8\}\).*/\1/p" <<<"$DYNAMIC_THEME_STR" | head -1
}

# Chip de categoria/ícone: elevação NEUTRA (bg1/fg2 — o mesmo "content
# material" do inputbar), não o accent. O accent do M3 (chip-bg/chip-fg,
# primary-container) fica só no badge do prompt — com 4 categorias + 5+
# ícones de linha também tingidos de accent, a lista inteira vira um bloco
# da mesma cor e "um accent só, 1-2 elementos" deixa de valer. Pango não lê
# variáveis do tema, por isso o valor já resolvido entra aqui como hex
# literal; sem override dinâmico, cai no mesmo fallback estático do .rasi.
CHIP_BG="$(_token bg1)"; CHIP_BG="${CHIP_BG:-#1C1C21}"
CHIP_FG="$(_token fg2)"; CHIP_FG="${CHIP_FG:-#9E9EA3}"
chip() { printf '<span background="%s" foreground="%s" size="small" weight="600">  %s  </span>' \
            "$CHIP_BG" "$CHIP_FG" "$(esc "$1")"; }

# Fileira de categorias — equivalente estático à barra "Calendar ·
# Applications · Actions …" da referência: mostra os grupos da lista atual
# acima dela, via -mesg. Não é clicável (o dmenu do rofi não alterna modos
# sem reescrever isto como múltiplos "modi" de script); é a legenda visual.
chips_row() {
    local out="" first=1 c
    for c in "$@"; do
        [[ $first -eq 0 ]] && out+="  "
        out+="$(chip "$c")"
        first=0
    done
    printf '%s' "$out"
}

# Linha: ícone, nome, e o fornecedor em subtexto. Subtexto é opcional. $5,
# se dado, é um arquivo dentro de svg/ — quando existe, vira o element-icon
# real do rofi (protocolo -show-icons) e o chip de emoji nem entra no texto;
# sem arquivo (ou arquivo ausente), cai no emoji em chip discreto de sempre.
item() {
    local icon="$1" name; name="$(esc "$2")"
    local desc="${3:-}" id="${4:-}" icon_file="${5:-}"
    local icon_path=""
    if [[ -n "$icon_file" && -f "$ICON_DIR/$icon_file" ]]; then
        icon_path="$ICON_DIR/$icon_file"
    fi

    local lead
    if [[ -n "$icon_path" ]]; then
        lead=""
    else
        lead="$(printf '<span background="%s"> %s </span>  ' "$CHIP_BG" "$icon")"
    fi

    if [[ -n "$desc" ]]; then
        row "$(printf '%s%s   <span size="small" alpha="50%%">%s</span>' \
                "$lead" "$name" "$(esc "$desc")")" "$id" "$icon_path"
    else
        row "$(printf '%s%s' "$lead" "$name")" "$id" "$icon_path"
    fi
}

back_row() { row "$(printf '↩  <span alpha="70%%">%s</span>' "$(t back)")" "__back__"; }

# Corre o menu com as linhas já construídas. $2 = linha selecionada de início
# (1 = o primeiro item real, para o cursor não abrir em cima de um cabeçalho).
# $3 = markup da fileira de categorias (opcional), mostrada acima da lista.
run_menu() {
    local dyn=(); [[ -n "$DYNAMIC_THEME_STR" ]] && dyn=(-theme-str "$DYNAMIC_THEME_STR")
    local mesg=(); [[ -n "${3:-}" ]] && mesg=(-mesg "$3")
    # O protocolo de ícone do rofi precisa de um byte NUL literal entre o texto
    # e "icon\x1f<path>" — uma variável bash não guarda NUL (trunca a string),
    # por isso o byte só pode nascer aqui, no printf que escreve direto no pipe,
    # nunca num array/variável intermediária.
    local i
    for i in "${!ROW_TEXT[@]}"; do
        if [[ -n "${ROW_ICON[i]:-}" ]]; then
            printf '%s\x00icon\x1f%s\n' "${ROW_TEXT[i]}" "${ROW_ICON[i]}"
        else
            printf '%s\n' "${ROW_TEXT[i]}"
        fi
    done | rofi -dmenu -show-icons -p "$1" -theme "$ROFI_THEME" \
        -theme-str "entry { placeholder: \"$(t search_placeholder)\"; }" \
        "${dyn[@]}" "${mesg[@]}" -no-custom -markup-rows -format i -selected-row "${2:-1}"
}

# ── Helpers de inicialização compatíveis com UWSM e Wayland/Hyprland ──
launch_cmd() {
    if command -v uwsm &>/dev/null && uwsm check is-active &>/dev/null; then
        uwsm app -- "$@" &
    else
        "$@" &>/dev/null &
    fi
}

launch_term() {
    local title="$1"
    local cmd="$2"
    if command -v uwsm &>/dev/null && uwsm check is-active &>/dev/null; then
        uwsm app -- kitty --title "$title" fish -i -c "$cmd" &
    else
        kitty --title "$title" fish -i -c "$cmd" &
    fi
}

launch_web() {
    local url="$1"
    local name="${2:-Web AI}"
    if command -v notify-send &>/dev/null; then
        notify-send -a "Hypr.AI" "$(t opening) $name" "$url" -i "web-browser" || true
    fi
    if command -v uwsm &>/dev/null && uwsm check is-active &>/dev/null; then
        uwsm app -- xdg-open "$url" &
    else
        xdg-open "$url" &>/dev/null &
    fi
}

edit_file() {
    local target="$1"
    local editor_cmd=""
    for ed in "${VISUAL:-}" "${EDITOR:-}" zeditor code nvim micro nano kate; do
        if [[ -n "$ed" ]] && command -v "${ed%% *}" &>/dev/null; then
            editor_cmd="$ed"
            break
        fi
    done
    if [[ -z "$editor_cmd" ]]; then
        launch_cmd xdg-open "$target"
    else
        case "${editor_cmd%% *}" in
            zeditor|code|kate|gedit)
                launch_cmd $editor_cmd "$target"
                ;;
            *)
                launch_cmd kitty $editor_cmd "$target"
                ;;
        esac
    fi
}

# ── Detecção de ferramentas locais (tools.conf) ────────────────────────
# TOOL_CMD/TOOL_CAT/TOOL_NAME guardam, por id, o que foi realmente
# encontrado — o case de lançamento lê daqui em vez de ter um bloco
# hardcoded por ferramenta.
declare -A TOOL_CMD=()
declare -A TOOL_CAT=()
declare -A TOOL_NAME=()
declare -A TOOL_ARGS=()

# Primeiro candidato existente de uma lista "a;b;c" — nome solto procura no
# PATH, caminho absoluto ou começando por "~" é testado com -x. Retorna
# vazio (e falha) se nenhum bater, pra a chamadora pular a ferramenta.
#
# Um binário solto é checado dentro do fish (não do bash puro): o launcher é
# disparado pelo Hyprland/systemd com um PATH mínimo (~/.local/bin,
# ~/.cargo/bin — ver ~/.config/uwsm/env), que não inclui o que o config.fish
# do usuário adiciona (ex.: linuxbrew, nvm, pyenv). launch_term já roda tudo
# dentro de "fish -i" — se a detecção não olhar o mesmo PATH, uma ferramenta
# instalada por um version/package manager que só o fish conhece nunca
# aparece no menu mesmo estando 100% executável.
resolve_candidate() {
    local cand expanded
    IFS=';' read -ra _cands <<< "$1"
    for cand in "${_cands[@]}"; do
        [[ -z "$cand" ]] && continue
        expanded="${cand/#\~/$HOME}"
        if [[ "$expanded" == /* ]]; then
            [[ -x "$expanded" ]] && { printf '%s' "$expanded"; return 0; }
        elif command -v fish &>/dev/null; then
            local hit
            hit="$(fish -c "command -v -- '$expanded'" 2>/dev/null)"
            [[ -n "$hit" ]] && { printf '%s' "$hit"; return 0; }
        elif command -v "$expanded" &>/dev/null; then
            command -v "$expanded"; return 0
        fi
    done
    return 1
}

# ── Menu principal ────────────────────────────────────────────────────
build_main() {
    ROW_TEXT=(); ROW_ID=(); ROW_ICON=()
    TOOL_CMD=(); TOOL_CAT=(); TOOL_NAME=(); TOOL_ARGS=()
    HAS_CLI=0; HAS_DESKTOP=0

    local last_cat="" tid ticon tname tdesc tcat tcands tsvg targs found
    if [[ -f "$TOOLS_CONF" ]]; then
        while IFS='|' read -r tid ticon tname tdesc tcat tcands tsvg targs; do
            [[ -z "$tid" || "$tid" =~ ^[[:space:]]*# ]] && continue
            found="$(resolve_candidate "$tcands")" || continue
            TOOL_CMD["$tid"]="$found"
            TOOL_CAT["$tid"]="$tcat"
            TOOL_NAME["$tid"]="$tname"
            TOOL_ARGS["$tid"]="$targs"
            [[ "$tcat" == "cli" ]] && HAS_CLI=1
            [[ "$tcat" == "desktop" ]] && HAS_DESKTOP=1
            if [[ "$tcat" != "$last_cat" ]]; then
                case "$tcat" in
                    cli)     sep "$(t cat_cli)" ;;
                    desktop) sep "$(t cat_desktop)" ;;
                    *)       sep "$tcat" ;;
                esac
                last_cat="$tcat"
            fi
            item "$ticon" "$tname" "$tdesc" "$tid" "$tsvg"
        done < "$TOOLS_CONF"
    fi

    sep "$(t cat_web)"
    local count=0
    if [[ -f "$SITES_CONF" ]]; then
        # Uma entrada real é uma linha não comentada com "|" (id|ícone|nome|
        # categoria|url) — precisa das duas condições: só "#" deixava passar
        # as linhas em branco entre secções, e só "|" pegava até o comentário
        # de formato no topo do arquivo, que também tem pipes.
        count=$(grep -v '^[[:space:]]*#' "$SITES_CONF" | grep -c '|' || true)
    fi
    item "✨" "$(t name_ai_web)"         "$(t desc_ai_web "$count")" "__web__"

    sep "$(t cat_config)"
    item "📝" "$(t edit_sites)"          "$(t desc_edit_sites)"      "__edit_sites__"
}

build_main
# Só entra na fileira de chips quem realmente tem itens — um chip
# apontando pra uma secção vazia (nenhuma ferramenta detectada) confunde
# mais do que ajuda.
MAIN_CHIP_LABELS=()
[[ "$HAS_CLI" -eq 1 ]]     && MAIN_CHIP_LABELS+=("$(t cat_cli)")
[[ "$HAS_DESKTOP" -eq 1 ]] && MAIN_CHIP_LABELS+=("$(t cat_desktop)")
MAIN_CHIP_LABELS+=("$(t cat_web)" "$(t cat_config)")
MAIN_CHIPS="$(chips_row "${MAIN_CHIP_LABELS[@]}")"
IDX=$(run_menu "$(t title)" 1 "$MAIN_CHIPS") || exit 0
[[ "${IDX:-}" =~ ^[0-9]+$ ]] || exit 0
ID="${ROW_ID[$IDX]:-}"
# Índice sem id = cabeçalho de secção; reabre em vez de fazer nada.
[[ -z "$ID" ]] && exec "$0"

case "$ID" in
    __web__)
        # Submenu com navegação para sites de IA
        build_web() {
            ROW_TEXT=(); ROW_ID=(); ROW_ICON=()
            back_row
            local last_cat="" sid sicon sname scat surl ssvg
            if [[ -f "$SITES_CONF" ]]; then
                while IFS='|' read -r sid sicon sname scat surl ssvg; do
                    [[ -z "$sid" || "$sid" =~ ^[[:space:]]*# ]] && continue
                    if [[ "$scat" != "$last_cat" ]]; then
                        case "$scat" in
                            chat)   sep "$(t cat_chat)" ;;
                            search) sep "$(t cat_search)" ;;
                            write)  sep "$(t cat_write)" ;;
                            dev)    sep "$(t cat_dev)" ;;
                            code)   sep "$(t cat_code)" ;;
                            media)  sep "$(t cat_media)" ;;
                            *)      sep "$scat" ;;
                        esac
                        last_cat="$scat"
                    fi
                    item "$sicon" "$sname" "" "$sid" "$ssvg"
                done < "$SITES_CONF"
            fi
        }

        build_web
        WEB_CHIPS="$(chips_row "$(t cat_chat)" "$(t cat_search)" "$(t cat_write)" "$(t cat_dev)" "$(t cat_code)" "$(t cat_media)")"
        # Linha 0 é "Voltar"; o cursor abre no primeiro site real (linha 2,
        # depois do primeiro cabeçalho).
        WIDX=$(run_menu "🌐 $(t web_hub_title)" 2 "$WEB_CHIPS") || exit 0
        [[ "${WIDX:-}" =~ ^[0-9]+$ ]] || exit 0
        SEL="${ROW_ID[$WIDX]:-}"
        [[ -z "$SEL" ]] && exec "$0"
        if [[ "$SEL" == "__back__" ]]; then exec "$0"; fi

        # Extrai URL e nome do site selecionado
        TARGET_URL=""
        TARGET_NAME=""
        while IFS='|' read -r sid sicon sname scat surl ssvg; do
            if [[ "$sid" == "$SEL" ]]; then
                TARGET_URL="$surl"
                TARGET_NAME="$sname"
                break
            fi
        done < "$SITES_CONF"

        if [[ -n "$TARGET_URL" ]]; then
            launch_web "$TARGET_URL" "$TARGET_NAME"
        fi
        ;;
    __edit_sites__)
        edit_file "$SITES_CONF"
        ;;
    *)
        # $ID não vazio chegou até aqui (a checagem lá em cima já cobriu o
        # caso de cabeçalho de secção) — só falta ser uma ferramenta do
        # tools.conf detectada em build_main().
        if [[ -n "${TOOL_CMD[$ID]:-}" ]]; then
            if [[ "${TOOL_CAT[$ID]}" == "cli" ]]; then
                # launch_term manda a string inteira pro "fish -c" — junta
                # comando e argumento extra (ex.: "hermes chat") num só texto.
                launch_term "${TOOL_NAME[$ID]}" "${TOOL_CMD[$ID]} ${TOOL_ARGS[$ID]}"
            else
                # launch_cmd exec's "$@" direto (sem passar por shell), então
                # o argumento extra (ex.: "desktop" em "hermes desktop") entra
                # como palavra separada, não colada na mesma string.
                launch_cmd "${TOOL_CMD[$ID]}" ${TOOL_ARGS[$ID]}
            fi
        else
            # Estava no menu há segundos (detectado em build_main) e sumiu
            # até o clique — janela de tempo mínima, mas cobre o caso.
            notify-send -a "Hypr.AI" "$(t err_tool_missing)" "$(t err_tool_missing_body)" || true
        fi
        ;;
esac
