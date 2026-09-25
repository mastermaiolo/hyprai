# Hypr.AI

[🇵🇹 Português](README.pt.md) · [🇬🇧 English](README.md) · [🇪🇸 Español](README.es.md) · 🇨🇳 **简体中文**

[![Release](https://img.shields.io/github/v/release/mastermaiolo/hyprai?label=版本)](https://github.com/mastermaiolo/hyprai/releases/latest)

<p align="center"><img src="assets/screenshot.webp" alt="Hypr.AI — 一键直达本机所有 AI 工具"></p>

**Hyprland 原生 AI 启动器** —— 命令行智能体、桌面应用与精选网页门户，统一收进一个 Rofi 菜单。没有任何硬编码：只有真正安装了的工具才会出现，整个窗口的配色也会跟随壁纸的 Material You 调色板。

## 目录

[功能](#功能) · [可检测的工具](#可检测的工具) · [依赖](#依赖) · [安装](#安装) · [使用](#使用) · [配置](#配置) · [添加工具或网站](#添加工具或网站) · [疑难排查](#疑难排查) · [架构](#架构) · [致谢](#致谢) · [许可证](#许可证)

## 功能

- **运行时检测** —— 命令行智能体和桌面应用在 `tools.conf` 中以*候选项*声明；启动器每次打开都会逐个探测，只显示确实存在的。装上某个工具，它自己就会出现；卸载后自动消失，无需手工编辑。
- **检测使用你交互式 `fish` 的 `PATH`**，而不是 Hyprland 的：Hyprland 交给进程的是一个最小化的 `PATH`，所以通过 linuxbrew/nvm/pyenv 安装的工具明明能跑却会「隐身」。启动器每次打开时向 `fish -i` 取一次 `PATH`——正是之后启动工具的那个交互式 shell——所以检测到的和实际运行的始终一致。
- **33 个精选 AI 网页门户**，收在 `sites.conf` 中，按对话、搜索、写作、开发、代码、多媒体分组，用默认浏览器打开。
- **Material You 色调**：整套配色（背景、文字、容器，而非仅强调色）实时取自 [Noctalia](https://github.com/noctalia-dev/noctalia-shell)，并以 [Caelestia](https://github.com/caelestia-dots/shell) 作为备选。菜单看起来就是桌面的一部分，而不是从别的主题借来的挂件。
- **真正的玻璃质感**，不是一块扁平的半透明方块：只在上缘的一道高光、在模糊背景之上按色调提亮的内容层，以及一个恰好让合成器模糊真正显现的不透明度（见 [DESIGN.md](DESIGN.md)）。
- **真实图标**：使用 Rofi 原生图标协议，逐条目指定 SVG/PNG；没有图标文件时回退为 emoji 小标签。
- **五种语言** —— pt-PT、pt-BR、es-ES、en-GB 与中文 —— 依系统区域设置自动选择。
- **封闭的设计系统**：基础网格与统一间距、同心圆角、单词标签，以及经 WCAG 对比度验证的 OKLCH 调色板。每一个数值都记录在 [DESIGN.md](DESIGN.md)。
- **Hyprland 集成**：全局快捷键 `Super + I`，在 `uwsm` 或纯 Hyprland 下均可用；安装脚本会询问是否添加那条让玻璃质感得以生效的 layer 规则。

## 可检测的工具

以下全部已预置为候选项，在你安装之前始终处于隐藏状态。

| 类别 | 工具 |
|---|---|
| 命令行智能体 | Claude Code · Antigravity CLI · Gemini CLI · Codex CLI · Aider · GitHub Copilot CLI · Cursor CLI · OpenCode · Goose · Ollama · Qwen Code · Crush · Mods · Plandex · Droid · OpenHands · Cline · Hermes |
| 桌面应用 | Claude Desktop · Antigravity 2.0 · Cursor · Windsurf · Zed · LM Studio · Jan · GPT4All · AnythingLLM · Chatbox · Msty · Hermes Desktop |
| 网页门户 | 33 个网站 —— Gemini、Claude、ChatGPT、DeepSeek、Grok、Kimi、Qwen、Mistral、Copilot、Perplexity、v0、Lovable、Midjourney、Suno、ElevenLabs、Runway 等 |

不在列表里的，只需在 `tools.conf` 里加一行 —— 见[添加工具或网站](#添加工具或网站)。

## 依赖

- Hyprland
- rofi（1.7 以上，图标协议所需）
- bash，以及 **fish** —— 命令行智能体在 `kitty` 里以你的交互式 fish 启动，这同时也是检测能看到真实 `PATH` 的原因
- **推荐：** [Noctalia](https://github.com/noctalia-dev/noctalia-shell) 或 [Caelestia](https://github.com/caelestia-dots/shell) —— 两者都没有时，菜单会退回一套固定的暗紫配色
- 可选：libnotify（通知）、uwsm（会话隔离）

## 安装

```bash
git clone https://github.com/mastermaiolo/hyprai && cd hyprai
./install.sh
```

安装脚本会把文件复制到 `~/.config/hypr/hyprai/`，在 `~/.local/bin/` 创建 `hyprai` 可执行文件，向 Noctalia 注册色调桥接（若已安装），向 `binds.lua` 添加 `Super + I` 快捷键（若文件存在，且若该组合已被占用会询问改用哪个键），并在向你的 `windowrules.lua` 添加玻璃 layer 规则前**先询问**。它从不改动你的全局模糊设置。

> 安装完成后，在 Noctalia 里切换一次壁纸或强调色，让它首次生成色彩桥接文件。

## 使用

- `Super + I` —— 打开菜单
- `hyprai` —— 在终端里同样可用
- 输入即筛选；`Enter` 打开；`Esc` 关闭
- **网页门户**会打开子菜单；`↩ 返回`回到上一层

## 配置

两个声明式纯文本文件，都可以直接从菜单里编辑：

| 文件 | 内容 |
|---|---|
| `~/.config/hypr/hyprai/config/tools.conf` | 命令行智能体与桌面应用，含检测候选项 |
| `~/.config/hypr/hyprai/config/sites.conf` | 精选网页门户，按类别分组 |

> `install.sh` 在重装时**刻意不覆盖**这两个文件 —— 你的精选内容不会在更新中丢失。在仓库里修改它们之后，需要手动复制过去。

## 添加工具或网站

**本地工具**（`tools.conf`）：

```conf
id | 图标 | 名称 | 副标题 | 类别 | 候选项 | svg | args
```

- `类别` —— `cli`（在 kitty 终端中运行）或 `desktop`（图形应用）
- `候选项` —— 一个或多个二进制名/路径，用 `;` 分隔，按顺序探测；第一个存在的胜出，并成为启动命令。裸名称在 `PATH` 中查找；绝对路径（或以 `~` 开头）直接测试
- `args` —— 可选的固定参数，适用于同一个二进制同时提供 CLI 与 GUI 的情况：

```conf
hermes_cli|🪽|Hermes|Nous Research|cli|hermes|hermes.png|chat
hermes_desktop|🪽|Hermes Desktop|Nous Research|desktop|hermes|hermes-agent-text.svg|desktop
```

**网页门户**（`sites.conf`）：

```conf
id | 图标 | 名称 | 类别 | https://url | svg
```

类别：`chat`、`search`、`write`、`dev`、`code`、`media`。

两个文件中的 `svg` 列都指向 `svg/` 目录下的文件（PNG 同样可用），缺失时回退为第二列的 emoji。

## 疑难排查

**我装了的工具没有出现。** `候选项` 里的二进制名大概和你的不一致 —— 用 `which <名称>` 确认后修改那一行。检测是刻意静默失败的：名字写错只会让该条目保持隐藏。

**菜单不透明，没有玻璃质感。** 三种原因，按顺序排查：
1. 缺少 layer 规则 —— 在 Hyprland 中，layer-shell 表面若没有针对其 namespace 的规则，就不会获得模糊。重新运行 `./install.sh` 并接受玻璃例外规则。
2. 该规则上写了 `xray = true` —— 重新运行 `./install.sh`，它现在会给出警告。xray 会让模糊跳过中间层、直接取背景，但在壁纸本身就*是*一个层的桌面上（例如 Noctalia 的壁纸），它恰好跳过了本该被模糊的那一层：清晰的壁纸直接透过面板，玻璃质感就无声无息地消失了。位于菜单背后的桌面挂件同理不会被模糊。
3. 不透明度太高 —— 超过约 85% 时，模糊已没有余光可贡献，面板看起来就是一块实色。`bg0` 出厂值为 70%。

**截图里有玻璃质感，但我的屏幕上没有。** 两者确实不同：`grim` 在合成器的模糊阶段之前抓图，所以那几个百分点的透明度显示的是*清晰*的壁纸（看起来像玻璃），而你的屏幕显示的是*模糊后*的壁纸（均匀，看起来像实色）。相信眼睛，不要相信截图 —— 校准正确时，两者应当一致。

**配色不跟随壁纸。** Noctalia 只在壁纸/配色方案变更时重新渲染模板。可用 `noctalia msg config-reload && noctalia msg templates-apply` 强制执行。

## 架构

```
hyprai/
├── config/
│   ├── sites.conf        # 精选网页门户
│   └── tools.conf        # 命令行智能体/桌面应用 —— 运行时探测
├── rofi/
│   └── hyprai.rasi       # 主题 —— 网格、圆角与调色板
├── svg/                  # 逐条目图标（Rofi 图标协议）
├── theme/
│   └── noctalia.rasi.tmpl # 由 Noctalia 渲染成色调桥接的模板
├── ui/
│   └── launcher.sh       # 启动器本体
├── install.sh
├── uninstall.sh
└── DESIGN.md             # 设计 token 及每个数值背后的理由
```

各行以并行数组（文本、id、图标）构建，交给 `rofi -dmenu -format i`，因此返回的索引可以映射回 id，而 id 从不显示在屏幕上。色调桥接是一个 `.rasi` 片段，由 Noctalia 在每次配色变更时重新生成；`launcher.sh` 通过 `-theme-str` 原样传入，因此换色无需重启任何东西。

## 致谢

基于 [HyprVision](https://github.com/mastermaiolo/hyprvision) 的架构、人机工程与设计约定构建。

布局、间距、配色与对比度遵循 **coherent-design** 体系 —— token 与理由见 [DESIGN.md](DESIGN.md)。

## 许可证

MIT
