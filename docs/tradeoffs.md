# Tradeoffs — Why Ghostty, Why Not Warp, Why Keep Hyper

## Why Ghostty primary (over Warp)

- **Free forever, no account needed.** Warp requires login and has paid Pro tier.
- **Native macOS, GPU-native, low RAM (~80 MB vs Warp ~400 MB, Hyper ~500 MB).**
- **No telemetry.** Warp phones home by default.
- **Keyboard-first.** Full remap via text config; no mouse-gated UX.
- **We already have Claude Code CLI as the AI layer** — Warp's agent mode and blocks duplicate what `claude` already does better (plans, memory, MCP). Paying for Warp's AI would be redundant.

## Why keep Hyper (as fallback only)

- Launch in under a second when Ghostty misbehaves (config error, GPU glitch, beta regression).
- Electron = portable; zero surprise behavior across macOS versions.
- Modernized to share our theme/font/keymap so switching is zero-cost.

## Hyper's honest limits

- ~500 MB RAM per window (Electron overhead)
- GPU renderer less mature than Ghostty's native
- Upstream stalled for 2+ yrs as of 2026
- Do not invest in Hyper-specific plugins; treat as fallback

## Why not Warp even free

- Account requirement: even free tier wants login for most AI features
- Telemetry defaults on
- Blocks UX is nice but doesn't map to our plan/spec/prompt workflow (which is already in brain/)
- One more layer between "command I typed" and "output I need"

## Why not WezTerm / Alacritty / Kitty

- WezTerm: powerful Lua config but the config burden exceeds the benefit for a personal setup
- Alacritty: no tabs/splits native; requires tmux, which adds cognitive load
- Kitty: solid, but Ghostty matches on speed and has cleaner config DSL
