# Dream Terminal

Reproducible macOS terminal + shell + IDE-integrated-terminal stack with Claude Code as the AI layer.

- **Primary:** Ghostty (native, fast, free)
- **Fallback:** Hyper (modernized, minimal)
- **IDE:** Cursor integrated terminal (aligned font/theme/keybinds)
- **Shell:** zsh + oh-my-zsh + starship
- **Theme:** Tokyo Night Storm (glass, opacity 0.78 / blur 40)
- **Font:** JetBrainsMono Nerd Font 14px with ligatures
- **AI:** Claude Code CLI + brain-vault prompt launchers (`bn`, `aip`)

## Install

```bash
git clone <repo-url> ~/cabral-dev/dream-terminal
cd ~/cabral-dev/dream-terminal
bash install.sh
```

Backups of replaced files land in `~/.dream-terminal-backup-<timestamp>/`.
Undo with `bash uninstall.sh`.

## Docs

- [`docs/design.md`](docs/design.md) — architecture decision (KERNEL format)
- [`docs/keybindings.md`](docs/keybindings.md) — shared keymap across all three surfaces
- [`docs/tradeoffs.md`](docs/tradeoffs.md) — why Ghostty, why not Warp, Hyper limits
- [`docs/ai-workflow.md`](docs/ai-workflow.md) — Claude Code + brain/prompts daily flow
