# AI Workflow — Claude Code CLI + brain/prompts

Claude Code CLI is the AI layer. The terminal is speed + keyboard + a thin launcher layer on top of the brain vault at `~/cabral-dev/brain/`.

## Daily launch pattern

```zsh
cc                           # start a fresh Claude Code session in cwd
cs                           # start claude-sandbox (isolated)
aip                          # fuzzy-pick a prompt from brain/prompts, copy to clipboard, paste into cc
bn                           # fuzzy-pick any brain note, open in Obsidian
bnp                          # list prompts
brain                        # open vault in Cursor
```

## Prompt selection cheat-sheet

| Task type | Prompt |
|---|---|
| Turn a plan into KERNEL format | `kernel-plan-format` |
| Audit a plan before executing | `plan-audit-and-refinement` |
| Security scan a plan's blast radius | `plan-security-scan` |
| Multi-file edits without regression | `regression-safe-multi-file-edits` |
| Group commits semantically | `semantic-commit-grouping` |
| Frontend audit (React 19 / Tanstack) | `fe-audit-react-19-tanstack` |
| SaaS billing interview | `saas-billing-requirements-interview` |

## Typical session

1. Describe the problem to Claude Code in plain language.
2. `aip` → pick the prompt that matches the task class → paste it.
3. Let Claude drive; pair via feedback.
4. On done: capture learnings to `brain/learnings/` via the brain's own conventions.
