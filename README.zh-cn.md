<div align="center">

# HYPR.AI

**适用于 Hyprland 的原生 AI 命令交互面板与快速启动器**

[![Release](https://img.shields.io/github/v/release/mastermaiolo/hyprai?style=flat-square&color=00D2FF&label=release)](https://github.com/mastermaiolo/hyprai/releases/latest)
[![许可证](https://img.shields.io/badge/%E8%AE%B8%E5%8F%AF%E8%AF%81-MIT-E9E5DC?style=flat-square&labelColor=13161A)](LICENSE)
[![合成器](https://img.shields.io/badge/%E5%90%88%E6%88%90%E5%99%A8-Hyprland%20%2F%20Wayland-38BDF8?style=flat-square&labelColor=13161A)](https://hyprland.org)
[![Shell](https://img.shields.io/badge/%E8%BF%90%E8%A1%8C%E6%97%B6-fish%20%2B%20bash%20%2B%20rofi-B62B32?style=flat-square&labelColor=13161A)](https://github.com/davatorium/rofi)

<br/>

[English (UK)](README.md) · [Português (Brasil)](README.pt-br.md) · [Português (Portugal)](README.pt-pt.md) · [Español](README.es-es.md) · **简体中文**

<br/>

<img src="assets/readme/hero.svg" alt="Hypr.AI 核心视觉图" width="100%"/>

</div>

<br/>

> **适用于 Hyprland 的原生 AI 启动器** — 将命令行 CLI 智能体、桌面应用程序以及精选云端门户统一汇集于单一键盘驱动的 Rofi 毛玻璃界面。零硬编码：工具仅在系统中真实安装时动态呈现，整个窗口即时跟随壁纸生成的 Material You 色调。

---

## 01 / 导航目录

- [02 / 特性速览](#02--特性速览)
- [03 / 核心能力与工程设计](#03--核心能力与工程设计)
- [04 / 工具图谱与展示](#04--工具图谱与展示)
- [05 / 控制面板与使用方式](#05--控制面板与使用方式)
- [06 / 环境要求与安装部署](#06--环境要求与安装部署)
- [07 / 配置指南与个性化定制](#07--配置指南与个性化定制)
- [08 / 流水线架构与内部机制](#08--流水线架构与内部机制)
- [09 / 故障排查与诊断](#09--故障排查与诊断)
- [10 / 架构传承与项目血统](#10--架构传承与项目血统)

---

## 02 / 特性速览

Hypr.AI 彻底消除了在零散终端窗口、臃肿 IDE 以及海量浏览器标签页之间来回切换的割裂体验。

<br/>

<div align="center">
  <img src="assets/readme/at-a-glance.svg" alt="Hypr.AI 特性速览" width="100%"/>
</div>

<br/>

### 核心架构支柱

| 架构支柱 | 技术实现机制 | 工程质量保障 |
|---|---|---|
| **运行时动态探测** | 基于交互式 `fish` shell 环境的候选命令按需探测 | 零失效废弃菜单项；软件安装或卸载时自动增删 |
| **Material You 毛玻璃** | 60% 物理背景透明度、1.5px 顶部受光高光及 Noctalia 动态色调桥接 | 深度合成器模糊，完美融入桌面壁纸实时色彩 |
| **协议安全性** | 经由 Rofi dmenu 管道直接注入 NUL 字节分隔的图标流 | 完整保留高分辨率 SVG/PNG，防止 Bash 字符串截断 |
| **无冲突热键集成** | 安装期间利用 `hyprctl -j binds` 自动检测按键冲突 | 安全注入 `Super + I`，不覆盖用户既有键位映射 |
| **5 种语言原生套件** | 依据操作系统 locale 自动匹配展示语言 | 原生覆盖 EN-GB、PT-BR、PT-PT、ES-ES 以及 ZH-CN |

---

## 03 / 核心能力与工程设计

<br/>

<div align="center">
  <img src="assets/readme/capabilities.svg" alt="Hypr.AI 核心能力图" width="100%"/>
</div>

<br/>

### 1. 交互式 Fish Shell PATH 动态解析
在 Wayland 与 UWSM 体系下，Hyprland 为子进程分配的是极简的系统 `$PATH`（通常仅限于 `/usr/bin`、`~/.local/bin` 和 `~/.cargo/bin`）。而用户通过 Linuxbrew（`/home/linuxbrew/.linuxbrew/bin`）、NVM、Pyenv 或 asdf 安装的环境，往往位于 `~/.config/fish/config.fish` 的交互式守护块中（`if status is-interactive`）。

若启动器仅在常规非交互式子 shell 中探测候选程序，通过 Brew 或虚拟环境安装的 CLI 智能体将完全不可见。Hypr.AI 的解决方案是：每次激活启动器时，向 `fish -i` 统一请求解析完成的 `$PATH` **仅此一次**，并在原生 Bash 中对照该合并路径快速测试所有候选可执行文件。这不仅避免了并发派生 30 个 Fish 进程的开销，更从底层确保了“探测可见即能正常启动”。

### 2. 精准校准的物理毛玻璃光学
在 Wayland 合成器下实现真实的玻璃视觉质感，需要严格平衡模糊度与面板透明度：
- **精确校准的 60% 透明度：** 窗口背景 `bg0` 固定为 60%（`#0D0D10` @ `0x99`）。一旦不透明度超过 85%，穿透光线被阻断，合成器的均匀模糊就会沦为毫无通透感的纯色平涂；低于 50% 时，亮色壁纸下的文字可读性则会急剧下降。
- **物理顶部单侧受光条：** 真实的物理玻璃板主要在顶部边缘折射环境光。Hypr.AI 采用 `border: 1.5px 0px 0px 0px`，杜绝了全封闭边框导致的“塑料卡片感”。
- **图层规则配置 `xray = false`：** 在 Hyprland 中，`xray` 指令会让模糊着色器跳过中间图层。但在壁纸自身即为全屏独立图层的桌面环境（如 Noctalia）中，`xray = true` 会跳过壁纸本身，使毛玻璃效果无声消失。安装程序强制设定并校验 `xray = false`。

### 3. 并行数组架构与 NUL 字节协议
Rofi 的原生图标协议（`-show-icons`）要求在显示文本与图标元数据之间插入纯 NUL 字节（`\0`）（例如：`条目\0icon\x1f/路径/图标.svg`）。由于 Bash 变量无法存储 NUL 字符而不发生截断，Hypr.AI 在内存中并行维护标题、唯一 ID 和图标路径数组，并在标准输入管道中通过 `printf` 直接写入 NUL 字节流。菜单仅返回选中行的数字索引（`-format i`），在内部映射回目标命令，界面绝对不会出现多余的原始 ID。

---

## 04 / 工具图谱与展示

<br/>

<div align="center">
  <img src="assets/readme/showcase.svg" alt="Hypr.AI 工具图谱展示" width="100%"/>
</div>

<br/>

### 生态候选工具支持矩阵

Hypr.AI 内置了涵盖三大主要领域的预配置候选工具。条目在对应程序安装前保持隐蔽，零干扰。

| 领域分类 | 已支持工具及生态节点 | 派生执行子系统 |
|---|---|---|
| **终端命令行智能体 (CLI)** | Claude Code、Antigravity CLI、Gemini CLI、Codex CLI、Aider、GitHub Copilot CLI、Cursor CLI、OpenCode、Goose、Ollama、Qwen Code、Crush、Mods、Plandex、Droid、OpenHands、Cline、Hermes CLI | 专属终端窗口（`kitty`、`ghostty`、`foot`、`alacritty` 或 `wezterm`），运行 `fish -i -c "$cmd"` |
| **桌面图形应用** | Claude Desktop、Antigravity 2.0、Cursor、Windsurf、Zed、LM Studio、Jan、GPT4All、AnythingLLM、Chatbox、Msty、Hermes Desktop | 原生 Wayland 桌面应用程序启动 |
| **精选 AI 云端门户** | 涵盖对话、搜索、写作、开发、编程、多媒体的 33 款云端平台 | 系统默认 Wayland 浏览器（`xdg-open "$url"`） |

<br/>

<div align="center">
  <img src="assets/screenshot.webp" alt="Hypr.AI 实际运行截图" width="85%"/>
  <p><em>Hypr.AI 在 Hyprland 环境下运行，配合 Noctalia 实现 Material You 实时动态色调</em></p>
</div>

<br/>

<details>
<summary><strong>展开查看 33 个预置云端 AI 门户完整列表</strong></summary>
<br/>

- **对话与基础大模型：** ChatGPT、Claude、Gemini、DeepSeek、Grok、Kimi（月之暗面）、Qwen（通义千问）、Mistral、Microsoft Copilot、Poe、HuggingChat、DuckDuckGo AI。
- **智能搜索与研究：** Perplexity AI、Genspark、Felo、Phind、Consensus。
- **文本写作与内容合成：** Claude Artifacts、Notion AI、Lex、TypingMind。
- **应用开发与代码辅助：** v0 (Vercel)、Lovable、Bolt.new、Replit Agent、GitHub Copilot Web。
- **多媒体与音视频生成：** Midjourney、Suno、Udio、ElevenLabs、Runway Gen-3、Luma Dream Machine、Flux / Black Forest Labs。

</details>

---

## 05 / 控制面板与使用方式

<br/>

<div align="center">
  <img src="assets/readme/control-surface.svg" alt="控制面板与操作按键" width="100%"/>
</div>

<br/>

### 键盘交互与全局快捷键

| 按键 / 命令 | 运行上下文 | 执行动作 |
|---|---|---|
| `Super + I` | Hyprland 全局桌面 | 呼出或隐藏 Hypr.AI 启动面板 |
| `hyprai` | 终端 / Shell 命令行 | 从命令行直接调用启动器 |
| `hyprai --doctor` | 终端 / Shell 命令行 | 运行全方位环境检测与故障诊断套件 |
| `输入关键词` | 菜单内部搜索框 | 对工具名称、厂商及分类进行实时模糊过滤 |
| `Enter` | 选定条目 | 在独立终端中启动智能体、打开桌面应用或跳转网页 |
| `Esc` | 菜单内部 | 立即退出面板，不残留多余进程 |
| `↩ 返回` | 网页门户或设置子菜单 | 返回顶层工具启动列表 |

---

## 06 / 环境要求与安装部署

### 基础环境依赖

- **合成器：** Hyprland
- **菜单引擎：** `rofi`（版本需 &ge; 1.7，支持原生图标协议）
- **Shell 环境：** `bash` 与 `fish`（Fish 用于实时解析交互式 PATH 及运行 CLI 智能体）
- **终端仿真器：** `kitty`、`ghostty`、`foot`、`alacritty` 或 `wezterm`（自动探测或在 `hyprai.conf` 中指定）
- **字体：** **Inter** 字体家族（Arch Linux：`pacman -S inter-font`）
- **色彩框架（推荐）：** [Noctalia](https://github.com/noctalia-dev/noctalia-shell) 或 [Caelestia](https://github.com/caelestia-dots/shell)（若均未安装，则回退至内置的静态暗紫 / 霓虹靛调色板）
- **可选增强组件：** `libnotify`（系统通知）、`uwsm`（systemd 用户会话隔离）

### 自动化一键安装

```bash
# 克隆代码仓库
git clone https://github.com/mastermaiolo/hyprai.git
cd hyprai

# 执行安装脚本
./install.sh
```

### 安装程序执行流程

1. 将脚本、配置文件规范与图标完整部署至 `~/.config/hypr/hyprai/`。
2. 在 `~/.local/bin/hyprai` 创建全局可执行封装文件。
3. 若检测到 Noctalia，自动注册 Material You 动态色调模板。
4. 查询 `hyprctl -j binds` 确保 `Super + I` 快捷键未被占用；若有冲突则交互式请求备用键，并在 `~/.config/hypr/config/binds.lua`（或 `hyprland.lua`）中的 `-- hyprai:begin/end` 区块安全注入热键。
5. 在修改 `windowrules.lua` 添加毛玻璃图层规则前向用户发起确认。

> [!TIP]
> 在 Noctalia 环境下完成首次安装后，请随意更换一次壁纸或强调色，以便 Noctalia 首次生成色调桥接文件（`~/.local/state/hyprai/noctalia-colors.rasi`）。

---

## 07 / 配置指南与个性化定制

所有配置文件均为纯文本格式，存放于 `~/.config/hypr/hyprai/config/`：

| 配置文件 | 功能用途 |
|---|---|
| `config/tools.conf` | CLI 命令行智能体与桌面应用程序候选定义 |
| `config/sites.conf` | 按类别划分的精选 AI 在线门户清单 |
| `config/hyprai.conf` | 运行时全局偏好（例如 `terminal = kitty`，留空则为自动选择） |
| `rofi/user.rasi` | 可选的用户自定义样式（窗口对齐位置、偏移量、宽度及字体覆盖） |

> [!IMPORTANT]
> 重新运行 `./install.sh` 升级时，**绝不会覆盖**您现有的 `.conf` 文件或 `user.rasi`。您的自定义工具库和修改将在更新中始终得以保留。

### 添加本地自定义工具

在 `~/.config/hypr/hyprai/config/tools.conf` 中追加一行：

```conf
# id | 图标 | 显示名称 | 副标题/厂商 | 类别 | 候选路径/可执行名 | svg图标文件名 | 启动参数
myagent|🤖|My Agent|Custom Lab|cli|myagent;myagent-cli|myagent.svg|--chat
```

- **`类别`：** `cli`（在独立 fish 终端中运行）或 `desktop`（以图形窗口运行）。
- **`候选路径`：** 分号（`;`）分隔的一个或多个二进制名称/绝对路径。按顺序探测，首个匹配项生效。纯命令名在 `$PATH` 中检索，以 `~` 或 `/` 开头的路径则直接测试。
- **`svg图标`：** 存放于 `~/.config/hypr/hyprai/svg/` 中的矢量图文件（缺失时自动回退为第 2 列的 emoji）。
- **`启动参数`：** 可选的静态参数（适用于同一二进制文件同时支持 CLI 与 GUI 模式的场景）。

### 添加在线 AI 门户

在 `~/.config/hypr/hyprai/config/sites.conf` 中追加一行：

```conf
# id | 图标 | 显示名称 | 分类 | url | svg图标文件名
myportal|🌐|My Portal|chat|https://example.ai|portal.svg
```

可用分类：`chat`、`search`、`write`、`dev`、`code`、`media`。

### 调整启动器窗口位置

若需调整窗口显示位置（例如置于顶部状态栏正下方），创建 `~/.config/hypr/hyprai/rofi/user.rasi`：

```css
/* ~/.config/hypr/hyprai/rofi/user.rasi */
window {
    location: north;
    y-offset: 120px;
    width: 720px;
}
```

---

## 08 / 流水线架构与内部机制

<br/>

<div align="center">
  <img src="assets/readme/architecture.svg" alt="Hypr.AI 流水线架构图" width="100%"/>
</div>

<br/>

### 代码仓库目录结构

```
hyprai/
├── assets/
│   ├── readme/            # 模块化设计系统 SVG 资产（hero、capabilities 等）
│   └── screenshot.webp    # 物理真实界面截图
├── config/
│   ├── hyprai.conf        # 终端仿真器及通用首选项
│   ├── sites.conf         # 精选在线门户清单
│   └── tools.conf         # CLI 智能体与桌面应用候选名单
├── rofi/
│   └── hyprai.rasi        # 4px 网格体系主题样式表及设计变量
├── svg/                   # Rofi 原生协议专属矢量图标库
├── theme/
│   └── noctalia.rasi.tmpl # 由 Noctalia 实时编译的 Material You 色彩模板
├── ui/
│   └── launcher.sh        # 核心探测、菜单组装及调度派发引擎
├── install.sh             # 幂等安装程序与热键安全注入器
├── uninstall.sh           # 干净对称的卸载脚本
├── DESIGN.md              # coherent-design 规范细节与光学计算依据
└── SOBRE.md               # 葡萄牙语技术设计白皮书与工程抉择
```

---

## 09 / 故障排查与诊断

遇到异常时，请优先运行内置的自检诊断程序：

```bash
hyprai --doctor
```

`hyprai --doctor` 将自动排查底层依赖、终端绑定、主题来源、候选程序命中状态、语法配置错误、按键绑定有效性以及合成器图层规则。

<br/>

<div align="center">
  <img src="assets/readme/failure-modes.svg" alt="故障排查矩阵" width="100%"/>
</div>

<br/>

### 常见问题与解决方案

<details>
<summary><strong>1. 已安装的工具未在菜单中显示</strong></summary>
<br/>

`tools.conf` 中定义的候选程序名称可能与您系统中的实际二进制名称不一致。
1. 在交互式 Fish 终端中运行 `which <工具名>` 查看真实路径。
2. 检查该名称是否包含在 `tools.conf` 的 `candidates` 列中。
3. 探测机制为了保持界面整洁，默认采用静默失效机制。只需用分号（`;`）将实际命令名称追加至候选列表中即可。

</details>

<details>
<summary><strong>2. 菜单呈现纯黑/纯白死板底色，无毛玻璃半透明效果</strong></summary>
<br/>

1. **图层规则缺失：** 在 Hyprland 中，layer-shell 表面必须显式指定目标 namespace 的图层规则才能启用模糊。请重新运行 `./install.sh` 并确认添加规则。
2. **错误启用了 `xray = true`：** 若图层规则包含 `xray = true`，合成器会穿透中间层。而在 Noctalia 这类壁纸作为全屏图层存在的环境中，模糊会直接穿透壁纸本身，导致毛玻璃效果彻底失效。请确认规则中明确设定为 `xray = false`。
3. **背景不透明度过高：** 若 `bg0` 的透明度设置高于 85%，光线无法穿透，视觉上会表现为死板的实色。Hypr.AI 默认标定为 60%。

</details>

<details>
<summary><strong>3. 截图里显示正常毛玻璃，但在物理显示器上却是纯色</strong></summary>
<br/>

类似 `grim` 的截图工具是在合成器的模糊滤镜处理前抓取缓冲区的。即便只有 5% 的微弱透明度，截图中也会呈现清晰锐利的壁纸（人脑会将其误读为通透玻璃），而实体屏幕上展现的则是模糊后的均匀色块。请务必以人眼在物理显示器上的观感为准。

</details>

<details>
<summary><strong>4. 在 Noctalia 中更换壁纸后，菜单配色未联动更新</strong></summary>
<br/>

Noctalia 会在壁纸或配色方案变更时重新编译模板。若色彩桥接未即时同步，可通过以下命令手动强制刷新：
```bash
noctalia msg config-reload && noctalia msg templates-apply
```

</details>

---

## 10 / 架构传承与项目血统

<br/>

<div align="center">
  <img src="assets/readme/provenance.svg" alt="架构传承与设计血统" width="100%"/>
</div>

<br/>

### 架构传承与设计体系

- **系统架构：** 直接继承并发展自 [HyprVision](https://github.com/mastermaiolo/hyprvision) 的人体工学规范、交互模式与 Wayland 菜单设计。
- **设计系统：** 严格遵循 **coherent-design** 规范 — 4px 基础网格间距、同心圆角约束（24px 外框、16px 容器、8px 子元素），以及经由 OKLCH 验证、WCAG 对比度 &ge; 4.5:1 的色阶规范。完整设计数值记录于 [DESIGN.md](DESIGN.md)。
- **创作者：** Master Maiolo · MAIOLO / SYSTEMS LAB。

### 开源许可证

本项目基于 **MIT 许可证** 开放授权。完整条款请参阅 [LICENSE](LICENSE) 文件。

---

<div align="center">
<sub>MAIOLO / SYSTEMS LAB · HYPR.AI · 适用于 HYPRLAND 的原生 AI 命令交互面板</sub>
</div>
