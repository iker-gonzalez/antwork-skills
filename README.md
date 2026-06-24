# Antwork Skills

A toolkit of [Agent Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) that turn Claude into a social-media command center on top of the [Antwork](https://antwork.io) MCP connector — an MCP-native social scheduler for solo founders and small teams.

One orchestrator routes `/antwork <command>` to specialized skills, each of which codifies the right sequence of Antwork's 43 MCP tools so the workflow runs correctly the first time — voice-aware drafting, the draft→publish/schedule two-step, per-platform character limits, campaign grouping, analytics, and a full audit.

## Commands

| Command | Skill | What it does |
|---|---|---|
| `/antwork setup` | [`antwork-setup`](skills/antwork-setup/SKILL.md) | Connect accounts, set workspace timezone + posting times, brand identity. **Run first.** |
| `/antwork voice [account]` | [`antwork-voice`](skills/antwork-voice/SKILL.md) | Build/refresh a per-account voice profile from real posts. |
| `/antwork post <idea>` | [`antwork-poster`](skills/antwork-poster/SKILL.md) | Draft → schedule/publish a post (single account or multi-platform fan-out). |
| `/antwork calendar <theme>` | [`antwork-calendar`](skills/antwork-calendar/SKILL.md) | Plan and batch-schedule a content calendar. |
| `/antwork repurpose <source>` | [`antwork-repurpose`](skills/antwork-repurpose/SKILL.md) | One piece → platform-native variants, grouped as a campaign. |
| `/antwork campaign <goal>` | [`antwork-campaign`](skills/antwork-campaign/SKILL.md) | Sequence a multi-post campaign / launch week. |
| `/antwork ideas [topic]` | [`antwork-ideas`](skills/antwork-ideas/SKILL.md) | Data-driven hooks grounded in what already performed. |
| `/antwork analytics [range]` | [`antwork-analytics`](skills/antwork-analytics/SKILL.md) | Pull performance + engagement and synthesize a report. |
| `/antwork engage` | [`antwork-engage`](skills/antwork-engage/SKILL.md) | Comment/reply (LinkedIn), retry failed posts, community work. |
| `/antwork media` | [`antwork-media`](skills/antwork-media/SKILL.md) | Upload, attach, and manage post media. |
| `/antwork audit` | [`antwork-audit`](skills/antwork-audit/SKILL.md) | Full social-presence audit with 5 parallel agents + a 0-100 Social Health Score. |

You don't have to type the command — describe the intent ("schedule a LinkedIn post for Tuesday", "how did last month do?") and the [orchestrator](skills/antwork/SKILL.md) routes to the right skill.

## The audit's parallel agents

`/antwork audit` spawns five read-only subagents concurrently, then synthesizes a weighted score:

| Agent | Dimension | Weight |
|---|---|---|
| [`antwork-performance`](agents/antwork-performance.md) | Engagement & top/bottom posts | 30% |
| [`antwork-voice-analyst`](agents/antwork-voice-analyst.md) | Voice consistency across accounts | 20% |
| [`antwork-cadence`](agents/antwork-cadence.md) | Posting cadence & timing | 20% |
| [`antwork-content`](agents/antwork-content.md) | Content quality (hooks, CTAs, fit) | 20% |
| [`antwork-growth`](agents/antwork-growth.md) | Platform coverage & growth | 10% |

## Prerequisite — connect Antwork

These skills call the Antwork MCP server, so you need it connected to Claude first. See [antwork.io](https://antwork.io). A single OAuth token spans all your workspaces.

Once connected, the highest-value path for a new user is: **setup → voice → ideas/calendar → post → analytics → audit**.

## Install

### Claude Code plugin (recommended)

This repo is also a Claude Code **plugin marketplace**. Installing the plugin wires up the Antwork MCP server *and* all skills + agents in one step:

```sh
/plugin marketplace add iker-gonzalez/antwork-skills
/plugin install antwork-skills@antwork
```

That's it — the [`antwork` MCP server](.mcp.json) connects automatically (complete the OAuth prompt), and the orchestrator, 11 skills, and 5 audit agents load. Why the plugin over loose skills: the skills are useless until Antwork's MCP is connected, and the plugin ships that config bundled, so there's no separate connector setup.

### Script install (no plugin)

If you'd rather not use the plugin system, the script copies the skills + agents straight into `~/.claude/` (you still connect the [Antwork MCP](https://antwork.io) yourself):

```sh
curl -fsSL https://raw.githubusercontent.com/iker-gonzalez/antwork-skills/main/install.sh | bash
```

Prefer to clone first? `git clone … && cd antwork-skills && ./install.sh`. Remove everything with `./uninstall.sh`.

### Claude.ai

Skills submitted to the [Anthropic Skills Directory](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) surface automatically when you mention something they cover — no install step. (Plugins are Claude-Code-only; the skills are the cross-surface format.)

## Repository layout

```
antwork-skills/
├── .claude-plugin/
│   ├── plugin.json           # plugin manifest
│   └── marketplace.json      # self-hosted marketplace (lists this plugin)
├── .mcp.json                 # Antwork MCP server — bundled & auto-connected
├── skills/                   # orchestrator + 11 specialized skills
│   ├── antwork/              # orchestrator — routes /antwork <command>
│   ├── antwork-setup/        ├── antwork-campaign/
│   ├── antwork-voice/        ├── antwork-ideas/
│   ├── antwork-poster/       ├── antwork-analytics/
│   ├── antwork-calendar/     ├── antwork-engage/
│   ├── antwork-repurpose/    ├── antwork-media/
│   └── antwork-audit/
├── agents/                   # 5 parallel audit subagents (auto-discovered)
├── templates/                # voice profile, calendar, campaign brief, launch week, report
├── install.sh / uninstall.sh # script-install fallback
└── README.md / LICENSE
```

## Contributing

Each skill lives in `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`) followed by markdown instructions. Keep `description:` specific — it determines when Claude auto-loads the skill. Use only [real Antwork MCP tools](https://antwork.io) and never invent tool arguments; the server rejects unknown fields.

## License

[MIT](LICENSE)
