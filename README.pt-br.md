<div align="center">

# HYPR.AI

**Superfície de Comando e Inicializador Nativo de IA para Hyprland**

[![Release](https://img.shields.io/github/v/release/mastermaiolo/hyprai?style=flat-square&color=00D2FF&label=release)](https://github.com/mastermaiolo/hyprai/releases/latest)
[![Licença](https://img.shields.io/badge/licen%C3%A7a-MIT-E9E5DC?style=flat-square&labelColor=13161A)](LICENSE)
[![Compositor](https://img.shields.io/badge/compositor-Hyprland%20%2F%20Wayland-38BDF8?style=flat-square&labelColor=13161A)](https://hyprland.org)
[![Shell](https://img.shields.io/badge/runtime-fish%20%2B%20bash%20%2B%20rofi-B62B32?style=flat-square&labelColor=13161A)](https://github.com/davatorium/rofi)

<br/>

[English (UK)](README.md) · **Português (Brasil)** · [Português (Portugal)](README.pt-pt.md) · [Español](README.es-es.md) · [简体中文](README.zh-cn.md)

<br/>

<img src="assets/readme/hero.svg" alt="Hypr.AI Hero Canvas" width="100%"/>

</div>

<br/>

> **Inicializador nativo de IA para Hyprland** — agentes de terminal CLI, ambientes desktop e portais em nuvem reunidos sob uma interface Rofi em vidro acionada por teclado. Nada está chumbado no código: as ferramentas aparecem apenas se estiverem genuinamente instaladas na máquina, e a janela inteira segue a paleta tonal Material You do seu papel de parede em tempo real.

---

## 01 / Índice de Navegação

- [02 / Visão Geral](#02--vis%C3%A3o-geral)
- [03 / Capacidades e Engenharia](#03--capacidades-e-engenharia)
- [04 / Atlas de Candidatos e Showcase](#04--atlas-de-candidatos-e-showcase)
- [05 / Superfície de Controle e Uso](#05--superf%C3%ADcie-de-controle-e-uso)
- [06 / Requisitos e Instalação](#06--requisitos-e-instala%C3%A7%C3%A3o)
- [07 / Configuração e Customização](#07--configura%C3%A7%C3%A3o-e-customiza%C3%A7%C3%A3o)
- [08 / Arquitetura do Pipeline e Internos](#08--arquitetura-do-pipeline-e-internos)
- [09 / Resolução de Problemas e Diagnóstico](#09--resolu%C3%A7%C3%A3o-de-problemas-e-diagn%C3%B3stico)
- [10 / Linhagem e Proveniência](#10--linhagem-e-proveni%C3%AAncia)

---

## 02 / Visão Geral

O Hypr.AI elimina o atrito de alternar entre terminais soltos, IDEs pesadas e dezenas de abas no navegador ao orquestrar ferramentas de inteligência artificial.

<br/>

<div align="center">
  <img src="assets/readme/at-a-glance.svg" alt="Hypr.AI Visão Geral" width="100%"/>
</div>

<br/>

### Principais Pilares Arquiteturais

| Pilar | Implementação Técnica | Garantia Arquitetural |
|---|---|---|
| **Detecção em Tempo de Execução** | Sondagem dinâmica de candidatos via ambiente interativo do shell `fish` | Zero entradas fantasmas; detecção automática ao instalar ou desinstalar |
| **Vidro Material You** | Alpha de fundo em 60%, realce superior de 1,5px e ponte viva com Noctalia | Desfoque profundo do compositor respeitando o tema ativo do papel de parede |
| **Segurança de Protocolo** | Streaming de ícones delimitados por byte NUL direto no pipe do Rofi | Preserva SVGs e PNGs em alta resolução sem truncamento no Bash |
| **Atalhos Não Invasivos** | Detecção de conflitos via `hyprctl -j binds` na instalação | Registro seguro do `Super + I` sem sobrescrever macros existentes |
| **Suíte de 5 Idiomas** | Resolução automática de locale do sistema operacional | Suporte nativo a EN-GB, PT-BR, PT-PT, ES-ES e ZH-CN |

---

## 03 / Capacidades e Engenharia

<br/>

<div align="center">
  <img src="assets/readme/capabilities.svg" alt="Capacidades do Hypr.AI" width="100%"/>
</div>

<br/>

### 1. Resolução do PATH do Fish Interativo
No Wayland e UWSM, o Hyprland inicializa processos com um `$PATH` mínimo de sistema (geralmente limitado a `/usr/bin`, `~/.local/bin` e `~/.cargo/bin`). Ambientes gerenciados via Linuxbrew (`/home/linuxbrew/.linuxbrew/bin`), NVM, Pyenv ou asdf são configurados no `~/.config/fish/config.fish` sob proteções interativas (`if status is-interactive`).

Se um inicializador testar candidatos em um subshell comum, agentes instalados via Brew ou gerenciadores virtuais ficam invisíveis. O Hypr.AI soluciona isso consultando o `fish -i` pelo `$PATH` consolidado **exatamente uma vez** ao abrir o menu, sondando todos os candidatos em Bash com esse caminho. Isso elimina o atraso de instanciar 30 processos de Fish e garante que tudo o que for detectado execute perfeitamente ao ser acionado.

### 2. Óptica de Vidro Fisicamente Calibrada
Produzir vidro realista no Wayland exige equilíbrio físico entre desfoque do compositor e transparência da janela:
- **Opacidade Calibrada em 60%:** O fundo `bg0` está fixado em 60% (`#0D0D10` com transparência `0x99`). Acima de 85%, a passagem de luz é bloqueada e o blur uniforme do compositor se torna indistinguível de tinta sólida. Abaixo de 50%, perde-se legibilidade de texto sobre papéis de parede claros.
- **Realce Exclusivo no Topo:** Um vidro real recebe incidência de luz principalmente pela borda superior. O Hypr.AI aplica `border: 1.5px 0px 0px 0px`, evitando bordas em caixa fechada que fazem o vidro parecer uma placa plástica.
- **Regra de Camada com `xray = false`:** No Hyprland, a diretiva `xray` manda o blur pular camadas intermediárias. Em desktops onde o papel de parede é renderizado como camada de tela cheia (como no Noctalia), o `xray = true` pula o próprio papel de parede, fazendo o efeito de vidro sumir silenciosamente. O instalador configura e valida `xray = false`.

### 3. Protocolo de Arrays Paralelos e Bytes NUL
O protocolo de ícones do Rofi (`-show-icons`) requer um byte NUL bruto (`\0`) separando o texto da linha dos parâmetros de ícone (`texto\0icon\x1f/caminho/icone.svg`). Como variáveis do Bash não armazenam bytes NUL sem truncar a string, o Hypr.AI mantém arrays paralelos para nomes, identificadores e ícones, injetando o byte diretamente no fluxo do pipe via `printf`. O retorno ocorre pelo índice numérico (`-format i`), mapeando a ação sem sujar a interface com códigos internos.

---

## 04 / Atlas de Candidatos e Showcase

<br/>

<div align="center">
  <img src="assets/readme/showcase.svg" alt="Atlas de Candidatos do Hypr.AI" width="100%"/>
</div>

<br/>

### Matriz de Ferramentas Suportadas

O Hypr.AI já vem com candidatos pré-configurados em três frentes principais. As entradas permanecem ocultas até que os binários correspondentes sejam detectados.

| Domínio | Ferramentas e Nós do Ecossistema | Subsistema de Lançamento |
|---|---|---|
| **Agentes de Terminal (CLI)** | Claude Code, Antigravity CLI, Gemini CLI, Codex CLI, Aider, GitHub Copilot CLI, Cursor CLI, OpenCode, Goose, Ollama, Qwen Code, Crush, Mods, Plandex, Droid, OpenHands, Cline, Hermes CLI | Janela dedicada no terminal (`kitty`, `ghostty`, `foot`, `alacritty` ou `wezterm`) rodando `fish -i -c "$cmd"` |
| **Aplicações Desktop** | Claude Desktop, Antigravity 2.0, Cursor, Windsurf, Zed, LM Studio, Jan, GPT4All, AnythingLLM, Chatbox, Msty, Hermes Desktop | Inicialização nativa de aplicativo Wayland |
| **Portais Web Curados** | 33 serviços agrupados em Chat, Pesquisa, Escrita, Desenvolvimento, Código e Mídia | Navegador padrão do Wayland (`xdg-open "$url"`) |

<br/>

<div align="center">
  <img src="assets/screenshot.webp" alt="Captura da Interface Hypr.AI" width="85%"/>
  <p><em>Hypr.AI em execução no Hyprland com integração tonal Material You via Noctalia</em></p>
</div>

<br/>

<details>
<summary><strong>Lista Completa dos 33 Portais Web Curados (Clique para Expandir)</strong></summary>
<br/>

- **Chat e Modelos Base:** ChatGPT, Claude, Gemini, DeepSeek, Grok, Kimi, Qwen, Mistral, Microsoft Copilot, Poe, HuggingChat, DuckDuckGo AI.
- **Pesquisa e Inteligência:** Perplexity AI, Genspark, Felo, Phind, Consensus.
- **Escrita e Síntese:** Claude Artifacts, Notion AI, Lex, TypingMind.
- **Desenvolvimento e Código:** v0 da Vercel, Lovable, Bolt.new, Replit Agent, GitHub Copilot Web.
- **Mídia e Geração Multimodal:** Midjourney, Suno, Udio, ElevenLabs, Runway Gen-3, Luma Dream Machine, Flux / Black Forest Labs.

</details>

---

## 05 / Superfície de Controle e Uso

<br/>

<div align="center">
  <img src="assets/readme/control-surface.svg" alt="Superfície de Controle" width="100%"/>
</div>

<br/>

### Ergonomia de Teclado e Atalhos

| Entrada / Atalho | Contexto de Operação | Ação Executada |
|---|---|---|
| `Super + I` | Desktop Global do Hyprland | Abre ou fecha o menu Hypr.AI |
| `hyprai` | Terminal / Shell | Dispara o inicializador via linha de comando |
| `hyprai --doctor` | Terminal / Shell | Roda a bateria completa de testes e diagnóstico |
| `Digitar para filtrar` | Caixa de busca do menu | Filtro fuzzy em tempo real por nome, autor e função |
| `Enter` | Linha selecionada | Executa o agente no terminal, abre o app desktop ou o portal web |
| `Esc` | No menu | Fecha a janela imediatamente sem deixar estado residual |
| `↩ Voltar` | Submenu de Portais ou Configurações | Retorna ao menu principal de ferramentas |

---

## 06 / Requisitos e Instalação

### Pré-requisitos

- **Compositor:** Hyprland
- **Mecanismo de Menu:** `rofi` (versão 1.7+ com suporte ao protocolo de ícones)
- **Shells:** `bash` e `fish` (o Fish é mandatório para resolução interativa de PATH e execução dos agentes de terminal)
- **Emulador de Terminal:** `kitty`, `ghostty`, `foot`, `alacritty` ou `wezterm` (detectado automaticamente ou configurado em `hyprai.conf`)
- **Tipografia:** Fonte **Inter** (`pacman -S inter-font` no Arch Linux)
- **Esquema de Cores (Recomendado):** [Noctalia](https://github.com/noctalia-dev/noctalia-shell) ou [Caelestia](https://github.com/caelestia-dots/shell) (cai para paleta estática Dark Violet / Neon Indigo sem eles)
- **Opcionais:** `libnotify` (notificações), `uwsm` (gerenciamento de sessão systemd)

### Instalação Automatizada

```bash
# Clonar o repositório
git clone https://github.com/mastermaiolo/hyprai.git
cd hyprai

# Executar o instalador
./install.sh
```

### O Que o Instalador Faz

1. Copia scripts, esquemas de configuração e ícones para `~/.config/hypr/hyprai/`.
2. Cria o executável wrapper `hyprai` em `~/.local/bin/hyprai`.
3. Registra o template tonal Material You no Noctalia (se presente).
4. Consulta `hyprctl -j binds` para verificar se `Super + I` está livre; solicita outra tecla se houver conflito e adiciona o atalho de forma segura entre marcações `-- hyprai:begin/end` no `~/.config/hypr/config/binds.lua` (ou `hyprland.lua`).
5. Pergunta antes de adicionar a regra de camada de blur para o vidro no seu `windowrules.lua`.

> [!TIP]
> Após instalar sob o Noctalia, troque o papel de parede ou a cor de destaque uma vez para que o Noctalia gere a ponte de cores (`~/.local/state/hyprai/noctalia-colors.rasi`) pela primeira vez.

---

## 07 / Configuração e Customização

Todas as configurações residem em arquivos de texto simples dentro de `~/.config/hypr/hyprai/config/`:

| Arquivo de Configuração | Propósito |
|---|---|
| `config/tools.conf` | Definição de candidatos para agentes CLI e aplicativos desktop |
| `config/sites.conf` | Portais web de IA curados, agrupados por categorias |
| `config/hyprai.conf` | Preferências de execução (ex.: `terminal = kitty`, ou vazio para automático) |
| `rofi/user.rasi` | Ajustes visuais pessoais opcionais (posição, largura, fontes) |

> [!IMPORTANT]
> O instalador `./install.sh` **nunca sobrescreve** seus arquivos `.conf` nem seu `user.rasi` em reinstalações. Suas personalizações e curadorias sobrevivem a atualizações.

### Adicionando uma Ferramenta Local

Adicione uma linha em `~/.config/hypr/hyprai/config/tools.conf`:

```conf
# id | ícone | Nome | Subtexto | categoria | candidatos | svg | args
meuagente|🤖|Meu Agente|Lab Pessoal|cli|meuagente;meuagente-cli|meuagente.svg|--chat
```

- **`categoria`:** `cli` (abre no terminal dedicado com fish) ou `desktop` (abre como app gráfico).
- **`candidatos`:** Nomes de binários ou caminhos separados por `;`. Testados na ordem; o primeiro que existir vence. Nomes puros são buscados no `$PATH`; caminhos absolutos ou iniciados por `~` são testados diretamente.
- **`svg`:** Arquivo vetorial dentro de `~/.config/hypr/hyprai/svg/` (cai para o emoji da coluna 2 se ausente).
- **`args`:** Argumentos fixos opcionais (útil quando o mesmo binário serve para modo CLI e GUI).

### Adicionando um Portal Web

Adicione uma linha em `~/.config/hypr/hyprai/config/sites.conf`:

```conf
# id | ícone | Nome | categoria | url | svg
meuportal|🌐|Meu Portal|chat|https://exemplo.ai|portal.svg
```

Categorias disponíveis: `chat`, `search`, `write`, `dev`, `code`, `media`.

### Reposicionando a Janela

Para mover a janela (por exemplo, logo abaixo de uma barra superior), crie `~/.config/hypr/hyprai/rofi/user.rasi`:

```css
/* ~/.config/hypr/hyprai/rofi/user.rasi */
window {
    location: north;
    y-offset: 120px;
    width: 720px;
}
```

---

## 08 / Arquitetura do Pipeline e Internos

<br/>

<div align="center">
  <img src="assets/readme/architecture.svg" alt="Arquitetura do Hypr.AI" width="100%"/>
</div>

<br/>

### Estrutura do Repositório

```
hyprai/
├── assets/
│   ├── readme/            # SVGs modulares do design system (hero, capabilities, etc.)
│   └── screenshot.webp    # Captura da interface real
├── config/
│   ├── hyprai.conf        # Preferências de terminal e execução
│   ├── sites.conf         # Portais web curados
│   └── tools.conf         # Candidatos de agentes CLI e aplicativos desktop
├── rofi/
│   └── hyprai.rasi        # Folha de estilo (grid de 4px, raios, tokens OKLCH)
├── svg/                   # Biblioteca de ícones vetoriais do protocolo Rofi
├── theme/
│   └── noctalia.rasi.tmpl # Template Material You renderizado pelo Noctalia
├── ui/
│   └── launcher.sh        # Orquestrador central e motor de sondagem
├── install.sh             # Instalador idempotente e injetor de atalhos
├── uninstall.sh           # Desinstalador limpo
├── DESIGN.md              # Tokens de design do coherent-design e especificações ópticas
└── SOBRE.md               # Manifesto técnico e decisões de engenharia
```

---

## 09 / Resolução de Problemas e Diagnóstico

Sempre inicie o diagnóstico pelo comando integrado:

```bash
hyprai --doctor
```

O `hyprai --doctor` analisa dependências, terminal detectado, fonte do tema ativo, candidatos encontrados, possíveis erros de sintaxe, estado do atalho e regras de camada do compositor.

<br/>

<div align="center">
  <img src="assets/readme/failure-modes.svg" alt="Matriz de Resolução de Problemas" width="100%"/>
</div>

<br/>

### Cenários Frequentes

<details>
<summary><strong>1. Uma ferramenta instalada não aparece no menu</strong></summary>
<br/>

O nome do binário nos `candidatos` do `tools.conf` provavelmente não corresponde ao seu sistema.
1. Execute `which <nome-da-ferramenta>` em um terminal Fish interativo para ver o caminho real.
2. Confira se o nome está presente na coluna `candidatos` do `tools.conf`.
3. A detecção falha silenciosamente por design para evitar opções quebradas. Adicione o nome correto separado por ponto e vírgula (`;`).

</details>

<details>
<summary><strong>2. O menu parece opaco, sem efeito de vidro</strong></summary>
<br/>

1. **Regra de Camada Ausente:** Superfícies layer-shell não recebem desfoque no Hyprland sem uma regra explícita apontando para seu namespace. Rode novamente `./install.sh` e aceite a regra de vidro.
2. **`xray = true` Ativado:** Se a regra estiver com `xray = true`, o compositor pula as camadas intermediárias. Como o papel de parede do Noctalia ocupa uma camada, o blur salta o próprio papel de parede e o vidro some. Garanta que a regra use `xray = false`.
3. **Opacidade Excessiva:** Se a opacidade de `bg0` estiver acima de 85%, a luz não consegue passar e o vidro se comporta como tinta sólida. O padrão do Hypr.AI é 60%.

</details>

<details>
<summary><strong>3. A captura de tela mostra vidro, mas a tela real parece opaca</strong></summary>
<br/>

Ferramentas como o `grim` capturam o buffer de imagem antes do passo de desfoque do compositor. Mesmo 5% de transparência revelam o papel de parede nítido no screenshot (que o cérebro interpreta como vidro), enquanto o monitor físico exibe o borrão uniforme. Sempre calibre a óptica olhando diretamente para a tela do monitor.

</details>

<details>
<summary><strong>4. As cores não acompanham a troca de papel de parede no Noctalia</strong></summary>
<br/>

O Noctalia atualiza templates a cada troca de tema ou papel de parede. Se as cores não sincronizarem, force a atualização com:
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

- **Arquitetura:** Construído sobre a ergonomia, convenções e engenharia de menus Wayland do [HyprVision](https://github.com/mastermaiolo/hyprvision).
- **Design System:** Segue os princípios do **coherent-design** — grid estrutural de 4px, raios concêntricos (janela 24px, container 16px, filhos 8px) e paleta OKLCH com contraste WCAG &ge; 4,5:1. Detalhes documentados em [DESIGN.md](DESIGN.md).
- **Autor:** Master Maiolo · MAIOLO / SYSTEMS LAB.

### Licença

Este projeto é distribuído sob a licença **MIT**. Consulte o arquivo [LICENSE](LICENSE) para obter os termos na íntegra.

---

<div align="center">
<sub>MAIOLO / SYSTEMS LAB · HYPR.AI · SUPERFÍCIE NATIVA DE COMANDO DE IA PARA HYPRLAND</sub>
</div>
