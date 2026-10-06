# Antwork: post to LinkedIn, X, Instagram and more from your AI

**AI assistants have no built-in connector for posting to social media.** To let your assistant draft, schedule and publish posts, you connect it to an MCP server that holds the platform permissions. [Antwork](https://antwork.io?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills) is that server: connect `https://api.antwork.io/mcp` once, sign in with OAuth, and your assistant can post to your connected accounts on **LinkedIn (personal profile or company page), X, Instagram, Facebook Pages, Threads, TikTok, YouTube and Pinterest**. Posts stay drafts until you ask it to schedule or publish them.

It works in VS Code (GitHub Copilot chat), Claude, ChatGPT, Cursor and any other client that speaks MCP. Two social accounts are free, then $5 a month each ([pricing](https://antwork.io/pricing?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills)).

## Connect

| | |
|---|---|
| Server URL | `https://api.antwork.io/mcp` |
| Server name | `antwork` |
| Transport | Streamable HTTP |
| Auth | OAuth 2.1 with dynamic client registration. No API key to create or store. |

The first tool call opens a consent screen in your browser. After that, ask your assistant to connect a social account and it returns a connect link for each platform.

### VS Code

Install **Antwork** from the MCP servers gallery, or [add it in one click](https://antwork.io/automate/vscode?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills). MCP servers in VS Code run through GitHub Copilot, so the Copilot extension must be installed and signed in. To add it by hand, put this in `.vscode/mcp.json`:

```json
{
  "servers": {
    "antwork": {
      "type": "http",
      "url": "https://api.antwork.io/mcp"
    }
  }
}
```

### Other clients

- **Claude.ai or Claude Desktop:** add `https://api.antwork.io/mcp` as a custom connector. [Step-by-step](https://antwork.io/automate/claude-desktop/linkedin?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills). For the calendar, campaign, analytics and audit workflows, add the [claude.ai skill](#claudeai) too.
- **Claude Code:** install the plugin below, which connects the server and adds the skills in one step.
- **ChatGPT:** [setup guide](https://antwork.io/automate/chatgpt?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills).
- **Cursor:** [setup guide](https://antwork.io/automate/cursor?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills).
- **Anything else:** point it at the server URL above. [Full MCP docs](https://antwork.io/docs/mcp?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills).

### What your assistant can do

- Draft a post in each account's own voice. It reads that account's recent posts first.
- Schedule or publish, per account or as a campaign across several accounts.
- Attach images, video and PDFs, and manage the media library.
- See the calendar, list and search posts, and retry a failed one.
- Report engagement: impressions or views, likes, comments, shares and reach, per post and per account.

Each platform's own rules apply: Instagram and Pinterest need an image or video, TikTok and YouTube need a video, and Instagram needs a Creator or Business account. [Tool reference](https://antwork.io/docs/mcp/tools?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills).

## Antwork Skills for Claude Code and claude.ai

This repo also adds [Agent Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) on top of the connector. The connector alone handles single steps: drafting, scheduling, publishing, media, connections. The skills cover the multi-step workflows: a content calendar planned around what's already scheduled, one piece repurposed across platforms, a campaign arc, ideas grounded in what performed, an analytics report, and a scored audit. One router sends `/antwork <command>` (or a plain request) to the right one.

### Commands

| Command | Skill | What it does |
|---|---|---|
| `/antwork voice [account]` | [`antwork-voice`](skills/antwork-voice/SKILL.md) | Read an account's voice from its real posts, or capture one from samples. |
| `/antwork calendar <theme>` | [`antwork-calendar`](skills/antwork-calendar/SKILL.md) | Plan and batch-schedule a content calendar. |
| `/antwork repurpose <source>` | [`antwork-repurpose`](skills/antwork-repurpose/SKILL.md) | One piece → platform-native variants, grouped as a campaign. |
| `/antwork campaign <goal>` | [`antwork-campaign`](skills/antwork-campaign/SKILL.md) | Sequence a multi-post campaign / launch week. |
| `/antwork ideas [topic]` | [`antwork-ideas`](skills/antwork-ideas/SKILL.md) | Data-driven hooks grounded in what already performed. |
| `/antwork analytics [range]` | [`antwork-analytics`](skills/antwork-analytics/SKILL.md) | Pull performance + engagement and synthesize a report. |
| `/antwork audit` | [`antwork-audit`](skills/antwork-audit/SKILL.md) | Full social-presence audit with 5 parallel agents + a 0-100 Social Health Score. |

You don't have to type the command — describe the intent ("plan next week", "how did last month do?") and the [router](skills/antwork/SKILL.md) picks the skill. A single post, connecting an account, media and LinkedIn comments need no skill: the connector's own instructions cover them.

### The audit's parallel agents

In Claude Code, `/antwork audit` spawns five read-only subagents concurrently, then synthesizes a weighted score. On claude.ai, which has no subagents, the same five dimensions run one after another:

| Agent | Dimension | Weight |
|---|---|---|
| [`antwork-performance`](agents/antwork-performance.md) | Engagement & top/bottom posts | 30% |
| [`antwork-voice-analyst`](agents/antwork-voice-analyst.md) | Voice consistency across accounts | 20% |
| [`antwork-cadence`](agents/antwork-cadence.md) | Posting cadence & timing | 20% |
| [`antwork-content`](agents/antwork-content.md) | Content quality (hooks, CTAs, fit) | 20% |
| [`antwork-growth`](agents/antwork-growth.md) | Platform coverage & growth | 10% |

### Prerequisite

The skills call the Antwork MCP server, so it has to be connected (see [Connect](#connect)). The plugin does that for you. A single OAuth token spans all your workspaces.

Once connected, a good first run is **audit** (where you stand), then **ideas** or **calendar** (what to post next).

### Install the skills

#### Claude Code plugin (recommended)

This repo is also a Claude Code **plugin marketplace**. Installing the plugin wires up the Antwork MCP server *and* all skills + agents in one step:

```sh
/plugin marketplace add iker-gonzalez/antwork-skills
/plugin install antwork-skills@antwork
```

That's it — the [`antwork` MCP server](.mcp.json) connects automatically (complete the OAuth prompt), and the router, 7 skills, and 5 audit agents load. Why the plugin over loose skills: the skills are useless until Antwork's MCP is connected, and the plugin ships that config bundled, so there's no separate connector setup.

#### Script install (no plugin)

If you'd rather not use the plugin system, the script copies the skills + agents straight into `~/.claude/` (you still connect the [Antwork MCP](https://antwork.io?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills) yourself):

```sh
curl -fsSL https://raw.githubusercontent.com/iker-gonzalez/antwork-skills/main/install.sh | bash
```

Prefer to clone first? `git clone … && cd antwork-skills && ./install.sh`. Remove everything with `./uninstall.sh`.

#### OpenClaw / ClawHub

`clawhub/antwork/` is a **self-contained** skill published to [ClawHub](https://clawhub.ai), OpenClaw's skill registry:

```sh
clawhub install iker-gonzalez/antwork
mcporter config add antwork --url https://api.antwork.io/mcp --auth oauth
```

It is deliberately not the router above. ClawHub publishes one folder, so a skill that routes to 7 siblings that were never installed would be broken — this one inlines the setup, the drafting protocol, the character limits and the draft→publish two-step in a single file.

#### claude.ai

Plugins are Claude Code only, so claude.ai gets the same skills as one upload:

1. Download [`antwork-claude-ai-skill.zip`](https://github.com/iker-gonzalez/antwork-skills/releases/download/claude-ai-skill/antwork-claude-ai-skill.zip).
2. In claude.ai, open Settings, find Skills, and upload the ZIP.
3. Connect the Antwork connector (see [Connect](#connect)) if you haven't.

It is one skill named `antwork`: the router, with every other skill and audit dimension inside it as a reference file it reads when needed. [`claude-ai/build.sh`](claude-ai/build.sh) generates it from `skills/`, `agents/` and `templates/`, and a workflow republishes it on every change, so it never drifts from the plugin. Posting itself needs no skill on claude.ai either: the connector sends its drafting rules when it connects.

## Repository layout

```
antwork-skills/
├── .claude-plugin/
│   ├── plugin.json           # plugin manifest
│   └── marketplace.json      # self-hosted marketplace (lists this plugin)
├── .mcp.json                 # Antwork MCP server — bundled & auto-connected
├── skills/                   # router + 7 specialized skills
│   ├── antwork/              # router — /antwork <command>
│   ├── antwork-calendar/     ├── antwork-campaign/
│   ├── antwork-repurpose/    ├── antwork-ideas/
│   ├── antwork-voice/        ├── antwork-analytics/
│   └── antwork-audit/
├── agents/                   # 5 parallel audit subagents (auto-discovered)
├── templates/                # voice read, calendar, campaign brief, launch week, report
├── claude-ai/build.sh        # builds the claude.ai ZIP from skills/, agents/, templates/
├── clawhub/                  # self-contained skill published to ClawHub
├── install.sh / uninstall.sh # script-install fallback
└── README.md / LICENSE
```

## Contributing

Each skill lives in `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`) followed by markdown instructions. Keep `description:` specific — it determines when Claude auto-loads the skill. Use only [real Antwork MCP tools](https://antwork.io?utm_source=github&utm_medium=readme&utm_campaign=antwork_skills) and never invent tool arguments; the server rejects unknown fields.

## License

[MIT](LICENSE)
