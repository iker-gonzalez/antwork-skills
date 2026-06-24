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

You don't have to type the command — describe the intent ("schedule a LinkedIn post for Tuesday", "how did last month do?") and the [orchestrator](antwork/SKILL.md) routes to the right skill.

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

### Claude Code (one command)

```sh
curl -fsSL https://raw.githubusercontent.com/iker-gonzalez/antwork-skills/main/install.sh | bash
```

This clones the repo and copies the orchestrator + 11 skills into `~/.claude/skills/`, the 5 audit agents into `~/.claude/agents/`, and the templates alongside the orchestrator. Start a new Claude Code session to load them.

Prefer to clone first? Same result:

```sh
git clone https://github.com/iker-gonzalez/antwork-skills.git
cd antwork-skills
./install.sh
```

Remove everything with `./uninstall.sh` (or `curl -fsSL https://raw.githubusercontent.com/iker-gonzalez/antwork-skills/main/uninstall.sh | bash`).

To install into a single project instead of globally:

```sh
mkdir -p .claude/skills .claude/agents
cp -r antwork skills/antwork-* .claude/skills/
cp agents/antwork-*.md .claude/agents/
```

### Claude.ai

Skills submitted to the [Anthropic Skills Directory](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) surface automatically when you mention something they cover — no install step.

## Repository layout

```
antwork-skills/
├── antwork/SKILL.md          # orchestrator — routes /antwork <command>
├── skills/                   # 11 specialized skills
│   ├── antwork-setup/        ├── antwork-campaign/
│   ├── antwork-voice/        ├── antwork-ideas/
│   ├── antwork-poster/       ├── antwork-analytics/
│   ├── antwork-calendar/     ├── antwork-engage/
│   ├── antwork-repurpose/    ├── antwork-media/
│   └── antwork-audit/
├── agents/                   # 5 parallel audit subagents
├── templates/                # voice profile, calendar, campaign brief, launch week, report
├── install.sh / uninstall.sh
└── README.md / LICENSE
```

## Contributing

Each skill lives in `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`) followed by markdown instructions. Keep `description:` specific — it determines when Claude auto-loads the skill. Use only [real Antwork MCP tools](https://antwork.io) and never invent tool arguments; the server rejects unknown fields.

## License

[MIT](LICENSE)
