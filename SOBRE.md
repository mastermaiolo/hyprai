# 🧠 Hypr.AI · Guia do Projecto

Este documento explica **o que é**, **para que serve** e sobretudo **porque foi
construído assim**. O [README](README.pt.md) cobre a utilização; aqui ficam as
decisões de engenharia e o raciocínio por trás delas — incluindo as que só se
percebem depois de bater com a cabeça na parede.

---

## 📌 1. O que é

O **Hypr.AI** é um launcher nativo para Wayland/Hyprland, accionado via
[Rofi](https://github.com/davatorium/rofi), que reúne todo o ecossistema de IA
numa interface teclado-cêntrica, dividida em três pilares:

1. **Agentes de linha de comando (CLI)**, abertos no Kitty com a fish shell;
2. **Aplicações desktop** (IDEs, clientes locais de modelos);
3. **Portais web de IA**, abertos no browser predefinido.

---

## 🎯 2. Para que serve

No dia-a-dia com IA, alterna-se constantemente entre agentes de terminal, IDEs
pesadas e uma dúzia de separadores no browser. O Hypr.AI resolve essa
fragmentação:

- **Acesso imediato**: `Super + I` a partir de qualquer lado;
- **Zero fricção de terminal**: os agentes arrancam dentro de instâncias
  dedicadas do Kitty, com a tua fish e o teu ambiente intactos;
- **Nada fixo no código**: ferramentas e sites vivem em ficheiros de texto
  declarativos, editáveis a partir do próprio menu;
- **Só mostra o que existe**: uma ferramenta aparece quando a instalas e
  desaparece quando a removes, sem configuração nenhuma.

---

## 🛠️ 3. Como foi construído

Tomou como referência a arquitectura, a ergonomia e as convenções do
[HyprVision](https://github.com/mastermaiolo/hyprvision), adaptadas para gerir
aplicações e ligações em vez de perfis de cor.

### 🏛️ Estrutura

```
hyprai/
├── config/
│   ├── sites.conf         # Portais web curados
│   └── tools.conf         # Agentes CLI/apps desktop — candidatos a detectar
├── rofi/
│   └── hyprai.rasi        # Tema — grelha, raios e paleta
├── svg/                   # Ícones por entrada (protocolo do Rofi)
├── theme/
│   └── noctalia.rasi.tmpl # Template que o Noctalia rende na ponte tonal
├── ui/
│   └── launcher.sh        # O launcher
├── assets/                # Captura usada nos READMEs
├── install.sh             # Instalação, atalho e registo no Noctalia
├── uninstall.sh           # Remoção simétrica
├── DESIGN.md              # Tokens e o porquê de cada número
└── README*.md             # Documentação (pt, en, es, zh)
```

### 🔍 3.1. Detecção em runtime — a decisão central

As ferramentas **não estão escritas no código**. O `tools.conf` declara
*candidatos*, e o launcher testa cada um sempre que abre:

```conf
id | ícone | Nome | Subtexto | categoria | candidatos | svg | args
```

O campo `candidatos` aceita vários binários/caminhos separados por `;`; o
primeiro que existir ganha e passa a ser o comando de arranque. Falhar é
silencioso de propósito: um nome errado deixa a entrada invisível, nunca uma
entrada morta que rebenta ao clicar.

**A parte não óbvia:** a sondagem usa o `PATH` do `fish` interactivo, não o do
Hyprland. O Hyprland entrega aos processos um `PATH` mínimo (`~/.local/bin`,
`~/.cargo/bin` — ver `~/.config/uwsm/env`), que não inclui o que o `config.fish`
acrescenta (linuxbrew, nvm, pyenv). Como o lançamento real já acontece dentro de
`fish -i`, sondar com outro `PATH` criava uma assimetria absurda: a ferramenta
funcionava perfeitamente se fosse clicada, mas nunca chegava a aparecer para
ser clicada. Foi exactamente o que aconteceu com o Claude Code instalado via
`brew` em `/home/linuxbrew/.linuxbrew/bin`.

Na prática, o launcher pede o `PATH` ao `fish -i` **uma vez** por abertura e
sonda os candidatos em bash com esse `PATH` — em vez de ~30 arranques de fish
e sem interpolar campos do `.conf` numa string de shell. Tem de ser `-i`, e não
um `fish -c` simples: quem monta o `PATH` dentro de `if status is-interactive`
ficaria de fora, e a assimetria voltava por outra porta.

O campo `args` existe para o caso de um mesmo binário servir o CLI e a GUI —
`hermes chat` e `hermes desktop` são o mesmo candidato com argumentos
diferentes.

### 🎨 3.2. Design system e interface (`rofi/hyprai.rasi`)

Sistema coerente, não herança visual solta: grelha fechada de múltiplos de 4px,
raios concêntricos (janela `24px` → padding `16px` → filhos `8px`) e paleta
OKLCH gerada e verificada por script (contraste ≥4,5:1 em todo o texto). Ver
[DESIGN.md](DESIGN.md) para os tokens exactos.

Os rótulos de categoria são de **uma palavra** por decisão, não por acaso:
servem tanto aos chips como aos cabeçalhos de secção, e um rótulo longo parte a
fileira de chips em duas linhas desalinhadas.

### 🪟 3.3. O vidro — a parte contra-intuitiva

Três coisas têm de estar certas ao mesmo tempo, e falhar qualquer uma delas dá
o mesmo sintoma (painel opaco), sem erro nenhum:

1. **A regra de camada.** Superfícies layer-shell não recebem blur no Hyprland
   sem uma `layer_rule` que aponte ao namespace. O `install.sh` pergunta antes
   de a adicionar, e nunca toca no blur global.
2. **`xray = false` nessa regra.** O `xray` manda o blur saltar as camadas
   intermédias e ir buscar o fundo — mas em desktops onde o wallpaper *é* uma
   camada (o do Noctalia ocupa o ecrã inteiro), salta justamente aquilo que
   devia desfocar. O wallpaper atravessa nítido e o vidro desaparece, de forma
   intermitente conforme os widgets que estejam por trás.
3. **Opacidade a 70%, não a 95%.** Acima de ~85% o blur não tem luz suficiente
   para contribuir: o que está atrás vira uma mancha uniforme (é o que o blur
   faz) e o painel lê-se como tinta chapada. **Quanto melhor o blur funciona,
   mais opaco parece** se não houver transparência que chegue.

E um aviso que poupa horas: **uma screenshot não serve para validar isto.** O
`grim` captura antes do passo de blur do compositor, por isso os mesmos poucos
% de transparência mostram um wallpaper *nítido* (que se lê como vidro),
enquanto o ecrã real mostra um *desfocado*. Quando está calibrado, as duas
imagens coincidem — essa coincidência é o sinal de que está certo.

### 🌈 3.4. Cor tonal dinâmica

- **Noctalia (principal)**: o `install.sh` regista `theme/noctalia.rasi.tmpl`
  como *user template* em `~/.config/noctalia/config.toml`. O próprio Noctalia
  regenera `~/.local/state/hyprai/noctalia-colors.rasi` a cada mudança de
  wallpaper/esquema; o launcher lê esse ficheiro e injecta-o via `-theme-str`,
  sem polling nem script de conversão.
- **Caelestia (compatibilidade)**: sem Noctalia mas com
  `~/.local/state/caelestia/scheme.json`, o launcher remonta o mesmo bloco de
  tokens a partir dos papéis M3 que o scheme expõe.
- **Fallback estático**: sem nenhum dos dois, uma paleta *Dark Violet / Neon
  Indigo* verificada (`#A18DEE` sobre `#0D0D10`), com o mesmo mapeamento de
  tokens — trocar a fonte de cor nunca muda a estrutura do tema.

Passam **todos** os neutros, não só o accent. Com só o accent dinâmico, o
launcher lia como um chrome alheio assim que o Noctalia pintava o resto do
desktop noutro esquema.

### 🖼️ 3.5. Ícones reais

Usa o protocolo nativo de ícones do Rofi (`-show-icons`), com o ícone indicado
por entrada e um chip de emoji como alternativa quando não há ficheiro.

O protocolo exige um **byte NUL** entre o texto e `icon\x1f<caminho>` — e uma
variável bash não guarda NUL (trunca a string nesse ponto). O byte só pode
nascer no `printf` que escreve directamente no pipe, nunca numa variável
intermediária. Por isso as linhas vivem em arrays paralelos (texto, id, ícone)
e só são combinadas no momento da escrita.

### 🔑 3.6. Identificadores e navegação

As linhas **não mostram** `[id]`. O Rofi devolve o índice (`-format i`) e o
`launcher.sh` mapeia índice → id em arrays paralelos, por isso o id nunca
precisa de aparecer no ecrã. Um índice sem id é um cabeçalho de secção e
reabre o menu em vez de fazer nada.

### ⚡ 3.7. Integração com Hyprland, Wayland e UWSM

- **Isolamento de escopos com UWSM**: o Hyprland no CachyOS usa `uwsm app --`
  para gerir ciclos de vida via unidades transientes do systemd.
- **Resolução de `$PATH`**: como o `systemd --user` não herda `~/.local/bin`
  por omissão, o projecto usa caminhos absolutos no `binds.lua`, conta com
  `export PATH=...` no `~/.config/uwsm/env`, e dispara o Kitty com a shell
  interactiva (`kitty --title "$title" fish -i -c "$cmd"`) para que funções,
  aliases e toolchains estejam disponíveis.
- **Atalho sem conflitos**: antes de injectar `Super + I` no `binds.lua` (ou,
  sem ele, no `hyprland.lua`), o instalador consulta `hyprctl -j binds`. Se a
  combinação já estiver ocupada, avisa e deixa escolher outra tecla, verificando
  também essa — caso contrário criava duas acções na mesma tecla sem aviso
  nenhum. Sem terminal para perguntar, não cria o atalho e mostra a linha.
- **Atalho portátil**: `mainMod` e `launchPrefix` só entram na linha se o
  arquivo os definir; senão a linha é autónoma (`"SUPER + I"`). O bloco fica
  entre `-- hyprai:begin/end`, no fim do arquivo (ou antes de um `return`
  final), e o `uninstall.sh` tira só esse bloco. Os arquivos são reescritos
  por cima, não substituídos — um `binds.lua` que seja symlink de um
  repositório de dotfiles continua symlink.

### 📝 3.8. Curadoria declarativa (`config/sites.conf`)

```conf
id | ícone | Nome | categoria | url | svg
```

O script lê linha a linha, agrupa pelas categorias (`chat`, `search`, `write`,
`dev`, `code`, `media`) e insere os cabeçalhos. Pelas opções *"Definições"*
(*"Configurações"* em pt-BR) e *"Ferramentas"* no menu, detecta o editor
disponível (`zeditor`, `nvim`, `nano`, `micro`, `kate`…) e abre o ficheiro certo.

O `install.sh` **não sobrescreve** `sites.conf` nem `tools.conf` ao reinstalar:
a curadoria sobrevive às actualizações. Em contrapartida, ao alterá-los no
repositório é preciso copiá-los à mão para a instalação.

### 🌍 3.9. Cinco idiomas

Interface em pt-PT, pt-BR, es-ES, en-GB e 中文, escolhidos pelo locale. A
tabela está organizada por idioma (não por chave) porque, com cinco línguas,
uma linha por chave com todas lado a lado torna-se ilegível — e é aí que se
erra ao acrescentar a sexta. Uma chave em falta cai para o inglês, nunca para o
identificador cru: `cat_media` na interface é pior que o termo em inglês.

---

## 🚀 Resumo de uso

| Acção | Como fazer |
|---|---|
| **Abrir o menu** | `Super + I` |
| **Abrir via terminal** | `hyprai` |
| **Adicionar um site** | Editar `~/.config/hypr/hyprai/config/sites.conf` |
| **Adicionar uma ferramenta** | Uma linha em `~/.config/hypr/hyprai/config/tools.conf` |
| **Reinstalar/actualizar** | Correr `./install.sh` |
