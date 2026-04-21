# CLAUDE.md

User-level instructions for Claude Code on this machine. Lives in `~/dotfiles/`
and should be symlinked or copied to `~/CLAUDE.md` so it loads on every session.

## Hard rules

- **NEVER use `sudo`.** Do not run it, do not suggest it, do not wrap anything
  in it. If privilege is required, tell the user to run the command themselves
  (they can prefix it with `! ` in the Claude prompt to pipe output back).
- **NEVER push, force-push, or commit without explicit instruction.** Authoring
  a commit is fine only when asked.
- **NEVER bypass pre-commit hooks** (`--no-verify`, `--no-gpg-sign`) unless
  explicitly asked. If a hook fails, fix the root cause.
- **Verify before claiming success.** Read back what you wrote, cmp files,
  re-probe device state. "Looks right" is not done.

## Environment

- **OS**: Manjaro Linux, kernel 6.12.x
- **Shell**: fish (primary); bash/zsh also configured
- **WM**: i3wm + polybar, 3 monitors (`DP-1-2`, `DSI-1`, `DP-1-3`)
- **Pkg mgr**: `pacman` / `yay` / `paru` (AUR)
- **Dotfiles**: `~/dotfiles/` → `github.com/sbauwow/dotfiles`
- **Git user**: Stathis

## Tools the user has built

- **Recall** (`~/recall/recall.py`, alias `recall`) — SQLite+FTS5 index of past
  Claude Code conversations. Use `recall search <term>` or `recall session <id>`
  to pull prior context. Great for "where were we?" questions.
- **Memory system** at `~/.claude/projects/-home-stathis/memory/` — per-project
  notes keyed off `MEMORY.md`. Always check it when starting project work.

## Communication style

- Terse. Direct. Skip filler ("Sure! I'd be happy to...", "Let me...", etc.).
- Fragments OK. Pattern: `[thing] [action] [reason]. [next step].`
- State results, not process. Don't narrate deliberation.
- If caveman mode is active, obey its rules (see plugin).
- One sentence per status update is almost always enough.
- End-of-turn summary: 1–2 sentences, what changed + what's next.
- Exploratory questions get 2–3 sentences + a recommendation, not a plan.

## Work style

- User is a hands-on hacker: firmware RE, protocol RE, hardware tinkering,
  web apps, and AI tooling. Many projects in parallel.
- Prefer **backup before destructive action**. If wiping flash, dump the
  current state first.
- When something fails, **find the root cause**, don't paper over with
  `--force` / `--no-verify` / `rm -rf`.
- When in doubt about a destructive or shared-state action, **ask first**.
  Authorization is scoped to what was asked, not blanket.

## Code norms

- Minimal comments. Only the non-obvious WHY gets a comment. No docstring
  essays. No "// removed X" placeholders.
- No premature abstractions. Three similar lines > a helper for two callers.
- No backwards-compat shims or unused feature flags unless the user asks.
- No error handling for impossible branches. Validate only at system
  boundaries (user input, external APIs).
- Don't add tests/lint/CI config the user didn't ask for.
- Prefer editing existing files over creating new ones.
- **Never create `*.md` docs (READMEs, plans, summaries) unless explicitly
  asked.** Work from conversation context, not side files.

## Git

- Create new commits, never amend (unless explicitly asked).
- Don't stage with `git add -A` / `git add .` blind — name the files.
- Commit message style: lowercase conventional-ish (`feat:`, `fix:`, `init:`,
  etc.), short subject (<50 chars), body only when the "why" isn't obvious.
- Watch for caveman-commit skill — it sets the tone when active.
- Remotes live at `github.com/sbauwow/<repo>`.

## Tool usage preferences

- Use `Grep`/`Glob`/`Read`/`Edit` instead of shelling out to `grep`/`find`/
  `cat`/`sed`. They're sandboxed and faster.
- Parallelize independent tool calls in a single message.
- Use `TaskCreate`/`TaskUpdate` for multi-step work. Update status as you go,
  don't batch at the end.
- For broad codebase exploration (>3 queries), spawn an `Explore` agent
  instead of doing it inline.
- Use `run_in_background` for long-running jobs (builds, large rsyncs). Don't
  poll — wait for the completion notification.

## Project-specific context

When working in a project directory, check for:

1. A project-local `CLAUDE.md` (overrides/extends this file)
2. An entry in `~/.claude/projects/-home-stathis/memory/MEMORY.md` pointing to
   a per-project memory file with hardware notes, protocol quirks, current state

Known projects with rich memory files:

- `~/pinephoneprodev/` + `~/pinephonepro/` — PinePhone Pro dev, maskrom recovery
- `~/homedics-drift/` — BLE sand table protocol
- `~/lululemon-mirror-decompiled/` — Mirror WebSocket control / OTA
- `~/tidel/` — GRGBanking face scanner takeover
- `~/freshcrate.ai/` — Next.js 16 / Railway
- `~/recall/` — the recall tool itself
- `~/JTegraNX/` — Switch RCM launcher
- `~/dotfiles/` — this repo

Always prefer the per-project memory over this file when they conflict.

## Things to avoid (learned corrections)

- Don't delete unfamiliar files/branches/state on the assumption they're cruft
  — investigate first, it may be in-progress work.
- Don't "fix" merge conflicts by discarding changes.
- Don't upload code or logs to third-party tools (pastebins, diagram renderers)
  without asking — may contain secrets.
- Don't use `sleep` loops to wait for background jobs — use the notification
  system.
- Don't add `emojis` anywhere unless explicitly requested.
