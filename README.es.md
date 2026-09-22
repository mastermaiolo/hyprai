# Hypr.AI

[🇵🇹 Português](README.pt.md) · [🇬🇧 English](README.md) · 🇪🇸 **Español** · [🇨🇳 简体中文](README.zh.md)

[![Release](https://img.shields.io/github/v/release/mastermaiolo/hyprai?label=versi%C3%B3n)](https://github.com/mastermaiolo/hyprai/releases/latest)

<p align="center"><img src="assets/screenshot.webp" alt="Hypr.AI — todas las herramientas de IA de tu máquina a una tecla de distancia"></p>

**Lanzador de IA nativo para Hyprland** — agentes CLI, aplicaciones de escritorio y portales web curados en un único menú Rofi. Nada está fijado en el código: las herramientas solo aparecen si están realmente instaladas, y toda la ventana sigue la paleta Material You de tu fondo de pantalla.

## Contenidos

[Funciones](#funciones) · [Herramientas detectadas](#herramientas-detectadas) · [Requisitos](#requisitos) · [Instalación](#instalación) · [Uso](#uso) · [Configuración](#configuración) · [Añadir herramienta o sitio](#añadir-herramienta-o-sitio) · [Solución de problemas](#solución-de-problemas) · [Arquitectura](#arquitectura) · [Créditos](#créditos) · [Licencia](#licencia)

## Funciones

- **Detección en tiempo de ejecución** — los agentes CLI y las aplicaciones de escritorio se declaran en `tools.conf` como *candidatos*; el lanzador comprueba cada uno cada vez que se abre y muestra solo lo que existe. Instalas una herramienta y aparece sola; la desinstalas y desaparece. Sin editar nada.
- **La detección se ejecuta dentro de `fish`**, no en bash puro: Hyprland entrega a los procesos un `PATH` mínimo, por lo que una herramienta instalada vía linuxbrew/nvm/pyenv quedaría invisible aunque funcione perfectamente. Comprobar en la misma shell que la lanza mantiene ambas alineadas.
- **33 portales de IA curados** en `sites.conf`, agrupados en chat, búsqueda, escritura, dev, código y medios — se abren en tu navegador predeterminado.
- **Color tonal Material You**: toda la paleta (fondos, texto, contenedores — no solo el color de acento) se toma en vivo de [Noctalia](https://github.com/noctalia-dev/noctalia-shell), con [Caelestia](https://github.com/caelestia-dots/shell) como alternativa. El menú parece parte de tu escritorio, no un widget prestado de otro tema.
- **Cristal de verdad**, no una caja translúcida plana: un reflejo de luz solo en el borde superior, una capa de contenido elevada tonalmente sobre el fondo desenfocado, y una opacidad calibrada en el punto donde el desenfoque del compositor realmente se aprecia (ver [DESIGN.md](DESIGN.md)).
- **Iconos reales**: protocolo nativo de iconos de Rofi con SVG/PNG por entrada, con un chip de emoji como respaldo cuando no existe archivo de icono.
- **Cinco idiomas** — pt-PT, pt-BR, es-ES, en-GB y 中文 — elegidos según la configuración regional del sistema.
- **Sistema de diseño cerrado**: rejilla base con espaciado consistente, radios concéntricos, etiquetas de una palabra y paleta OKLCH con contraste WCAG verificado. Cada número está documentado en [DESIGN.md](DESIGN.md).
- **Integración con Hyprland**: atajo global `Super + I`, funciona con `uwsm` o Hyprland puro, y el instalador ofrece añadir la regla de capa sin la cual el cristal ni siquiera llega a mostrarse.

## Herramientas detectadas

Todo lo siguiente viene preconfigurado como candidato y permanece invisible hasta que lo instales.

| Categoría | Herramientas |
|---|---|
| Agentes CLI | Claude Code · Antigravity CLI · Gemini CLI · Codex CLI · Aider · GitHub Copilot CLI · Cursor CLI · OpenCode · Goose · Ollama · Qwen Code · Crush · Mods · Plandex · Droid · OpenHands · Cline · Hermes |
| Apps de escritorio | Claude Desktop · Antigravity 2.0 · Cursor · Windsurf · Zed · LM Studio · Jan · GPT4All · AnythingLLM · Chatbox · Msty · Hermes Desktop |
| Portales web | 33 sitios — Gemini, Claude, ChatGPT, DeepSeek, Grok, Kimi, Qwen, Mistral, Copilot, Perplexity, v0, Lovable, Midjourney, Suno, ElevenLabs, Runway y más |

Lo que no esté en la lista ocupa una línea en `tools.conf` — ver [Añadir herramienta o sitio](#añadir-herramienta-o-sitio).

## Requisitos

- Hyprland
- rofi (1.7+, por el protocolo de iconos)
- bash, y **fish** — los agentes CLI se abren dentro de `kitty` ejecutando tu fish interactiva, que es también lo que hace que la detección vea tu `PATH` real
- **Recomendado:** [Noctalia](https://github.com/noctalia-dev/noctalia-shell) o [Caelestia](https://github.com/caelestia-dots/shell) — sin ninguno de los dos, el menú recurre a una paleta violeta oscura fija
- Opcional: libnotify (notificaciones), uwsm (aislamiento de sesión)

## Instalación

```bash
git clone https://github.com/mastermaiolo/hyprai && cd hyprai
./install.sh
```

El instalador copia todo a `~/.config/hypr/hyprai/`, crea el ejecutable `hyprai` en `~/.local/bin/`, registra el puente tonal en Noctalia (si está instalado), añade el atajo `Super + I` a `binds.lua` (si el archivo existe, preguntando por otra tecla si esa combinación ya está ocupada) y **pregunta** antes de añadir una regla de capa de cristal a tu `windowrules.lua`. Nunca toca tu desenfoque global.

> Después de instalar, cambia de fondo de pantalla o de color de acento en Noctalia una vez, para que genere el puente de color por primera vez.

## Uso

- `Super + I` — abrir el menú
- `hyprai` — lo mismo, desde una terminal
- Escribe para filtrar; `Enter` abre; `Esc` cierra
- **Portales web** abre un submenú; `↩ Volver` regresa

## Configuración

Dos archivos declarativos en texto sencillo, ambos editables desde el propio menú:

| Archivo | Qué contiene |
|---|---|
| `~/.config/hypr/hyprai/config/tools.conf` | Agentes CLI y apps de escritorio, con los candidatos de detección |
| `~/.config/hypr/hyprai/config/sites.conf` | Portales web curados, agrupados por categoría |

> `install.sh` **no sobrescribe** estos dos archivos al reinstalar — tu curación sobrevive a las actualizaciones. Al cambiarlos en el repositorio, cópialos a mano.

## Añadir herramienta o sitio

**Una herramienta local** (`tools.conf`):

```conf
id | icono | Nombre | Subtexto | categoría | candidatos | svg | args
```

- `categoría` — `cli` (se ejecuta en una terminal kitty) o `desktop` (app gráfica)
- `candidatos` — uno o más binarios/rutas separados por `;`, comprobados en orden; el primero que exista gana y pasa a ser el comando de arranque. Un nombre suelto se busca en el `PATH`; una ruta absoluta (o que empiece por `~`) se comprueba directamente
- `args` — argumentos fijos opcionales, para cuando un mismo binario sirve al CLI y a la GUI:

```conf
hermes_cli|🪽|Hermes|Nous Research|cli|hermes|hermes.png|chat
hermes_desktop|🪽|Hermes Desktop|Nous Research|desktop|hermes|hermes-agent-text.svg|desktop
```

**Un portal web** (`sites.conf`):

```conf
id | icono | Nombre | categoría | https://url | svg
```

Categorías: `chat`, `search`, `write`, `dev`, `code`, `media`.

En ambos archivos, la columna `svg` nombra un archivo dentro de `svg/` (PNG también funciona) y recurre al emoji de la segunda columna.

## Solución de problemas

**Una herramienta que tengo instalada no aparece.** El nombre del binario en `candidatos` probablemente no coincide con el tuyo — compruébalo con `which <nombre>` y ajusta la línea. La detección falla en silencio a propósito: un nombre equivocado solo deja la entrada invisible.

**El menú se ve opaco, sin cristal.** Tres causas, por orden:
1. Falta la regla de capa — las superficies layer-shell no reciben desenfoque en Hyprland sin una regla que apunte a su namespace. Vuelve a ejecutar `./install.sh` y acepta la excepción de cristal.
2. `xray = true` en esa regla — vuelve a ejecutar `./install.sh`, que ahora avisa. xray le dice al desenfoque que salte las capas intermedias y tome el fondo, pero en escritorios donde el fondo de pantalla *es* una capa (el de Noctalia, por ejemplo) salta justamente lo que debería desenfocar: el fondo atraviesa nítido y el cristal desaparece, sin ningún error. Los widgets de escritorio detrás del menú quedan sin desenfoque por la misma razón.
3. Opacidad demasiado alta — por encima de ~85% el desenfoque se queda sin luz que aportar y el panel se lee como pintura plana. `bg0` viene al 70%.

**Una captura muestra cristal pero mi pantalla no.** Son realmente distintas: `grim` captura antes del paso de desenfoque del compositor, así que ese pequeño porcentaje de transparencia muestra un fondo *nítido* (que se lee como cristal), mientras que tu pantalla muestra uno *desenfocado* (uniforme, se lee como pintura). Confía en tus ojos, no en la captura — cuando está bien calibrado, ambas coinciden.

**Los colores no siguen mi fondo de pantalla.** Noctalia solo vuelve a renderizar la plantilla al cambiar de fondo/esquema. Fuérzalo con `noctalia msg config-reload && noctalia msg templates-apply`.

## Arquitectura

```
hyprai/
├── config/
│   ├── sites.conf        # Portales web curados
│   └── tools.conf        # Agentes CLI/apps de escritorio — comprobados en runtime
├── rofi/
│   └── hyprai.rasi       # Tema — rejilla, radios y paleta
├── svg/                  # Iconos por entrada (protocolo de Rofi)
├── theme/
│   └── noctalia.rasi.tmpl # Plantilla que Noctalia renderiza en el puente tonal
├── ui/
│   └── launcher.sh       # El lanzador en sí
├── install.sh
├── uninstall.sh
└── DESIGN.md             # Tokens y el razonamiento detrás de cada número
```

Las filas se construyen como arrays paralelos (texto, id, icono) y se entregan a `rofi -dmenu -format i`, de modo que el índice devuelto se asigna de nuevo a un id sin llegar a mostrarse nunca en pantalla. El puente tonal es un fragmento `.rasi` que Noctalia regenera en cada cambio de esquema; `launcher.sh` lo pasa directamente con `-theme-str`, así que cambiar de color no requiere reiniciar nada.

## Créditos

Construido sobre la arquitectura, la ergonomía y las convenciones de diseño de [HyprVision](https://github.com/mastermaiolo/hyprvision).

Disposición, espaciado, paleta y contraste siguen el sistema **coherent-design** — ver [DESIGN.md](DESIGN.md) para los tokens y el razonamiento.

## Licencia

MIT
