# 🎨 Hypr.AI · Design

Este tema segue o sistema **coherent-design** — grid fechado, raios concêntricos, paleta OKLCH
verificada. Este documento registra os números usados e o porquê, para quem for mexer no
`rofi/hyprai.rasi` depois.

## Camadas

A janela do Rofi **é** a camada funcional/glass (flutua sobre o desktop, translúcida, com o
blur do compositor por trás). Inputbar, a fileira de categorias (`message`) e a linha
selecionada são a camada de conteúdo — por isso não levam blur próprio, só materiais
sólidos/semitransparentes **mais claros que o vidro por trás** (`bg1`, `bg2`). É essa diferença
de tom entre as duas camadas, não uma sombra, que faz o vidro ler-se com profundidade — o mesmo
princípio do `--bg-elev` do coherent-design ("superfícies que avançam usam um fundo mais claro
que a base").

A janela tem ainda um realce (`rim-top`) só na borda de cima — `border: 1.5px 0px 0px 0px` —
porque um vidro real só capta luz por cima. Borda nos quatro lados é o que faz translucidez
ler-se como caixa cinzenta em vez de vidro.

## Opacidade do vidro (e por que o screenshot mente)

`bg0` está a **70%** (`B3`), não a 95%. Isto não é gosto, é o limite físico do efeito:

- O blur do compositor transforma o que está atrás numa **mancha uniforme** — é literalmente
  o que blur faz. Uma mancha uniforme só se vê se houver luz suficiente a atravessar.
- A 95% de opacidade sobram 5% — 5% de mancha uniforme é indistinguível de tinta chapada.
  Resultado: **quanto melhor o blur funciona, mais opaco o painel parece.**
- Acima de ~85% o efeito desaparece por completo. A faixa que funciona aqui é **65–75%**.

**Um screenshot não serve para validar isto.** O `grim` (wlr-screencopy) captura o buffer
antes do pipeline de blur, por isso naqueles mesmos 5% aparece wallpaper *nítido* — com
textura e gradiente, que o olho lê como vidro. A tela real mostra wallpaper *borrado*. As
duas imagens são diferentes e ambas estão "certas"; só a tela real conta.

Sintoma de que está calibrado: screenshot e tela real passam a mostrar a mesma coisa.

Nada disto funciona sem o `layer_rule` para o namespace `rofi` no Hyprland (o `install.sh`
pergunta antes de o adicionar) — camadas layer-shell não recebem blur por omissão, e sem ele
nenhum valor de alpha resolve.

E nessa regra o **`xray` tem de ficar `false`**, ao contrário da regra equivalente do Noctalia
(de onde esta foi copiada, e onde o `xray = true` faz sentido). O `xray` manda o blur saltar as
camadas intermédias e ir buscar o fundo — mas neste desktop o wallpaper *é* uma dessas camadas
(`noctalia-wallpaper`, a ocupar o ecrã inteiro), e o mesmo vale para os widgets de desktop que
caiam atrás do menu. Com `xray = true`, o blur salta exactamente aquilo que devia desfocar: o
wallpaper atravessa nítido pela transparência e o vidro desaparece — sem erro, sem aviso, e de
forma intermitente (depende de que widgets estão por trás naquele instante). O `install.sh`
avisa se encontrar uma regra antiga com `xray = true`.

## Grid

| Elemento | Valor | Token |
|---|---|---|
| Padding da `mainbox` | 16px | `space-4` |
| Padding do `inputbar` | 12px / 16px | `space-3` / `space-4` |
| Padding do `element` (linha da lista) | 12px / 12px | `space-3` |
| Espaço entre linhas da lista | 2px | `space-0` |
| Margem acima de `message`/`listview` | 12px | `space-3` |

As linhas ficam a 2px umas das outras e o grupo respira com os 12px acima da lista — espaço
entre itens sempre menor que o espaço à volta do grupo, que é o que faz o agrupamento ler-se
sem desenhar caixas.

## Raios (concêntricos)

`janela (24, r-xl) − padding da mainbox (16) = 8` → todo filho direto (`inputbar`, `element`,
`message`) usa **8px**. A `error-message` funciona como painel próprio (não filho da mainbox)
e usa **16px** (`r-lg`). O scrollbar é um controle compacto → capsule (`999px`).

## Tipografia

**SF Pro Text**, a fonte do sistema deste desktop (Qt e GTK). Proporcional, não monoespaçada:
mono num launcher lê como terminal, e aqui nada é literal de código. 11pt ≈ 15px, a densidade
desktop do coherent-design; o subtexto usa `size="small"` do Pango (≈9pt).

Nomes em capitalização normal com o fornecedor em subtexto — **"Claude Code" / "Anthropic"**,
não "CLAUDE CODE CLI". Maiúsculas destroem a forma da palavra, que é o que torna uma lista
rápida de percorrer.

Os cabeçalhos de secção são texto pequeno e discreto, sem preenchimento, sem moldura e sem os
traços `──`. O elemento menos importante do ecrã não leva o tratamento mais pesado.

## Seleção

Preenchimento com o **accent tingido a 12%** (`sel`), não sólido, com o texto a manter a cor
normal — como o Spotlight e as listas do macOS. O accent cheio fica reservado ao prompt e ao
scrollbar.

Uma barra de accent sólida à largura toda, para um estado de cursor, é o que fazia a interface
parecer pesada. O accent deve ocupar pouca área; a hierarquia vem do preenchimento, não da
saturação.

O cursor abre na **linha 1** (`-selected-row`), não na 0, porque a 0 é um cabeçalho de secção —
caso contrário a primeira coisa que se vê é um cabeçalho selecionado.

## Identificadores

As linhas não mostram `[id]`. O Rofi devolve o índice (`-format i`) e o `launcher.sh` mapeia
índice → id em arrays paralelos. Um índice sem id é um cabeçalho de secção e reabre o menu.

## Paleta

Gerada e verificada com `scripts/palette.py --hue 285 --accent 292` do coherent-design — hue
285 é o neutro (leve tinta violeta, nunca cinza puro), 292 é o accent. Todos os pares batem
≥4.5:1 em modo escuro (único modo — este é um launcher utilitário, não um app com tema
alternável).

| Token | Hex | Papel |
|---|---|---|
| `bg0` | `#0D0D10` @ 70% | Fundo da janela (glass) — ver "Opacidade do vidro" |
| `bg1` | `#1C1C21` @ 90% | Elevação — inputbar, badge, chip de ícone |
| `bg2` | `#18181C` @ 60% | Agrupamento secundário (`message`) |
| `bg3` | `#A18DEE` @ 95% | Accent — única cor de destaque |
| `fg0` | `#F5F5F8` | Texto primário — 17.8:1 |
| `fg2` | `#9E9EA3` | Texto secundário/placeholder — 7.3:1 |
| `fg3` | `#6E6E74` | Terciário — só em uso decorativo (separadores) |
| `accent-fg` | `#262626` | Texto sobre `bg3` |
| `error` | `#E97871` @ 95% | Borda de erro — 6.8:1 |
| `sel` | `#A18DEE` @ 12% | Preenchimento da seleção — o accent tingido, não sólido |
| `chip-bg` | `#A18DEE` @ 14% | "Container" tonal — pílulas de categoria e ícone de cada linha |
| `chip-fg` | = `fg2` | Texto/ícone sobre `chip-bg` |
| `rim-top` | `#F5F5F8` @ 22% | Realce de vidro — só a borda de cima da janela e do inputbar |

## Cor tonal dinâmica

**Todos os neutros seguem o wallpaper agora, não só o accent.** `bg0…fg3`, `chip-bg`/`chip-fg`
e `rim-top` vêm juntos do mesmo esquema tonal quando o Noctalia/Caelestia estão presentes — só
sem nenhum dos dois é que entra a tabela estática acima.

A razão da mudança: com só o accent dinâmico e o resto fixo, o launcher lia como um chrome
alheio ao resto do desktop assim que o Noctalia/Caelestia pintam tudo o resto (GTK, Qt, barra)
num esquema diferente do violeta fixo daqui. Seguir o esquema inteiro é o que faz o launcher
parecer parte do mesmo sistema, não um widget emprestado.

`theme/noctalia.rasi.tmpl` mapeia os papéis M3 (Material You) para os tokens acima —
`background`→`bg0`, `surface_container_high`→`bg1` (a elevação, mais clara que `bg0`),
`surface_container`→`bg2`, `primary`→`bg3`, `on_background`→`fg0`,
`on_surface_variant`→`fg2`, `outline`→`fg3`/`sep`, `on_primary`→`accent-fg`,
`primary_container`/`on_primary_container`→`chip-bg`/`chip-fg` (o "container" tonal do M3 —
por isso as pílulas de categoria acompanham o accent do wallpaper em vez de um azul fixo).

Em runtime, `launcher.sh` decide, em ordem:

1. `~/.local/state/hyprai/noctalia-colors.rasi` — o Noctalia já renderizou o `.tmpl` inteiro
   (todos os tokens, não só o accent); `launcher.sh` só repassa o arquivo via `-theme-str`.
2. `~/.local/state/caelestia/scheme.json` (compat) — JSON bruto, sem passar por um `.tmpl`;
   `launcher.sh` remonta o mesmo bloco de tokens à mão a partir dos papéis M3 que o scheme
   expõe (`background`, `onBackground`, `surfaceContainerHigh`, `primary`, `primaryContainer`
   etc.). Se faltarem os papéis de neutro, cai para um compat mínimo — só o accent.
3. Nenhum dos dois → fica a paleta estática da tabela.

Antes de aplicar, há uma **guarda de brilho** sobre o accent: um `primary` escuro a mais rejeita
o esquema inteiro (fica o violeta estático), porque um wallpaper que produz um accent ilegível
tende a produzir o resto do esquema igualmente ruim. Brilho percebido em aritmética inteira —
aproximação grosseira, mas chega para apanhar os casos maus sem puxar uma dependência de Python
só por isto.

**Depois de mexer em `theme/noctalia.rasi.tmpl`, o Noctalia só re-renderiza o `.tmpl` numa
troca de wallpaper/scheme** — não ao editar o arquivo. Force uma troca (ou reaplique o esquema
atual) para o `~/.local/state/hyprai/noctalia-colors.rasi` regenerar com os tokens novos;
até lá, os tokens que ainda não existem no arquivo gerado (`chip-bg`, `chip-fg`, `rim-top`,
por exemplo, na primeira vez que forem adicionados) caem de volta para o estático da tabela,
sem quebrar nada.

A estrutura do tema (grid, raios concêntricos, tipografia, hierarquia) nunca muda — só os
valores dos tokens.

## O que não se aplica aqui

Rofi não tem sistema de motion/transição, então a seção de motion do coherent-design não se
aplica: a entrada/saída da janela é a animação de abertura de janela do próprio Hyprland
(`animations.lua`), já compartilhada com o resto do desktop.

Pelo mesmo motivo não há *scroll edge effect* — o Rofi não expõe o estado de scroll ao tema, e
o inputbar não tem como ganhar separação quando a lista corre por baixo.
