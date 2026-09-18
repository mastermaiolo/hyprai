# 🧠 Hypr.AI · Guia Completo do Projeto

Este documento detalha **o que é**, **para que serve** e **como foi construído** o **Hypr.AI**, criado especificamente para o seu ambiente Hyprland no CachyOS.

---

## 📌 1. O que é?

O **Hypr.AI** é um launcher nativo para Wayland/Hyprland, acionado via [Rofi](https://github.com/davatorium/rofi), projetado para atuar como uma central unificada e instantânea de atalhos para ferramentas de Inteligência Artificial.

Ele organiza todo o seu ecossistema de IA em uma interface visual fluida, teclado-cêntrica e dividida em três pilares principais:
1. **Agentes de Linha de Comando (CLI)** rodando no terminal Kitty com Fish Shell.
2. **Aplicativos Desktop Nativos/GUI** (IDEs e clientes de IA).
3. **Portais e Plataformas Web de IA** abrindo diretamente no seu navegador padrão (Zen Browser).

---

## 🎯 2. Para que serve?

No dia a dia de desenvolvimento e pesquisa com IA, é comum alternar constantemente entre:
- Sessões interativas no terminal com **AGY CLI** (Google Antigravity) e **Claude Code CLI** (Anthropic);
- Ambientes visuais pesados como a IDE **Antigravity 2.0** e o **Claude Desktop**;
- Diferentes portais na web com modelos variados (Gemini, ChatGPT, DeepSeek, Kimi, Qwen, Perplexity, v0, etc.).

O **Hypr.AI** resolve essa fragmentação:
- **Acesso em 1 segundo**: Basta pressionar `Super + I` de qualquer lugar do sistema para abrir o menu.
- **Zero fricção de terminal**: Dispara os agentes de terminal automaticamente dentro de instâncias dedicadas do Kitty configuradas com seu Fish shell nativo.
- **Submenu web inteligente**: Navegação sem poluir o menu principal, com agrupamento por categorias e curadoria aberta em texto puro (`sites.conf`).
- **Totalmente desacoplado e customizável**: Permite adicionar, remover ou editar qualquer atalho sem alterar linhas de código complexas.

---

## 🛠️ 3. Como foi construído?

A construção do **Hypr.AI** tomou como referência direta a arquitetura, a ergonomia e o código do seu projeto [HyprVision](https://github.com/mastermaiolo/hyprvision), adaptando-os para gerenciamento de aplicações e links.

### 🏛️ Arquitetura e Engenharia de Software

```
hyprai/
├── config/
│   └── sites.conf      # Banco de dados declarativo em texto puro
├── rofi/
│   └── hyprai.rasi     # Tema Rofi com design system do HyprVision
├── ui/
│   └── launcher.sh     # Engine do menu em Bash com controle de estados
├── install.sh          # Automação de setup, links e injeção em binds.lua
├── uninstall.sh        # Script de remoção limpa
├── README.md           # Visão geral do repositório
└── SOBRE.md            # Este guia conceitual e técnico
```

### 🎨 3.1. Design System e Interface Rofi (`rofi/hyprai.rasi`)
- **Sistema coerente, não herança visual solta**: o tema segue um grid fechado de múltiplos de 4px, raios concêntricos (janela `24px` → padding `16px` → filhos `8px`) e uma paleta OKLCH gerada e verificada por script (contraste ≥4.5:1 em todo texto). Ver `DESIGN.md` para os tokens exatos e o porquê de cada número.
- **Camada "glass"**: a janela é a camada funcional/flutuante, translúcida (`~95%` de opacidade), renderizada sobre o blur global já ativo no compositor Hyprland — não precisa de nenhuma regra extra.
- **Cor tonal dinâmica — Noctalia (principal)**: `install.sh` registra `theme/noctalia.rasi.tmpl` como *user template* em `~/.config/noctalia/config.toml`. O próprio Noctalia regenera `~/.local/state/hyprai/noctalia-colors.rasi` sempre que o wallpaper/scheme muda — o launcher só lê esse arquivo e injeta via `-theme-str`, sem polling nem script de conversão.
- **Caelestia (compatibilidade)**: se não houver Noctalia mas existir `~/.local/state/caelestia/scheme.json`, o launcher extrai as cores dali e monta o mesmo bloco de tokens na hora.
- **Paleta Estática Fallback**: sem nenhum dos dois, usa uma paleta **Dark Violet / Neon Indigo** verificada (`#A18DEE` sobre `#0D0D10`), com o mesmo mapeamento de tokens — trocar a fonte de cor nunca muda a estrutura do tema.

### 🧠 3.2. Lógica e Mecânica do Launcher (`ui/launcher.sh`)
- **Strict Mode**: Construído com `set -euo pipefail` garantindo estabilidade contra variáveis não definidas ou falhas silenciosas.
- **Resolução de Links Simbólicos**: Utiliza `readlink -f "${BASH_SOURCE[0]}"` para que o script descubra seu diretório real mesmo quando invocado através do symlink em `~/.local/bin/hyprai`.
- **Navegação Aninhada e Submenus**:
  - Utiliza o padrão `dim_row`, `sep` e `pick_id` do HyprVision para embutir tags ocultas `[id]` nas linhas renderizadas pelo Rofi e extraí-las no clique.
  - O submenu `AI WEB` exibe o botão `↩ Voltar` (`__back__`), que ao ser selecionado invoca `exec "$0"`, retornando instantaneamente para a raiz do menu sem fechar ou engasgar o processo.
  - Clicks acidentais em separadores de categoria (`── CATEGORIA ──`) são interceptados e ignorados, reabrindo o menu suavemente.

### ⚡ 3.3. Integração com Hyprland, Wayland & UWSM
- **Isolamento de Escopos com UWSM**:
  O Hyprland no CachyOS utiliza o `uwsm app --` para gerenciar ciclos de vida das janelas via unidades transientes do systemd.
- **Resolução de $PATH no Systemd**:
  Como o `systemd --user` não herda o `~/.local/bin` por omissão, o Hypr.AI foi projetado para:
  1. Utilizar caminhos absolutos (`os.getenv("HOME") .. "/.local/bin/hyprai"`) no `binds.lua`;
  2. Adicionar `export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"` no `~/.config/uwsm/env`;
  3. Disparar o Kitty chamando diretamente o shell interativo (`kitty --title "$title" fish -i -c "$cmd"`), garantindo que funções, aliases e toolchains do Fish estejam 100% disponíveis.

### 📝 3.4. Curadoria Declarativa de Sites (`config/sites.conf`)
- O arquivo segue a sintaxe limpa:
  ```conf
  id | ícone | Nome da Ferramenta | categoria | url
  ```
- O script lê o arquivo linha a linha, agrupa automaticamente os sites pelas categorias (`chat`, `search`, `dev`, `code`, `media`) e insere os divisores visuais formatados.
- Pelo próprio menu, a opção *"📝 Editar lista de sites"* detecta automaticamente o editor disponível (`zeditor`, `nvim`, `nano`, `micro`, `kate`, etc.) e o abre instantaneamente no arquivo correto.

---

## 🚀 Resumo de Uso

| Ação | Como fazer |
|---|---|
| **Abrir menu globalmente** | Pressionar `Super + I` |
| **Abrir menu via terminal** | Digitar `hyprai` no Fish shell |
| **Adicionar novo site de IA** | Editar `~/.config/hypr/hyprai/config/sites.conf` |
| **Reinstalar ou atualizar links** | Rodar `~/Projectos/hyprai/install.sh` |
