# Antwork: post to LinkedIn, X, Instagram and more from your AI

**AI assistants have no built-in connector for posting to social media.** To let your assistant draft, schedule and publish posts, you connect it to an MCP server that holds the platform permissions. [Antwork](https://antwork.io) is that server: connect `https://api.antwork.io/mcp` once, sign in with OAuth, and your assistant can post to your connected accounts on **LinkedIn (personal profile or company page), X, Instagram, Facebook Pages, Threads, TikTok, YouTube and Pinterest**. Posts stay drafts until you ask it to schedule or publish them.

It works in VS Code (GitHub Copilot chat), Claude, ChatGPT, Cursor and any other client that speaks MCP. Two social accounts are free, then $5 a month each ([pricing](https://antwork.io/pricing)).

## Connect

| | |
|---|---|
| Server URL | `https://api.antwork.io/mcp` |
| Server name | `antwork` |
| Transport | Streamable HTTP |
| Auth | OAuth 2.1 with dynamic client registration. No API key to create or store. |

The first tool call opens a consent screen in your browser. After that, ask your assistant to connect a social account and it returns a connect link for each platform.

### VS Code

Install **Antwork** from the MCP servers gallery, or [add it in one click](https://antwork.io/automate/vscode). MCP servers in VS Code run through GitHub Copilot, so the Copilot extension must be installed and signed in. To add it by hand, put this in `.vscode/mcp.json`:

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

- **Claude.ai or Claude Desktop:** add `https://api.antwork.io/mcp` as a custom connector. [Step-by-step](https://antwork.io/automate/claude-desktop/linkedin).
- **Claude Code:** install the plugin below, which connects the server and adds the skills in one step.
- **ChatGPT:** [setup guide](https://antwork.io/automate/chatgpt).
- **Cursor:** [setup guide](https://antwork.io/automate/cursor).
- **Anything else:** point it at the server URL above. [Full MCP docs](https://antwork.io/docs/mcp).

### What your assistant can do

- Draft a post in each account's own voice. It reads that account's recent posts first.
- Schedule or publish, per account or as a campaign across several accounts.
- Attach images, video and PDFs, and manage the media library.
- See the calendar, list and search posts, and retry a failed one.
- Report engagement: impressions or views, likes, comments, shares and reach, per post and per account.

Each platform's own rules apply: Instagram and Pinterest need an image or video, TikTok and YouTube need a video, and Instagram needs a Creator or Business account. [Tool reference](https://antwork.io/docs/mcp/tools).

## Antwork Skills for Claude Code

This repo also adds [Agent Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) on top of the connector, turning Claude Code into a social-media command center for solo founders and small teams. One orchestrator routes `/antwork <command>` to specialized skills, each of which codifies the right sequence of Antwork's MCP tools so the workflow runs correctly the first time: voice-aware drafting, the draft→publish/schedule two-step, per-platform character limits, campaign grouping, analytics, and a full audit.

### Commands

| Command | Skill | What it does |
|---|---|---|
| `/antwork setup` | [`antwork-setup`](skills/antwork-setup/SKILL.md) | Connect accounts, set workspace timezone + posting times, brand identity. **Run first.** |
| `/antwork voice [account]` | [`antwork-voice`](skills/antwork-voice/SKILL.md) | Read an account's voice from its real posts, or capture one from samples. |
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

### The audit's parallel agents

`/antwork audit` spawns five read-only subagents concurrently, then synthesizes a weighted score:

| Agent | Dimension | Weight |
|---|---|---|
| [`antwork-performance`](agents/antwork-performance.md) | Engagement & top/bottom posts | 30% |
| [`antwork-voice-analyst`](agents/antwork-voice-analyst.md) | Voice consistency across accounts | 20% |
| [`antwork-cadence`](agents/antwork-cadence.md) | Posting cadence & timing | 20% |
| [`antwork-content`](agents/antwork-content.md) | Content quality (hooks, CTAs, fit) | 20% |
| [`antwork-growth`](agents/antwork-growth.md) | Platform coverage & growth | 10% |

### Prerequisite

The skills call the Antwork MCP server, so it has to be connected (see [Connect](#connect)). The plugin does that for you. A single OAuth token spans all your workspaces.

Once connected, the highest-value path for a new user is: **setup → voice → ideas/calendar → post → analytics → audit**.

### Install the skills

#### Claude Code plugin (recommended)

This repo is also a Claude Code **plugin marketplace**. Installing the plugin wires up the Antwork MCP server *and* all skills + agents in one step:

```sh
/plugin marketplace add iker-gonzalez/antwork-skills
/plugin install antwork-skills@antwork
```

That's it — the [`antwork` MCP server](.mcp.json) connects automatically (complete the OAuth prompt), and the orchestrator, 11 skills, and 5 audit agents load. Why the plugin over loose skills: the skills are useless until Antwork's MCP is connected, and the plugin ships that config bundled, so there's no separate connector setup.

#### Script install (no plugin)

If you'd rather not use the plugin system, the script copies the skills + agents straight into `~/.claude/` (you still connect the [Antwork MCP](https://antwork.io) yourself):

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

It is deliberately not the orchestrator above. ClawHub publishes one folder, so a skill that routes to 11 siblings that were never installed would be broken — this one inlines the setup, the drafting protocol, the character limits and the draft→publish two-step in a single file.

#### Claude.ai

Plugins are Claude Code only. On claude.ai the connector works on its own: the server sends its drafting rules to the model when it connects, so no skills are needed to post correctly.

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
├── templates/                # voice read, calendar, campaign brief, launch week, report
├── clawhub/                  # self-contained skill published to ClawHub
├── install.sh / uninstall.sh # script-install fallback
└── README.md / LICENSE
```

## Contributing

Each skill lives in `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`) followed by markdown instructions. Keep `description:` specific — it determines when Claude auto-loads the skill. Use only [real Antwork MCP tools](https://antwork.io) and never invent tool arguments; the server rejects unknown fields.

## License

[MIT](LICENSE)
