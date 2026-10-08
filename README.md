<div align="center">

# HYPR.AI

**Native AI Command Surface &amp; Launcher for Hyprland**

[![Release](https://img.shields.io/github/v/release/mastermaiolo/hyprai?style=flat-square&color=00D2FF&label=release)](https://github.com/mastermaiolo/hyprai/releases/latest)
[![Licence](https://img.shields.io/badge/licence-MIT-E9E5DC?style=flat-square&labelColor=13161A)](LICENSE)
[![Platform](https://img.shields.io/badge/compositor-Hyprland%20%2F%20Wayland-38BDF8?style=flat-square&labelColor=13161A)](https://hyprland.org)
[![Shell](https://img.shields.io/badge/runtime-fish%20%2B%20bash%20%2B%20rofi-B62B32?style=flat-square&labelColor=13161A)](https://github.com/davatorium/rofi)

<br/>

**English (UK)** · [Português (Brasil)](README.pt-br.md) · [Português (Portugal)](README.pt-pt.md) · [Español](README.es-es.md) · [简体中文](README.zh-cn.md)

<br/>

<img src="assets/readme/hero.svg" alt="Hypr.AI Hero Canvas" width="100%"/>

</div>

<br/>

> **Native AI launcher for Hyprland** — CLI agents, desktop environments, and curated cloud portals unified under a single, keyboard-driven Rofi glass interface. Nothing is hard-coded: tools appear only when genuinely installed on your system, and the entire window follows your desktop wallpaper's Material You palette in real time.

---

## 01 / Navigation Index

- [02 / At a Glance](#02--at-a-glance)
- [03 / Capabilities &amp; Engineering](#03--capabilities--engineering)
- [04 / Candidate Atlas &amp; Showcase](#04--candidate-atlas--showcase)
- [05 / Control Surface &amp; Usage](#05--control-surface--usage)
- [06 / Requirements &amp; Installation](#06--requirements--installation)
- [07 / Configuration &amp; Customisation](#07--configuration--customisation)
- [08 / Pipeline Architecture &amp; Internals](#08--pipeline-architecture--internals)
- [09 / Troubleshooting &amp; Diagnostics](#09--troubleshooting--diagnostics)
- [10 / Lineage &amp; Provenance](#10--lineage--provenance)

---

## 02 / At a Glance

Hypr.AI eliminates the friction of switching between terminal windows, heavy IDEs, and browser tabs when orchestrating modern AI tools.

<br/>

<div align="center">
  <img src="assets/readme/at-a-glance.svg" alt="Hypr.AI At a Glance" width="100%"/>
</div>

<br/>

### Key Architectural Strengths

| Pillar | Technical Implementation | Architectural Guarantee |
|---|---|---|
| **Runtime Detection** | Dynamic candidate probing via interactive `fish` shell environment | Zero stale or dead entries; auto-discovery on install/uninstall |
| **Material You Glass** | 60% background alpha, 1.5px top-rim lighting, live Noctalia bridge | Deep compositor blur matching current wallpaper tonal scheme |
| **Protocol Safety** | NUL-delimited icon streaming directly to Rofi dmenu pipe | Preserves high-resolution SVGs/PNGs without shell truncation |
| **Non-Intrusive Keybinds** | Conflict detection via `hyprctl -j binds` during automated setup | Safe `Super + I` registration without overriding existing macros |
| **Multi-Language Core** | Automated locale resolution supporting 5 language suites | Native strings in EN-GB, PT-BR, PT-PT, ES-ES, and ZH-CN |

---

## 03 / Capabilities &amp; Engineering

<br/>

<div align="center">
  <img src="assets/readme/capabilities.svg" alt="Hypr.AI Subsystem Capabilities" width="100%"/>
</div>

<br/>

### 1. Interactive Fish Shell PATH Resolution
Under Wayland and UWSM, Hyprland launches processes with a minimal system `PATH` (typically limited to `/usr/bin`, `~/.local/bin`, and `~/.cargo/bin`). Environments managed via Linuxbrew (`/home/linuxbrew/.linuxbrew/bin`), NVM, Pyenv, or asdf are typically configured inside `~/.config/fish/config.fish` within interactive guards (`if status is-interactive`).

If a launcher evaluates candidate binaries using a standard subshell, CLI agents installed via Brew or virtual environments become completely invisible. Hypr.AI solves this by querying `fish -i` for its full evaluated `$PATH` **exactly once** upon menu invocation, testing all candidate binaries against this consolidated path in native Bash. This eliminates the latency of spawning 30 separate Fish processes whilst ensuring that what is detected mirrors what actually executes.

### 2. Physically Calibrated Glass Optics
Producing authentic glass on Wayland requires careful balance between compositor blur and surface transparency:
- **Calibrated Opacity (60%):** Window background `bg0` is calibrated to 60% opacity (`#0D0D10` @ `0x99`). Exceeding ~85% opacity chokes incoming light, rendering the compositor blur indistinguishable from flat paint. Below 50%, text legibility degrades over bright wallpapers.
- **Top-Only Rim Light:** Authentic physical glass only catches specular illumination on its top edge. Hypr.AI applies `border: 1.5px 0px 0px 0px`, avoiding full-box borders that flatten the appearance.
- **`xray = false` Layer Rule:** Hyprland's `xray` directive instructs the blur shader to skip intermediate layers. However, when using modern wallpaper daemons (such as Noctalia) where the wallpaper itself occupies a full-screen layer, `xray = true` skips the wallpaper, causing blur to collapse silently. Hypr.AI mandates and validates `xray = false`.

### 3. Parallel Array Protocol &amp; NUL Delimiters
Rofi's native icon protocol (`-show-icons`) expects a raw NUL byte (`\0`) between the entry text and metadata flags (e.g. `entry\0icon\x1f/path/to/icon.svg`). Because Bash variables cannot store NUL characters without truncating string content at the byte boundary, Hypr.AI maintains parallel arrays for labels, unique IDs, and icon paths, formatting and streaming the NUL bytes directly into the standard input pipe via `printf`. The selection returns purely as a numeric index (`-format i`), mapping directly back to candidate actions without polluting the UI with raw IDs.

---

## 04 / Candidate Atlas &amp; Showcase

<br/>

<div align="center">
  <img src="assets/readme/showcase.svg" alt="Hypr.AI Candidate Atlas" width="100%"/>
</div>

<br/>

### Ecosystem Candidates Matrix

Hypr.AI ships with pre-configured candidate definitions across three primary domains. Candidates remain hidden until their corresponding binaries or environments are detected.

| Domain | Supported Tools &amp; Ecosystem Nodes | Launch Subsystem |
|---|---|---|
| **CLI Agents** | Claude Code, Antigravity CLI, Gemini CLI, Codex CLI, Aider, GitHub Copilot CLI, Cursor CLI, OpenCode, Goose, Ollama, Qwen Code, Crush, Mods, Plandex, Droid, OpenHands, Cline, Hermes CLI | Dedicated terminal window (`kitty`, `ghostty`, `foot`, `alacritty`, `wezterm`) executing `fish -i -c "$cmd"` |
| **Desktop Environments** | Claude Desktop, Antigravity 2.0, Cursor, Windsurf, Zed, LM Studio, Jan, GPT4All, AnythingLLM, Chatbox, Msty, Hermes Desktop | Native Wayland application spawn |
| **Curated Web Portals** | 33 curated services categorised into Chat, Search, Writing, Development, Code, and Media | Default Wayland browser (`xdg-open "$url"`) |

<br/>

<div align="center">
  <img src="assets/screenshot.webp" alt="Hypr.AI Interface Capture" width="85%"/>
  <p><em>Hypr.AI running under Hyprland with Noctalia Material You tonal integration</em></p>
</div>

<br/>

<details>
<summary><strong>Full List of 33 Curated Web Portals (Click to Expand)</strong></summary>
<br/>

- **Chat &amp; Core Models:** ChatGPT, Claude, Gemini, DeepSeek, Grok, Kimi, Qwen, Mistral, Microsoft Copilot, Poe, HuggingChat, DuckDuckGo AI.
- **Search &amp; Intelligence:** Perplexity AI, Genspark, Felo, Phind, Consensus.
- **Writing &amp; Synthesis:** Claude Artifacts, Notion AI, Lex, TypingMind.
- **Development &amp; Code:** v0 by Vercel, Lovable, Bolt.new, Replit Agent, GitHub Copilot Web.
- **Media &amp; Generation:** Midjourney, Suno, Udio, ElevenLabs, Runway Gen-3, Luma Dream Machine, Flux / Black Forest Labs.

</details>

---

## 05 / Control Surface &amp; Usage

<br/>

<div align="center">
  <img src="assets/readme/control-surface.svg" alt="Hypr.AI Control Surface" width="100%"/>
</div>

<br/>

### Keyboard Ergonomics &amp; Hotkeys

| Input / Shortcut | Operational Context | Action Performed |
|---|---|---|
| `Super + I` | Global Hyprland Desktop | Toggles the Hypr.AI launcher surface |
| `hyprai` | Shell / Terminal Prompt | Dispatches launcher from command line |
| `hyprai --doctor` | Shell / Terminal Prompt | Executes complete diagnostic evaluation |
| `Type to Filter` | In-Menu Search Field | Real-time fuzzy filtering across names, vendors, and tags |
| `Enter` | Selected Row | Spawns agent in dedicated terminal, launches app, or opens portal |
| `Esc` | In-Menu | Dismisses launcher instantly without residual state |
| `↩ Back` | Portals / Settings Submenu | Navigates back to the root launcher menu |

---

## 06 / Requirements &amp; Installation

### Prerequisites

- **Compositor:** Hyprland
- **Menu Engine:** `rofi` (version 1.7+ with icon protocol support)
- **Shells:** `bash` and `fish` (Fish is required for interactive PATH resolution and CLI execution)
- **Terminal Emulator:** `kitty`, `ghostty`, `foot`, `alacritty`, or `wezterm` (auto-detected or configured in `hyprai.conf`)
- **Typography:** **Inter** font family (`pacman -S inter-font` on Arch Linux)
- **Colour Framework (Recommended):** [Noctalia](https://github.com/noctalia-dev/noctalia-shell) or [Caelestia](https://github.com/caelestia-dots/shell) (defaults to static Dark Violet / Neon Indigo without either)
- **Optional Dependencies:** `libnotify` (desktop notifications), `uwsm` (systemd user session management)

### Automated Installation

```bash
# Clone the repository
git clone https://github.com/mastermaiolo/hyprai.git
cd hyprai

# Execute installer
./install.sh
```

### What the Installer Does

1. Deploys scripts, configuration schemas, and icons to `~/.config/hypr/hyprai/`.
2. Creates the `hyprai` wrapper executable in `~/.local/bin/hyprai`.
3. Registers the Material You tonal template with Noctalia (if present).
4. Probes `hyprctl -j binds` to ensure `Super + I` is available; prompts for an alternative key if occupied, and appends the keybind safely between `-- hyprai:begin/end` markers in `~/.config/hypr/config/binds.lua` (or `hyprland.lua`).
5. Prompts before appending the required glass blur layer rule to `windowrules.lua`.

> [!TIP]
> After initial installation under Noctalia, cycle your wallpaper or accent colour once so Noctalia can render the tonal palette bridge file (`~/.local/state/hyprai/noctalia-colors.rasi`).

---

## 07 / Configuration &amp; Customisation

All configurations live in human-readable text files inside `~/.config/hypr/hyprai/config/`:

| Configuration File | Operational Purpose |
|---|---|
| `config/tools.conf` | Candidate definitions for CLI agents and desktop applications |
| `config/sites.conf` | Curated AI web portals, grouped by functional categories |
| `config/hyprai.conf` | Runtime preferences (e.g. `terminal = kitty`, or leave empty for auto-detection) |
| `rofi/user.rasi` | Optional user overrides (custom geometry, offsets, widths, fonts) |

> [!IMPORTANT]
> The `./install.sh` script **never overwrites** existing `.conf` files or `user.rasi` upon re-execution. Your custom additions and curation remain untouched during updates.

### Adding a Custom Local Tool

Add a line to `~/.config/hypr/hyprai/config/tools.conf`:

```conf
# id | icon | Name | Subtext | category | candidates | svg | args
myagent|🤖|My Agent|Custom Lab|cli|myagent;myagent-cli|myagent.svg|--chat
```

- **`category`:** `cli` (launches in interactive fish terminal) or `desktop` (launches as graphical application).
- **`candidates`:** Semicolon-separated list of executable names or paths. Probed in sequence; the first match wins. Bare names resolve via `$PATH`; paths starting with `~` or `/` are checked directly.
- **`svg`:** Vector icon file inside `~/.config/hypr/hyprai/svg/` (falls back to emoji in column 2).
- **`args`:** Optional static arguments (useful when a single binary serves both CLI and GUI modes).

### Adding a Custom Web Portal

Add a line to `~/.config/hypr/hyprai/config/sites.conf`:

```conf
# id | icon | Name | category | url | svg
myportal|🌐|My Portal|chat|https://example.ai|portal.svg
```

Available portal categories: `chat`, `search`, `write`, `dev`, `code`, `media`.

### Repositioning the Window

To reposition the window (for instance, beneath a top bar), create `~/.config/hypr/hyprai/rofi/user.rasi`:

```css
/* ~/.config/hypr/hyprai/rofi/user.rasi */
window {
    location: north;
    y-offset: 120px;
    width: 720px;
}
```

---

## 08 / Pipeline Architecture &amp; Internals

<br/>

<div align="center">
  <img src="assets/readme/architecture.svg" alt="Hypr.AI Execution Pipeline Architecture" width="100%"/>
</div>

<br/>

### Repository Layout

```
hyprai/
├── assets/
│   ├── readme/            # Modular design system SVGs (hero, capabilities, etc.)
│   └── screenshot.webp    # Physical UI capture
├── config/
│   ├── hyprai.conf        # Terminal emulator & general preferences
│   ├── sites.conf         # Curated web portals
│   └── tools.conf         # CLI agents & desktop app candidates
├── rofi/
│   └── hyprai.rasi        # Design system stylesheet (4px grid, radii, tokens)
├── svg/                   # Vector icon library for native Rofi protocol
├── theme/
│   └── noctalia.rasi.tmpl # Material You template compiled by Noctalia
├── ui/
│   └── launcher.sh        # Core orchestration & probing engine
├── install.sh             # Idempotent installer & keybind injector
├── uninstall.sh           # Clean uninstaller
├── DESIGN.md              # Coherent-design tokens & optical specifications
└── SOBRE.md               # Portuguese architectural manifesto
```

---

## 09 / Troubleshooting &amp; Diagnostics

Always begin diagnostic investigation with the built-in diagnostic harness:

```bash
hyprai --doctor
```

`hyprai --doctor` inspects installed dependencies, terminal detection, active theme source, detected candidates, syntax anomalies, keybind status, and compositor layer rules.

<br/>

<div align="center">
  <img src="assets/readme/failure-modes.svg" alt="Hypr.AI Troubleshooting Matrix" width="100%"/>
</div>

<br/>

### Common Diagnostic Scenarios

<details>
<summary><strong>1. A tool I have installed does not appear in the menu</strong></summary>
<br/>

The candidate executable name in `tools.conf` likely differs from the binary name on your system.
1. Run `which <tool-name>` in an interactive Fish terminal to locate the binary.
2. Verify if the binary name matches the `candidates` field in `tools.conf`.
3. Candidate detection fails silently by design to keep the menu clean. Add your alias or binary name to the candidate list separated by a semicolon (`;`).

</details>

<details>
<summary><strong>2. The menu appears completely opaque without glass blur</strong></summary>
<br/>

1. **Missing Layer Rule:** Wayland layer-shell surfaces receive no blur in Hyprland without an explicit rule targeting their namespace. Re-run `./install.sh` and accept the glass exception.
2. **`xray = true` Enabled:** If your layer rule specifies `xray = true`, the compositor skips intermediate layers. Because Noctalia wallpaper occupies a layer, the blur bypasses the wallpaper entirely, rendering the surface transparent or flat. Re-run `./install.sh` or ensure `xray = false` in your configuration.
3. **Excessive Opacity:** If `bg0` alpha is set higher than 85%, incoming blur is blocked and reads as flat paint. Hypr.AI defaults to 60%.

</details>

<details>
<summary><strong>3. Screenshots display glass, but physical monitors show flat surfaces</strong></summary>
<br/>

Tools like `grim` capture frame buffers prior to the compositor's blur pass. Even 5% transparency reveals sharp wallpaper details in screenshots (which the brain interprets as glass), while the physical display shows uniform blur. Always calibrate optical opacity based on direct monitor observation.

</details>

<details>
<summary><strong>4. Colours do not adapt when changing wallpapers in Noctalia</strong></summary>
<br/>

Noctalia renders templates upon wallpaper or scheme transitions. If the palette desynchronises, force an update via:
```bash
noctalia msg config-reload && noctalia msg templates-apply
```

</details>

---

## 10 / Lineage &amp; Provenance

<br/>

<div align="center">
  <img src="assets/readme/provenance.svg" alt="Hypr.AI Lineage &amp; Provenance" width="100%"/>
</div>

<br/>

### Lineage &amp; Design Heritage

- **Architecture:** Directly derived from the conventions, ergonomics, and Wayland menu architecture of [HyprVision](https://github.com/mastermaiolo/hyprvision).
- **Design System:** Follows the **coherent-design** methodology — strict 4px grid, concentric border radii (24px window, 16px container, 8px child elements), and verified OKLCH palettes maintaining WCAG contrast ratios &ge; 4.5:1. Complete specifications are documented in [DESIGN.md](DESIGN.md).
- **Author:** Master Maiolo · MAIOLO / SYSTEMS LAB.

### Licence

This project is licensed under the **MIT Licence**. See the [LICENSE](LICENSE) file for complete details.

---

<div align="center">
<sub>MAIOLO / SYSTEMS LAB · HYPR.AI · NATIVE AI COMMAND SURFACE FOR HYPRLAND</sub>
</div>
