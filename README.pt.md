# Hypr.AI

🇵🇹 **Português** · [🇬🇧 English](README.md) · [🇪🇸 Español](README.es.md) · [🇨🇳 简体中文](README.zh.md)

<p align="center"><img src="assets/screenshot.webp" alt="Hypr.AI — todas as ferramentas de IA da tua máquina a uma tecla de distância"></p>

**Launcher de IA nativo para Hyprland** — agentes CLI, aplicações desktop e portais web curados, num único menu Rofi. Nada é fixo no código: as ferramentas só aparecem se estiverem mesmo instaladas, e a janela inteira acompanha a paleta Material You do teu wallpaper.

## Conteúdos

[Funcionalidades](#funcionalidades) · [Ferramentas detectadas](#ferramentas-detectadas) · [Requisitos](#requisitos) · [Instalação](#instalação) · [Utilização](#utilização) · [Configuração](#configuração) · [Adicionar ferramenta ou site](#adicionar-ferramenta-ou-site) · [Resolução de problemas](#resolução-de-problemas) · [Arquitectura](#arquitectura) · [Créditos](#créditos) · [Licença](#licença)

## Funcionalidades

- **Detecção em runtime** — agentes CLI e aplicações desktop são declarados no `tools.conf` como *candidatos*; o launcher testa cada um sempre que abre e mostra só o que existe. Instalas uma ferramenta e ela aparece sozinha; desinstalas e ela desaparece. Sem editar nada.
- **A detecção corre dentro do `fish`**, não em bash puro: o Hyprland entrega aos processos um `PATH` mínimo, por isso uma ferramenta instalada via linuxbrew/nvm/pyenv ficaria invisível mesmo funcionando perfeitamente. Testar na mesma shell que a lança mantém as duas alinhadas.
- **33 portais de IA curados** no `sites.conf`, agrupados em chat, pesquisa, escrita, dev, código e média — abrem no teu browser predefinido.
- **Cor tonal Material You**: a paleta inteira (fundos, texto, containers — não só o accent) vem em tempo real do [Noctalia](https://github.com/noctalia-dev/noctalia-shell), com o [Caelestia](https://github.com/caelestia-dots/shell) como alternativa. O menu parece parte do teu desktop, não um widget emprestado de outro tema.
- **Vidro a sério**, não uma caixa translúcida chapada: realce de luz só no topo, uma camada de conteúdo elevada tonalmente acima do fundo desfocado, e uma opacidade calibrada no ponto em que o blur do compositor se vê mesmo (ver [DESIGN.md](DESIGN.md)).
- **Ícones reais**: protocolo nativo de ícones do Rofi com SVG/PNG por entrada, caindo num chip de emoji quando não existe ficheiro de ícone.
- **Cinco idiomas** — pt-PT, pt-BR, es-ES, en-GB e 中文 — escolhidos pelo locale do sistema.
- **Design system fechado**: grelha de 4px, raios concêntricos, rótulos de uma palavra e paleta OKLCH com contraste WCAG verificado. Todos os números documentados em [DESIGN.md](DESIGN.md).
- **Integração com o Hyprland**: atalho global `Super + I`, funciona com `uwsm` ou Hyprland puro, e o instalador propõe adicionar a regra de camada sem a qual o vidro nem chega a aparecer.

## Ferramentas detectadas

Tudo o que está abaixo já vem pré-configurado como candidato e fica invisível até o instalares.

| Categoria | Ferramentas |
|---|---|
| Agentes CLI | Claude Code · Antigravity CLI · Gemini CLI · Codex CLI · Aider · GitHub Copilot CLI · Cursor CLI · OpenCode · Goose · Ollama · Qwen Code · Crush · Mods · Plandex · Droid · OpenHands · Cline · Hermes |
| Aplicações desktop | Claude Desktop · Antigravity 2.0 · Cursor · Windsurf · Zed · LM Studio · Jan · GPT4All · AnythingLLM · Chatbox · Msty · Hermes Desktop |
| Portais web | 33 sites — Gemini, Claude, ChatGPT, DeepSeek, Grok, Kimi, Qwen, Mistral, Copilot, Perplexity, v0, Lovable, Midjourney, Suno, ElevenLabs, Runway e mais |

O que não estiver na lista leva uma linha no `tools.conf` — ver [Adicionar ferramenta ou site](#adicionar-ferramenta-ou-site).

## Requisitos

- Hyprland
- rofi (1.7+, pelo protocolo de ícones)
- bash, e **fish** — os agentes CLI abrem dentro do `kitty` a correr a tua fish interactiva, que é também o que faz a detecção ver o teu `PATH` real
- **Recomendado:** [Noctalia](https://github.com/noctalia-dev/noctalia-shell) ou [Caelestia](https://github.com/caelestia-dots/shell) — sem nenhum dos dois, o menu cai numa paleta violeta escura fixa
- Opcional: libnotify (notificações), uwsm (isolamento de sessão)

## Instalação

```bash
git clone https://github.com/mastermaiolo/hyprai && cd hyprai
./install.sh
```

O instalador copia tudo para `~/.config/hypr/hyprai/`, cria o executável `hyprai` em `~/.local/bin/`, regista a ponte tonal no Noctalia, adiciona o atalho `Super + I` (perguntando por outra tecla se essa combinação já estiver ocupada) e **pergunta** antes de acrescentar uma regra de camada de vidro ao teu `windowrules.lua`. Nunca mexe no blur global.

> Depois de instalar, muda de wallpaper ou de accent no Noctalia uma vez, para ele gerar a ponte de cor pela primeira vez.

## Utilização

- `Super + I` — abrir o menu
- `hyprai` — o mesmo, a partir de um terminal
- Escreve para filtrar; `Enter` abre; `Esc` fecha
- **Portais Web** abre um submenu; `↩ Voltar` regressa

## Configuração

Dois ficheiros declarativos em texto simples, ambos editáveis a partir do menu:

| Ficheiro | O que guarda |
|---|---|
| `~/.config/hypr/hyprai/config/tools.conf` | Agentes CLI e aplicações desktop, com os candidatos de detecção |
| `~/.config/hypr/hyprai/config/sites.conf` | Portais web curados, agrupados por categoria |

> O `install.sh` **não sobrescreve** estes dois ficheiros ao reinstalar — a tua curadoria sobrevive às actualizações. Ao alterá-los no repositório, copia-os à mão.

## Adicionar ferramenta ou site

**Uma ferramenta local** (`tools.conf`):

```conf
id | ícone | Nome | Subtexto | categoria | candidatos | svg | args
```

- `categoria` — `cli` (corre num terminal kitty) ou `desktop` (aplicação gráfica)
- `candidatos` — um ou mais binários/caminhos separados por `;`, testados por ordem; o primeiro que existir ganha e passa a ser o comando de arranque. Um nome solto é procurado no `PATH`; um caminho absoluto (ou começado por `~`) é testado directamente
- `args` — argumentos fixos opcionais, para quando um binário serve o CLI e a GUI:

```conf
hermes_cli|🪽|Hermes|Nous Research|cli|hermes|hermes.png|chat
hermes_desktop|🪽|Hermes Desktop|Nous Research|desktop|hermes|hermes-agent-text.svg|desktop
```

**Um portal web** (`sites.conf`):

```conf
id | ícone | Nome | categoria | https://url | svg
```

Categorias: `chat`, `search`, `write`, `dev`, `code`, `media`.

Nos dois ficheiros, a coluna `svg` nomeia um ficheiro dentro de `svg/` (PNG também funciona) e cai no emoji da segunda coluna.

## Resolução de problemas

**Uma ferramenta que tenho instalada não aparece.** O nome do binário em `candidatos` provavelmente não corresponde ao teu — confirma com `which <nome>` e ajusta a linha. A detecção falha em silêncio de propósito: um nome errado deixa apenas a entrada invisível.

**O menu está opaco, sem vidro.** Três causas, por ordem:
1. Falta a regra de camada — superfícies layer-shell não recebem blur no Hyprland sem uma regra que aponte ao namespace. Corre `./install.sh` outra vez e aceita a excepção de vidro.
2. `xray = true` nessa regra — corre `./install.sh`, que agora avisa. O xray manda o blur saltar as camadas intermédias e ir buscar o fundo, mas em desktops onde o wallpaper *é* uma camada (o do Noctalia, por exemplo) ele salta justamente o que devia desfocar: o wallpaper atravessa nítido e o vidro desaparece, sem erro nenhum. Widgets de desktop atrás do menu ficam sem blur pela mesma razão.
3. Opacidade alta demais — acima de ~85% o blur fica sem luz para contribuir e o painel lê-se como tinta chapada. O `bg0` vem a 70%.

**Uma screenshot mostra vidro mas o meu ecrã não.** São mesmo diferentes: o `grim` captura antes do passo de blur do compositor, por isso esses poucos % de transparência mostram um wallpaper *nítido* (que se lê como vidro), enquanto o teu ecrã mostra um *desfocado* (uniforme, lê-se como tinta). Confia nos olhos, não na screenshot — quando está bem calibrado, as duas coincidem.

**As cores não acompanham o wallpaper.** O Noctalia só regenera o template numa mudança de wallpaper/esquema. Força com `noctalia msg config-reload && noctalia msg templates-apply`.

## Arquitectura

```
hyprai/
├── config/
│   ├── sites.conf        # Portais web curados
│   └── tools.conf        # Agentes CLI/apps desktop — testados em runtime
├── rofi/
│   └── hyprai.rasi       # Tema — grelha, raios e paleta
├── svg/                  # Ícones por entrada (protocolo do Rofi)
├── theme/
│   └── noctalia.rasi.tmpl # Template que o Noctalia rende na ponte tonal
├── ui/
│   └── launcher.sh       # O launcher em si
├── install.sh
├── uninstall.sh
└── DESIGN.md             # Tokens e o porquê de cada número
```

As linhas são construídas em arrays paralelos (texto, id, ícone) e entregues ao `rofi -dmenu -format i`, por isso o índice devolvido mapeia de volta para um id sem nunca aparecer no ecrã. A ponte tonal é um fragmento `.rasi` que o Noctalia regenera a cada mudança de esquema; o `launcher.sh` repassa-o com `-theme-str`, pelo que mudar de cor não exige reiniciar nada.

## Créditos

Construído sobre a arquitectura, ergonomia e convenções de design do [HyprVision](https://github.com/mastermaiolo/hyprvision).

Layout, espaçamento, paleta e contraste seguem o sistema **coherent-design** — ver [DESIGN.md](DESIGN.md) para os tokens e o raciocínio.

## Licença

MIT
