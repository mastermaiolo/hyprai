<div align="center">

# HYPR.AI

**Superfície de Comando e Lançador Nativo de IA para Hyprland**

[![Release](https://img.shields.io/github/v/release/mastermaiolo/hyprai?style=flat-square&color=00D2FF&label=release)](https://github.com/mastermaiolo/hyprai/releases/latest)
[![Licença](https://img.shields.io/badge/licen%C3%A7a-MIT-E9E5DC?style=flat-square&labelColor=13161A)](LICENSE)
[![Compositor](https://img.shields.io/badge/compositor-Hyprland%20%2F%20Wayland-38BDF8?style=flat-square&labelColor=13161A)](https://hyprland.org)
[![Shell](https://img.shields.io/badge/runtime-fish%20%2B%20bash%20%2B%20rofi-B62B32?style=flat-square&labelColor=13161A)](https://github.com/davatorium/rofi)

<br/>

[English (UK)](README.md) · [Português (Brasil)](README.pt-br.md) · **Português (Portugal)** · [Español](README.es-es.md) · [简体中文](README.zh-cn.md)

<br/>

<img src="assets/readme/hero.svg" alt="Hypr.AI Hero Canvas" width="100%"/>

</div>

<br/>

> **Lançador nativo de IA para Hyprland** — agentes de terminal CLI, aplicações desktop e portais web curados reunidos sob uma interface Rofi em vidro acionada por teclado. Nada está fixo no código: as ferramentas surgem apenas quando se encontram verdadeiramente instaladas no sistema, e toda a janela acompanha em tempo real a paleta tonal Material You do teu papel de parede.

---

## 01 / Índice de Navegação

- [02 / Visão Geral](#02--vis%C3%A3o-geral)
- [03 / Capacidades e Engenharia](#03--capacidades-e-engenharia)
- [04 / Atlas de Candidatos e Showcase](#04--atlas-de-candidatos-e-showcase)
- [05 / Superfície de Controlo e Utilização](#05--superf%C3%ADcie-de-controlo-e-utiliza%C3%A7%C3%A3o)
- [06 / Requisitos e Instalação](#06--requisitos-e-instala%C3%A7%C3%A3o)
- [07 / Configuração e Personalização](#07--configura%C3%A7%C3%A3o-e-personaliza%C3%A7%C3%A3o)
- [08 / Arquitectura do Pipeline e Estrutura Interna](#08--arquitectura-do-pipeline-e-estrutura-interna)
- [09 / Resolução de Problemas e Diagnóstico](#09--resolu%C3%A7%C3%A3o-de-problemas-e-diagn%C3%B3stico)
- [10 / Linhagem e Proveniência](#10--linhagem-e-proveni%C3%AAncia)

---

## 02 / Visão Geral

O Hypr.AI resolve a fragmentação diária de alternar constantemente entre terminais de comando, IDEs pesadas e dezenas de separadores no navegador ao trabalhar com ecossistemas de inteligência artificial.

<br/>

<div align="center">
  <img src="assets/readme/at-a-glance.svg" alt="Hypr.AI Visão Geral" width="100%"/>
</div>

<br/>

### Principais Pilares Arquitecturais

| Pilar | Implementação Técnica | Garantia Arquitectural |
|---|---|---|
| **Detecção em Tempo Real** | Sondagem dinâmica de candidatos através do ambiente interactivo da shell `fish` | Zero entradas mortas; actualização automática ao instalar ou remover |
| **Vidro Material You** | Alpha de fundo calibrado a 60%, realce superior de 1,5px e ponte viva com Noctalia | Desfocagem do compositor adaptada ao esquema do papel de parede |
| **Segurança de Protocolo** | Streaming de ícones delimitados por byte NUL directamente no pipe do Rofi | Preserva ficheiros SVG e PNG em alta resolução sem truncagem no Bash |
| **Atalho Não Invasivo** | Validação prévia de colisões via `hyprctl -j binds` durante a instalação | Registo seguro de `Super + I` sem sobreposição de atalhos existentes |
| **Suíte de 5 Idiomas** | Resolução automática através do locale do sistema operativo | Suporte nativo em EN-GB, PT-BR, PT-PT, ES-ES e ZH-CN |

---

## 03 / Capacidades e Engenharia

<br/>

<div align="center">
  <img src="assets/readme/capabilities.svg" alt="Capacidades do Hypr.AI" width="100%"/>
</div>

<br/>

### 1. Resolução do PATH do Fish Interactivo
Em Wayland e sob o UWSM, o Hyprland entrega aos processos um `$PATH` mínimo de sistema (geralmente restrito a `/usr/bin`, `~/.local/bin` e `~/.cargo/bin`). Ecossistemas geridos pelo Linuxbrew (`/home/linuxbrew/.linuxbrew/bin`), NVM, Pyenv ou asdf são carregados no `~/.config/fish/config.fish` dentro de blocos interactivos (`if status is-interactive`).

Se um lançador testar os candidatos a partir de uma subshell vulgar, ferramentas instaladas via Brew ou ambientes virtuais tornam-se completamente invisíveis. O Hypr.AI resolve esta assimetria pedindo ao `fish -i` o seu `$PATH` consolidado **uma única vez** aquando da abertura do menu, testando todos os candidatos em Bash contra esse caminho. Evita-se assim o custo de abrir 30 instâncias de Fish, garantindo que o que é detectado corresponde ao que efectivamente corre.

### 2. Óptica de Vidro Fisicamente Calibrada
Obter um efeito de vidro autêntico em Wayland requer calibragem minuciosa entre a desfocagem do compositor e a transparência do painel:
- **Opacidade Calibrada a 60%:** O fundo `bg0` está fixado em 60% (`#0D0D10` com transparência `0x99`). Acima de 85%, a luz deixa de atravessar a superfície e o blur uniforme do compositor torna-se indistinguível de tinta sólida. Abaixo de 50%, perde-se legibilidade de texto perante papéis de parede claros.
- **Realce Exclusivo no Topo:** Um vidro real reflecte a luz sobretudo no bordo superior. O Hypr.AI utiliza `border: 1.5px 0px 0px 0px`, dispensando molduras integrais que transformam a janela numa caixa de plástico cinzento.
- **Regra de Camada com `xray = false`:** No Hyprland, a opção `xray` faz o blur ignorar camadas intermédias. Contudo, em ambientes onde o papel de parede constitui ele próprio uma camada de ecrã inteiro (como no Noctalia), o `xray = true` salta o próprio papel de parede, desvanecendo o efeito de vidro de forma invisível. O instalador força `xray = false`.

### 3. Protocolo de Arrays Paralelos e Bytes NUL
O protocolo de ícones do Rofi (`-show-icons`) requer um byte NUL puro (`\0`) a separar o texto da linha dos metadados de ícone (`texto\0icon\x1f/caminho/icone.svg`). Como as variáveis do Bash não conseguem armazenar bytes NUL sem truncar o conteúdo textual, o Hypr.AI armazena os dados em arrays paralelos para texto, identificadores e ícones, projectando o byte directamente no fluxo do pipe através de `printf`. A resposta é devolvida sob a forma de índice numérico (`-format i`), mapeando a acção sem poluir o ecrã com identificadores crus.

---

## 04 / Atlas de Candidatos e Showcase

<br/>

<div align="center">
  <img src="assets/readme/showcase.svg" alt="Atlas de Candidatos do Hypr.AI" width="100%"/>
</div>

<br/>

### Matriz de Ferramentas Suportadas

O Hypr.AI inclui configurações prévias para candidatos em três domínios principais. As opções mantêm-se ocultas até à efectiva instalação dos respectivos binários.

| Domínio | Ferramentas Suportadas | Subsistema de Execução |
|---|---|---|
| **Agentes de Linha de Comando (CLI)** | Claude Code, Antigravity CLI, Gemini CLI, Codex CLI, Aider, GitHub Copilot CLI, Cursor CLI, OpenCode, Goose, Ollama, Qwen Code, Crush, Mods, Plandex, Droid, OpenHands, Cline, Hermes CLI | Janela dedicada de terminal (`kitty`, `ghostty`, `foot`, `alacritty` ou `wezterm`) a correr `fish -i -c "$cmd"` |
| **Aplicações Desktop** | Claude Desktop, Antigravity 2.0, Cursor, Windsurf, Zed, LM Studio, Jan, GPT4All, AnythingLLM, Chatbox, Msty, Hermes Desktop | Lançamento nativo de aplicação Wayland |
| **Portais Web Curados** | 33 serviços agrupados em Chat, Pesquisa, Escrita, Desenvolvimento, Código e Multimédia | Navegador predefinido do sistema (`xdg-open "$url"`) |

<br/>

<div align="center">
  <img src="assets/screenshot.webp" alt="Captura da Interface Hypr.AI" width="85%"/>
  <p><em>Hypr.AI em execução sob o Hyprland com integração tonal Material You do Noctalia</em></p>
</div>

<br/>

<details>
<summary><strong>Lista Completa dos 33 Portais Web Curados (Clica para Expandir)</strong></summary>
<br/>

- **Conversação e Modelos Base:** ChatGPT, Claude, Gemini, DeepSeek, Grok, Kimi, Qwen, Mistral, Microsoft Copilot, Poe, HuggingChat, DuckDuckGo AI.
- **Pesquisa e Inteligência:** Perplexity AI, Genspark, Felo, Phind, Consensus.
- **Escrita e Redacção:** Claude Artifacts, Notion AI, Lex, TypingMind.
- **Desenvolvimento e Código:** v0 da Vercel, Lovable, Bolt.new, Replit Agent, GitHub Copilot Web.
- **Multimédia e Imagem/Áudio:** Midjourney, Suno, Udio, ElevenLabs, Runway Gen-3, Luma Dream Machine, Flux / Black Forest Labs.

</details>

---

## 05 / Superfície de Controlo e Utilização

<br/>

<div align="center">
  <img src="assets/readme/control-surface.svg" alt="Superfície de Controlo" width="100%"/>
</div>

<br/>

### Ergonomia de Teclado e Atalhos

| Entrada / Atalho | Contexto de Operação | Acção Executada |
|---|---|---|
| `Super + I` | Desktop Global do Hyprland | Abre ou fecha o menu Hypr.AI |
| `hyprai` | Terminal / Linha de Comandos | Acciona o lançador a partir de um comando |
| `hyprai --doctor` | Terminal / Linha de Comandos | Executa a verificação e diagnóstico de todo o sistema |
| `Digitar para filtrar` | Caixa de pesquisa do menu | Filtro dinâmico por nome, autor e palavras-chave |
| `Enter` | Linha seleccionada | Arranca o agente no terminal, abre a app ou lança o portal |
| `Esc` | No menu | Fecha a janela de imediato sem estados residuais |
| `↩ Voltar` | Submenu de Portais ou Definições | Regressa ao menu principal de ferramentas |

---

## 06 / Requisitos e Instalação

### Pré-requisitos

- **Compositor:** Hyprland
- **Motor de Menus:** `rofi` (versão 1.7+ com suporte a protocolo de ícones)
- **Shells:** `bash` e `fish` (o Fish é mandatório para a resolução interactiva de PATH e execução dos agentes)
- **Emulador de Terminal:** `kitty`, `ghostty`, `foot`, `alacritty` ou `wezterm` (detectado automaticamente ou definido em `hyprai.conf`)
- **Tipografia:** Família de tipos **Inter** (`pacman -S inter-font` no Arch Linux)
- **Esquema de Cores (Recomendado):** [Noctalia](https://github.com/noctalia-dev/noctalia-shell) ou [Caelestia](https://github.com/caelestia-dots/shell) (assume paleta estática Dark Violet / Neon Indigo na ausência de ambos)
- **Componentes Opcionais:** `libnotify` (notificações no desktop), `uwsm` (gestão de sessões systemd)

### Instalação Automatizada

```bash
# Clonar o repositório
git clone https://github.com/mastermaiolo/hyprai.git
cd hyprai

# Executar o instalador
./install.sh
```

### Acções do Instalador

1. Instala scripts, esquemas de configuração e ícones em `~/.config/hypr/hyprai/`.
2. Cria o executável wrapper `hyprai` em `~/.local/bin/hyprai`.
3. Regista o template tonal Material You no Noctalia (se presente).
4. Verifica via `hyprctl -j binds` se `Super + I` se encontra disponível; solicita outra tecla se já estiver ocupada e adiciona o atalho em segurança entre marcas `-- hyprai:begin/end` no `~/.config/hypr/config/binds.lua` (ou `hyprland.lua`).
5. Pergunta antes de acrescentar a regra de camada de blur para o vidro ao teu `windowrules.lua`.

> [!TIP]
> Após instalar sob o Noctalia, altera o papel de parede ou a cor de destaque uma vez para que o Noctalia crie a ponte de cores (`~/.local/state/hyprai/noctalia-colors.rasi`) pela primeira vez.

---

## 07 / Configuração e Personalização

Todos os ficheiros de configuração são ficheiros de texto simples em `~/.config/hypr/hyprai/config/`:

| Ficheiro de Configuração | Finalidade |
|---|---|
| `config/tools.conf` | Definição dos candidatos para agentes CLI e aplicações desktop |
| `config/sites.conf` | Portais web de IA curados, organizados por categorias |
| `config/hyprai.conf` | Preferências de arranque (ex.: `terminal = kitty`, ou vazio para selecção automática) |
| `rofi/user.rasi` | Ajustes visuais pessoais opcionais (posição da janela, largura, tipos de letra) |

> [!IMPORTANT]
> O instalador `./install.sh` **nunca substitui** os teus ficheiros `.conf` nem o teu `user.rasi` em reinstalações. A tua curadoria e alterações sobrevivem às actualizações.

### Adicionar uma Ferramenta Local

Acrescenta uma linha a `~/.config/hypr/hyprai/config/tools.conf`:

```conf
# id | ícone | Nome | Subtexto | categoria | candidatos | svg | args
meuagente|🤖|Meu Agente|Lab Pessoal|cli|meuagente;meuagente-cli|meuagente.svg|--chat
```

- **`categoria`:** `cli` (corre no terminal dedicado com fish) ou `desktop` (corre como aplicação gráfica).
- **`candidatos`:** Nomes de binários ou caminhos separados por `;`. Testados pela ordem indicada; o primeiro que existir vence. Nomes simples são procurados no `$PATH`; caminhos absolutos ou iniciados por `~` são testados directamente.
- **`svg`:** Ficheiro vectorial em `~/.config/hypr/hyprai/svg/` (cai para o emoji da segunda coluna na sua ausência).
- **`args`:** Argumentos fixos facultativos (útil se o mesmo executável servir de CLI e de GUI).

### Adicionar um Portal Web

Acrescenta uma linha a `~/.config/hypr/hyprai/config/sites.conf`:

```conf
# id | ícone | Nome | categoria | url | svg
meuportal|🌐|Meu Portal|chat|https://exemplo.ai|portal.svg
```

Categorias disponíveis: `chat`, `search`, `write`, `dev`, `code`, `media`.

### Mudar a Posição da Janela

Para mover a janela (por exemplo, abaixo de uma barra superior), cria `~/.config/hypr/hyprai/rofi/user.rasi`:

```css
/* ~/.config/hypr/hyprai/rofi/user.rasi */
window {
    location: north;
    y-offset: 120px;
    width: 720px;
}
```

---

## 08 / Arquitectura do Pipeline e Estrutura Interna

<br/>

<div align="center">
  <img src="assets/readme/architecture.svg" alt="Arquitectura do Hypr.AI" width="100%"/>
</div>

<br/>

### Estrutura do Repositório

```
hyprai/
├── assets/
│   ├── readme/            # SVGs modulares do sistema de design (hero, capabilities, etc.)
│   └── screenshot.webp    # Captura da interface no ecrã real
├── config/
│   ├── hyprai.conf        # Definições de terminal e preferências de execução
│   ├── sites.conf         # Portais web curados
│   └── tools.conf         # Candidatos de agentes CLI e aplicações desktop
├── rofi/
│   └── hyprai.rasi        # Folha de estilo do tema (grelha de 4px, raios, tokens OKLCH)
├── svg/                   # Biblioteca de ícones vectoriais para o protocolo Rofi
├── theme/
│   └── noctalia.rasi.tmpl # Template Material You processado pelo Noctalia
├── ui/
│   └── launcher.sh        # Motor central de sondagem e lançamento
├── install.sh             # Instalador idempotente e gestor de atalhos
├── uninstall.sh           # Desinstalador simétrico e limpo
├── DESIGN.md              # Especificação de design dos tokens do coherent-design
└── SOBRE.md               # Manifesto técnico e decisões de engenharia detalhadas
```

---

## 09 / Resolução de Problemas e Diagnóstico

Começa sempre pelo comando de diagnóstico integrado:

```bash
hyprai --doctor
```

O comando `hyprai --doctor` analisa dependências do sistema, terminal detectado, fonte do tema activo, ferramentas encontradas, eventuais erros de sintaxe, estado do atalho e regras de camada do compositor.

<br/>

<div align="center">
  <img src="assets/readme/failure-modes.svg" alt="Matriz de Resolução de Problemas" width="100%"/>
</div>

<br/>

### Cenários Frequentes

<details>
<summary><strong>1. Uma ferramenta que tenho instalada não surge no menu</strong></summary>
<br/>

O nome do executável na lista de `candidatos` do `tools.conf` provavelmente não corresponde ao instalado.
1. Corre `which <nome-da-ferramenta>` num terminal Fish interactivo para verificar a localização.
2. Compara com os nomes indicados na coluna `candidatos` do `tools.conf`.
3. A sondagem falha silenciosamente por decisão de desenho para manter o menu limpo. Adiciona o nome correcto separado por ponto e vírgula (`;`).

</details>

<details>
<summary><strong>2. O menu surge completamente opaco, sem vidro</strong></summary>
<br/>

1. **Regra de Camada em Falta:** As superfícies de layer-shell não recebem blur no Hyprland sem uma regra expressa para o seu namespace. Executa de novo `./install.sh` e aceita a regra de vidro.
2. **`xray = true` Definido:** Se a regra tiver `xray = true`, o compositor salta as camadas intermédias. Como o wallpaper do Noctalia é uma camada de ecrã inteiro, o blur salta o próprio wallpaper e o vidro desaparece. Assegura-te de que a regra tem `xray = false`.
3. **Opacidade Excessiva:** Se a opacidade de `bg0` estiver acima de 85%, a luz fica bloqueada e o blur lê-se como tinta plana. O valor predefinido do Hypr.AI é 60%.

</details>

<details>
<summary><strong>3. A captura de ecrã mostra vidro mas o ecrã real mostra uma caixa opaca</strong></summary>
<br/>

Utilitários como o `grim` recolhem o buffer de imagem antes do passo de desfocagem do compositor. Mesmo 5% de transparência deixam passar o fundo nítido na captura (que o cérebro interpreta como vidro), ao passo que o ecrã real exibe uma mancha homogénea. A validação do vidro deve ser feita sempre pelo olhar directo no ecrã.

</details>

<details>
<summary><strong>4. As cores não actualizam ao trocar de papel de parede no Noctalia</strong></summary>
<br/>

O Noctalia gera os templates aquando da mudança de papel de parede ou esquema. Se a paleta perder a sincronização, força a actualização com:
```bash
noctalia msg config-reload && noctalia msg templates-apply
```

</details>

---

## 10 / Linhagem e Proveniência

<br/>

<div align="center">
  <img src="assets/readme/provenance.svg" alt="Linhagem e Proveniência" width="100%"/>
</div>

<br/>

### Herança de Engenharia e Design

- **Arquitectura:** Directamente derivada da ergonomia, convenções e engenharia de menus Wayland do [HyprVision](https://github.com/mastermaiolo/hyprvision).
- **Design System:** Segue os princípios do **coherent-design** — grelha de base de 4px, raios concêntricos (janela de 24px, container de 16px, elementos de 8px) e paleta OKLCH com rácio de contraste WCAG &ge; 4,5:1. Especificação integral registada em [DESIGN.md](DESIGN.md).
- **Autor:** Master Maiolo · MAIOLO / SYSTEMS LAB.

### Licença

Este projecto encontra-se licenciado sob a licença **MIT**. Consulta o ficheiro [LICENSE](LICENSE) para obteres o texto completo.

---

<div align="center">
<sub>MAIOLO / SYSTEMS LAB · HYPR.AI · SUPERFÍCIE NATIVA DE COMANDO DE IA PARA HYPRLAND</sub>
</div>
