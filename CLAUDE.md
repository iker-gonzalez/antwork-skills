# antwork-skills — Claude Code plugin for Antwork

A skill library that routes `/antwork <command>` to specialized skills, each encoding the
correct sequence of Antwork MCP tool calls. Distributed as a Claude Code plugin (bundled
`.mcp.json` → `api.antwork.io/mcp`) or via `install.sh`.

This repo is **prompt content, not code**. There is no build, no dependencies, and no test
suite — correctness means the instructions are accurate about Antwork's MCP tools.

## Layout

- `skills/<name>/SKILL.md` — one directory per skill; `SKILL.md` is the skill.
- `agents/*.md` — the 5 read-only audit subagents used by `/antwork audit`.
- `templates/*.md` — output templates skills render into.
- `install.sh` / `uninstall.sh` — non-plugin install path.
- `README.md` — the command table. **It must stay in sync with `skills/`.**

## Changing a skill

Applies to every change, by hand or unattended.

- **Base branch is `main`** — this repo has no `dev` branch. Branch from `main`, PR to `main`.
- Nothing to build or test. Verification is by inspection; say so in the PR body rather
  than implying automated coverage.
- **Never invent MCP tool names, parameters, or response shapes.** Every tool referenced in
  a skill must exist in the Antwork MCP server. If the issue requires a tool you cannot
  verify against `../antwork.io/agent-service/app/mcp/server.py`, stop and say so rather than
  guessing — a plausible-looking wrong tool name is worse than no change. The server's tools
  change: on 2026-08-24 the stored voice profile went (`prepare_voice_analysis`,
  `save_voice_analysis`, `voiceStale`), and on 2026-10-03 eight tools were cut (antwork.io
  #1437). Both times these skills went on naming tools that no longer existed.
- Facts with a source of truth get checked against it, not memory: character limits live in
  `../antwork.io/src/lib/platforms/common/platform-rules.json`.
- `clawhub/antwork/SKILL.md` is a self-contained copy of the core rules for OpenClaw's
  registry. A change to a rule in `skills/` usually needs the same change there.
- Adding or renaming a skill means updating **both** `skills/<name>/SKILL.md` and the command
  table in `README.md`. A PR touching only one is incomplete.
- Never touch `install.sh`, `uninstall.sh`, or `.mcp.json` unless the issue explicitly asks.
