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
    [pt_PT:edit_tools]="Ferramentas"
    [pt_PT:desc_edit_tools]="tools.conf"
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
    [pt_PT:err_no_kitty]="Kitty não encontrado"
    [pt_PT:err_no_kitty_body]="Instala o terminal kitty para executar agentes CLI"
    [pt_PT:err_no_opener]="Não há como abrir o site"
    [pt_PT:err_no_opener_body]="Instala o xdg-utils (xdg-open)"
    [pt_PT:err_bad_cat]="Entrada ignorada no tools.conf"
    [pt_PT:err_bad_cat_body]="Categoria inválida (use cli ou desktop): %s"
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
    [pt_BR:edit_tools]="Ferramentas"
    [pt_BR:desc_edit_tools]="tools.conf"
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
    [pt_BR:err_no_kitty]="Kitty não encontrado"
    [pt_BR:err_no_kitty_body]="Instale o terminal kitty para executar agentes CLI"
    [pt_BR:err_no_opener]="Não há como abrir o site"
    [pt_BR:err_no_opener_body]="Instale o xdg-utils (xdg-open)"
    [pt_BR:err_bad_cat]="Entrada ignorada no tools.conf"
    [pt_BR:err_bad_cat_body]="Categoria inválida (use cli ou desktop): %s"
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
    [es:edit_tools]="Herramientas"
    [es:desc_edit_tools]="tools.conf"
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
    [es:err_no_kitty]="Kitty no encontrado"
    [es:err_no_kitty_body]="Instala la terminal kitty para ejecutar agentes CLI"
    [es:err_no_opener]="No hay cómo abrir el sitio"
    [es:err_no_opener_body]="Instala xdg-utils (xdg-open)"
    [es:err_bad_cat]="Entrada ignorada en tools.conf"
    [es:err_bad_cat_body]="Categoría no válida (usa cli o desktop): %s"
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
    [en:edit_tools]="Tools"
    [en:desc_edit_tools]="tools.conf"
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
    [en:err_no_kitty]="Kitty not found"
    [en:err_no_kitty_body]="Install the kitty terminal to run CLI agents"
    [en:err_no_opener]="Can't open the website"
    [en:err_no_opener_body]="Install xdg-utils (xdg-open)"
    [en:err_bad_cat]="Entry skipped in tools.conf"
    [en:err_bad_cat_body]="Invalid category (use cli or desktop): %s"
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
    [zh:edit_tools]="工具"
    [zh:desc_edit_tools]="tools.conf"
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
    [zh:err_no_kitty]="未找到 Kitty"
    [zh:err_no_kitty_body]="请安装 kitty 终端以运行命令行智能体"
    [zh:err_no_opener]="无法打开网站"
    [zh:err_no_opener_body]="请安装 xdg-utils（xdg-open）"
    [zh:err_bad_cat]="tools.conf 中的条目已跳过"
    [zh:err_bad_cat_body]="无效分类（请使用 cli 或 desktop）：%s"
)

# Chave em falta cai para o inglês, não para a chave crua — um rótulo
# "cat_media" na interface é pior que o termo em inglês.
# shellcheck disable=SC2059  # o formato É a tradução (leva %s)
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

# Guarda de legibilidade: aceita o accent só se contrastar ≥ 3:1 com o fundo
# (WCAG 1.4.11, componentes não-texto — prompt, scrollbar). Contraste e não
# brilho absoluto: num esquema claro o primary do M3 é escuro de propósito,
# e uma guarda de brilho rejeitava todo wallpaper claro. awk só pela vírgula
# flutuante da curva sRGB — já é dependência do resto do script.
_contrast_ok() {   # $1=accent $2=fundo, hex sem '#'
    awk -v a="$1" -v b="$2" '
        function ch(h,   v) { h = tolower(h)   # gawk não lê "0x.." de string
                              v = (index("0123456789abcdef", substr(h, 1, 1)) - 1) * 16 \
                                +  index("0123456789abcdef", substr(h, 2, 1)) - 1
                              v /= 255
                              return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ^ 2.4 }
        function lum(h) { return 0.2126 * ch(substr(h, 1, 2)) + 0.7152 * ch(substr(h, 3, 2)) \
                               + 0.0722 * ch(substr(h, 5, 2)) }
        BEGIN { la = lum(a); lb = lum(b)
                r = la > lb ? (la + 0.05) / (lb + 0.05) : (lb + 0.05) / (la + 0.05)
                exit !(r >= 3) }'
}

dynamic_theme() {
    # 1) Noctalia — o próprio Noctalia já renderizou theme/noctalia.rasi.tmpl
    # inteiro (todos os tokens, não só o accent); basta repassar o arquivo.
    if [[ -s "$NOCTALIA_THEME" ]] && ! grep -q '{{' "$NOCTALIA_THEME"; then
        local accent bg
        accent="$(sed -n 's/.*bg3:[[:space:]]*#\([0-9a-fA-F]\{6\}\).*/\1/p' "$NOCTALIA_THEME" | head -1)"
        bg="$(sed -n 's/.*bg0:[[:space:]]*#\([0-9a-fA-F]\{6\}\).*/\1/p' "$NOCTALIA_THEME" | head -1)"
        if [[ -n "$accent" && -n "$bg" ]] && _contrast_ok "$accent" "$bg"; then
            cat "$NOCTALIA_THEME"
            return 0
        fi
    fi

    # 2) Caelestia (compat) — só JSON bruto, então remonta o mesmo conjunto
    # de tokens à mão a partir dos papéis M3 que o scheme.json expõe.
    if [[ -f "$CAELESTIA_JSON" ]]; then
        local primary background
        primary="$(scheme_color primary)"
        background="$(scheme_color background)"
        # Sem background não há contra o que medir — cai no fundo estático.
        if [[ -n "$primary" ]] && _contrast_ok "$primary" "${background:-0D0D10}"; then
            local on_background surface_container_high surface_container \
                  on_surface_variant outline on_primary primary_container on_primary_container error
            on_background="$(scheme_color onBackground)"
            surface_container_high="$(scheme_color surfaceContainerHigh)"
            surface_container="$(scheme_color surfaceContainer)"
            on_surface_variant="$(scheme_color onSurfaceVariant)"
            outline="$(scheme_color outline)"
            on_primary="$(scheme_color onPrimary)"
            primary_container="$(scheme_color primaryContainer)"
            on_primary_container="$(scheme_color onPrimaryContainer)"
            error="$(scheme_color error)"

            # Mesmos alphas do theme/noctalia.rasi.tmpl — mudar lá, mudar aqui.
            # bg0 a 60%: acima de ~85% o blur deixa de se ver (ver DESIGN.md).
            if [[ -n "$background" && -n "$on_background" ]]; then
                cat <<RASI
* {
    bg0:        #${background}99;
    bg1:        #${surface_container_high:-$background}E6;
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

# Categorias vistas ao montar o submenu web, na ordem em que aparecem no
# sites.conf — usado pra montar WEB_CHIPS só com quem realmente tem itens
# (mesmo critério já aplicado a MAIN_CHIP_LABELS mais abaixo).
declare -A SEEN_WEB_CATS=()
WEB_CAT_ORDER=()

row()  { ROW_TEXT+=("$1"); ROW_ID+=("${2:-}"); ROW_ICON+=("${3:-}"); }

# Cabeçalho de secção: pequeno, discreto, sem preenchimento nem moldura.
sep()  { row "$(printf '<span size="small" weight="600" alpha="45%%" letter_spacing="900">%s</span>' "$(esc "$1")")"; }

# Pango markup: '&', '<' e '>' num nome vindo das configurações partem a linha inteira.
esc() {
    local s="${1//&/\&amp;}"
    s="${s//</\&lt;}"
    s="${s//>/\&gt;}"
    printf '%s' "$s"
}

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
# real do rofi (protocolo -show-icons). O chip de emoji no texto só sobra
# como último recurso, se nem o PNG do emoji nem o generic.svg existirem.
#
# Sem svg, o emoji do .conf também vai para a coluna de ícone, não para o
# texto: uma linha com a coluna vazia ficava com o nome recuado em relação às
# outras. O librsvg desenha emoji a preto chapado, por isso o emoji vira PNG
# pelo pango-view (vem com o pango, de que o próprio rofi depende), uma vez
# só, em cache. Sem pango-view, ícone genérico — o alinhamento é que importa.
EMOJI_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/hyprai/emoji"
emoji_icon() {   # $1=emoji → caminho do PNG em cache
    local key out
    [[ -n "$1" ]] && command -v pango-view &>/dev/null || return 1
    key="$(printf '%s' "$1" | od -An -tx1 | tr -d ' \n')"
    out="$EMOJI_CACHE/$key.png"
    if [[ ! -s "$out" ]]; then
        mkdir -p "$EMOJI_CACHE" || return 1
        if ! pango-view --no-display -q --background=transparent --margin=0 \
                --font="Noto Color Emoji 40" --text="$1" -o "$out.tmp.png" &>/dev/null \
             || ! mv -f "$out.tmp.png" "$out"; then
            rm -f "$out.tmp.png"
            return 1
        fi
    fi
    printf '%s' "$out"
}

item() {
    local icon="$1" name; name="$(esc "$2")"
    local desc="${3:-}" id="${4:-}" icon_file="${5:-}"
    local icon_path=""
    if [[ -n "$icon_file" && -f "$ICON_DIR/$icon_file" ]]; then
        icon_path="$ICON_DIR/$icon_file"
    elif ! icon_path="$(emoji_icon "$icon")" && [[ -f "$ICON_DIR/generic.svg" ]]; then
        icon_path="$ICON_DIR/generic.svg"
    fi

    local lead
    if [[ -n "$icon_path" ]]; then
        lead=""
    else
        lead="$(printf '<span background="%s"> %s </span>  ' "$CHIP_BG" "$(esc "$icon")")"
    fi

    if [[ -n "$desc" ]]; then
        row "$(printf '%s%s   <span size="small" alpha="50%%">%s</span>' \
                "$lead" "$name" "$(esc "$desc")")" "$id" "$icon_path"
    else
        row "$(printf '%s%s' "$lead" "$name")" "$id" "$icon_path"
    fi
}

back_row() {
    local b_icon=""
    [[ -f "$ICON_DIR/back.svg" ]] && b_icon="$ICON_DIR/back.svg"
    row "$(printf '<span alpha="70%%">%s</span>' "$(t back)")" "__back__" "$b_icon"
}

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

# Tira espaço à volta de cada variável nomeada, no lugar — nameref em vez de
# $(trim …) para não abrir um subshell por campo (~240 por abertura).
trim_vars() {
    local -n _tv
    for _tv in "$@"; do
        _tv="${_tv#"${_tv%%[![:space:]]*}"}"
        _tv="${_tv%"${_tv##*[![:space:]]}"}"
    done
}

# notify-send é opcional (libnotify) — sem ele, a mensagem perde-se, mas o
# launcher nunca falha por causa disso.
notify() {
    command -v notify-send &>/dev/null || return 0
    notify-send -a "Hypr.AI" "$@" || true
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
    if ! command -v kitty &>/dev/null; then
        notify "$(t err_no_kitty)" "$(t err_no_kitty_body)"
        return 1
    fi
    if command -v uwsm &>/dev/null && uwsm check is-active &>/dev/null; then
        uwsm app -- kitty --title "$title" fish -i -c "$cmd" &
    else
        kitty --title "$title" fish -i -c "$cmd" &
    fi
}

launch_web() {
    local url="$1"
    local name="${2:-Web AI}"
    # Sem isto, "A abrir X" aparecia e depois nada — o erro do xdg-open em
    # falta ia para um stderr que ninguém vê (o launcher corre de um atalho).
    if ! command -v xdg-open &>/dev/null; then
        notify "$(t err_no_opener)" "$(t err_no_opener_body)"
        return 1
    fi
    notify "$(t opening) $name" "$url" -i "web-browser"
    if command -v uwsm &>/dev/null && uwsm check is-active &>/dev/null; then
        uwsm app -- xdg-open "$url" &
    else
        xdg-open "$url" &>/dev/null &
    fi
}

launch_tool() {
    local id="$1"
    local -a _args=()
    read -ra _args <<< "${TOOL_ARGS[$id]:-}"
    if [[ "${TOOL_CAT[$id]}" == "cli" ]]; then
        # launch_term entrega a string ao "fish -i -c": cada palavra tem de ir
        # escapada, senão um argumento do .conf executa como código.
        local _cmd _a
        _cmd="$(printf '%q' "${TOOL_CMD[$id]}")"
        for _a in "${_args[@]}"; do _cmd+=" $(printf '%q' "$_a")"; done
        launch_term "${TOOL_NAME[$id]}" "$_cmd"
    else
        # launch_cmd faz "$@" sem shell — basta passar como palavras separadas.
        launch_cmd "${TOOL_CMD[$id]}" "${_args[@]}"
    fi
}

# Editores de terminal conhecidos abrem dentro do kitty; qualquer outro é
# tratado como gráfico. Ao contrário de uma lista de GUIs: um $VISUAL gráfico
# fora da lista (subl, gnome-text-editor…) abria um kitty vazio a correr uma
# janela gráfica. Procura com o PATH do fish, como as ferramentas — um nvim
# do brew também conta. EDITOR="code --wait" funciona (vira palavras); um
# editor num caminho com espaços não, como em qualquer $EDITOR.
edit_file() {
    local target="$1" ed bin
    local -a cmd=()
    for ed in "${VISUAL:-}" "${EDITOR:-}" zeditor code kate gedit gnome-text-editor nvim micro nano; do
        [[ -n "$ed" ]] || continue
        read -ra cmd <<< "$ed"
        bin="$(PATH="$(_fish_path)" command -v -- "${cmd[0]}" 2>/dev/null)" || continue
        cmd[0]="$bin"
        case "${bin##*/}" in
            nvim|vim|vi|nano|micro|hx|helix|kak|emacs|ne|joe|mcedit)
                if command -v kitty &>/dev/null; then
                    launch_cmd kitty "${cmd[@]}" "$target"
                    return
                fi
                continue   # editor de terminal sem terminal — tenta o próximo
                ;;
        esac
        launch_cmd "${cmd[@]}" "$target"
        return
    done
    launch_cmd xdg-open "$target"
}

# ── Detecção de ferramentas locais (tools.conf) ────────────────────────
# TOOL_CMD/TOOL_CAT/TOOL_NAME guardam, por id, o que foi realmente
# encontrado — o case de lançamento lê daqui em vez de ter um bloco
# hardcoded por ferramenta.
declare -A TOOL_CMD=()
declare -A TOOL_CAT=()
declare -A TOOL_NAME=()
declare -A TOOL_ARGS=()

# PATH do fish, obtido uma só vez. O Hyprland entrega aos processos um PATH
# mínimo; o config.fish é que acrescenta linuxbrew/nvm/pyenv. Sondar com este
# PATH em bash puro evita ~30 spawns de fish por abertura e, sobretudo, evita
# interpolar o campo do .conf dentro de uma string de shell.
_FISH_PATH=""
_fish_path() {
    if [[ -z "$_FISH_PATH" ]]; then
        # -i, como no lançamento (launch_term): quem monta o PATH dentro de
        # "if status is-interactive" ficaria de fora de um fish -c simples. O
        # marcador separa o PATH de qualquer coisa que o config.fish interativo
        # imprima (greeting, fastfetch…); </dev/null para ele nunca esperar input.
        if command -v fish &>/dev/null; then
            # shellcheck disable=SC2016  # $PATH é do fish, não do bash
            _FISH_PATH="$(fish -i -c 'printf "\n__HYPRAI_PATH__%s\n" (string join : $PATH)' \
                            </dev/null 2>/dev/null | sed -n 's/^__HYPRAI_PATH__//p' || true)"
        fi
        _FISH_PATH="${_FISH_PATH:+$_FISH_PATH:}$PATH"
    fi
    printf '%s' "$_FISH_PATH"
}

resolve_candidate() {
    local cand expanded hit
    IFS=';' read -ra _cands <<< "$1"
    for cand in "${_cands[@]}"; do
        trim_vars cand
        [[ -z "$cand" ]] && continue
        expanded="${cand/#\~/$HOME}"
        if [[ "$expanded" == /* ]]; then
            # -f além de -x: sem ele, uma DIRECTORIA passa na sondagem e a
            # ferramenta aparece no menu sem nunca abrir.
            [[ -f "$expanded" && -x "$expanded" ]] && { printf '%s' "$expanded"; return 0; }
        else
            hit="$(PATH="$(_fish_path)" command -v -- "$expanded" 2>/dev/null)" || true
            [[ -n "$hit" ]] && { printf '%s' "$hit"; return 0; }
        fi
    done
    return 1
}

# ── Menu principal ────────────────────────────────────────────────────
build_main() {
    ROW_TEXT=(); ROW_ID=(); ROW_ICON=()
    TOOL_CMD=(); TOOL_CAT=(); TOOL_NAME=(); TOOL_ARGS=()
    HAS_CLI=0; HAS_DESKTOP=0

    # Resolve o PATH do fish uma única vez no processo pai para que todas as
    # subshells herdadas não precisem de invocar o fish repetidamente.
    _fish_path >/dev/null

    declare -A seen_cats=()
    local tid ticon tname tdesc tcat tcands tsvg targs found
    local -a bad_cats=()
    if [[ -f "$TOOLS_CONF" ]]; then
        while IFS='|' read -r tid ticon tname tdesc tcat tcands tsvg targs || [[ -n "$tid" ]]; do
            trim_vars tid
            [[ -z "$tid" || "$tid" =~ ^# ]] && continue
            trim_vars ticon tname tdesc tcat tcands tsvg targs
            # Antes, uma categoria com erro de digitação virava um cabeçalho
            # com o texto cru e a ferramenta abria como "desktop" sem aviso.
            if [[ "$tcat" != cli && "$tcat" != desktop ]]; then
                bad_cats+=("$tid ($tcat)")
                continue
            fi

            found="$(resolve_candidate "$tcands")" || continue
            TOOL_CMD["$tid"]="$found"
            TOOL_CAT["$tid"]="$tcat"
            TOOL_NAME["$tid"]="$tname"
            TOOL_ARGS["$tid"]="$targs"
            [[ "$tcat" == "cli" ]] && HAS_CLI=1
            [[ "$tcat" == "desktop" ]] && HAS_DESKTOP=1
            if [[ -z "${seen_cats[$tcat]:-}" ]]; then
                case "$tcat" in
                    cli)     sep "$(t cat_cli)" ;;
                    desktop) sep "$(t cat_desktop)" ;;
                esac
                seen_cats["$tcat"]=1
            fi
            item "$ticon" "$tname" "$tdesc" "$tid" "$tsvg"
        done < "$TOOLS_CONF"
        # Uma notificação só, com todas — não uma por linha errada.
        if (( ${#bad_cats[@]} )); then
            local list; list="$(printf '%s, ' "${bad_cats[@]}")"
            notify "$(t err_bad_cat)" "$(t err_bad_cat_body "${list%, }")"
        fi
    fi

    sep "$(t cat_web)"
    local count=0
    if [[ -f "$SITES_CONF" ]]; then
        local sid_c _rest_c
        while IFS='|' read -r sid_c _rest_c || [[ -n "$sid_c" ]]; do
            trim_vars sid_c
            [[ -z "$sid_c" || "$sid_c" =~ ^# ]] && continue
            ((count++)) || true
        done < "$SITES_CONF"
    fi
    item "✨" "$(t name_ai_web)"         "$(t desc_ai_web "$count")" "__web__" "web-hub.svg"

    sep "$(t cat_config)"
    item "📝" "$(t edit_sites)"          "$(t desc_edit_sites)"      "__edit_sites__" "edit-sites.svg"
    item "🛠️" "$(t edit_tools)"          "$(t desc_edit_tools)"      "__edit_tools__" "edit-tools.svg"
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
            SEEN_WEB_CATS=()
            WEB_CAT_ORDER=()
            local sid sicon sname scat surl ssvg cat_label
            if [[ -f "$SITES_CONF" ]]; then
                while IFS='|' read -r sid sicon sname scat surl ssvg || [[ -n "$sid" ]]; do
                    trim_vars sid
                    [[ -z "$sid" || "$sid" =~ ^# ]] && continue
                    trim_vars sicon sname scat surl ssvg

                    if [[ -z "${SEEN_WEB_CATS[$scat]:-}" ]]; then
                        case "$scat" in
                            chat)   cat_label="$(t cat_chat)" ;;
                            search) cat_label="$(t cat_search)" ;;
                            write)  cat_label="$(t cat_write)" ;;
                            dev)    cat_label="$(t cat_dev)" ;;
                            code)   cat_label="$(t cat_code)" ;;
                            media)  cat_label="$(t cat_media)" ;;
                            *)      cat_label="$scat" ;;
                        esac
                        sep "$cat_label"
                        WEB_CAT_ORDER+=("$cat_label")
                        SEEN_WEB_CATS["$scat"]=1
                    fi
                    item "$sicon" "$sname" "" "$sid" "$ssvg"
                done < "$SITES_CONF"
            fi
        }

        while true; do
            build_web
            # Só entra na fileira quem realmente tem itens no sites.conf —
            # mesmo critério do MAIN_CHIP_LABELS: um chip apontando pra uma
            # secção vazia confunde mais do que ajuda.
            WEB_CHIPS="$(chips_row "${WEB_CAT_ORDER[@]}")"
            # Linha 0 é "Voltar"; o cursor abre no primeiro site real (linha 2,
            # depois do primeiro cabeçalho).
            WIDX=$(run_menu "🌐 $(t web_hub_title)" 2 "$WEB_CHIPS") || exit 0
            [[ "${WIDX:-}" =~ ^[0-9]+$ ]] || exit 0
            SEL="${ROW_ID[$WIDX]:-}"
            # Se for um cabeçalho de secção (id vazio), reabre o submenu em vez de sair
            [[ -z "$SEL" ]] && continue
            if [[ "$SEL" == "__back__" ]]; then exec "$0"; fi

            # Extrai URL e nome do site selecionado
            TARGET_URL=""
            TARGET_NAME=""
            while IFS='|' read -r sid sicon sname scat surl ssvg || [[ -n "$sid" ]]; do
                trim_vars sid
                if [[ "$sid" == "$SEL" ]]; then
                    trim_vars sname surl
                    TARGET_URL="$surl"
                    TARGET_NAME="$sname"
                    break
                fi
            done < "$SITES_CONF"

            if [[ -n "$TARGET_URL" ]]; then
                launch_web "$TARGET_URL" "$TARGET_NAME"
            fi
            break
        done
        ;;
    __edit_sites__)
        edit_file "$SITES_CONF"
        ;;
    __edit_tools__)
        edit_file "$TOOLS_CONF"
        ;;
    *)
        # $ID não vazio chegou até aqui (a checagem lá em cima já cobriu o
        # caso de cabeçalho de secção) — só falta ser uma ferramenta do
        # tools.conf detectada em build_main().
        if [[ -n "${TOOL_CMD[$ID]:-}" ]]; then
            launch_tool "$ID"
        else
            # Estava no menu há segundos (detectado em build_main) e sumiu
            # até o clique — janela de tempo mínima, mas cobre o caso.
            notify "$(t err_tool_missing)" "$(t err_tool_missing_body)"
        fi
        ;;
esac
