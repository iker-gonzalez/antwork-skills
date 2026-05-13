# Antwork Skills

[Agent Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) that help Claude work effectively with the [Antwork](https://antwork.io) MCP connector — an MCP-native social media scheduler for solo founders.

## Skills

| Skill | What it does |
|---|---|
| [`antwork-poster`](skills/antwork-poster/SKILL.md) | Drafts, schedules, and publishes social posts via Antwork. Pulls voice/brand context first, enforces the DRAFT → publish/schedule two-step, and optimizes per-platform copy. |

More skills (analytics, content planning, voice-profile maintenance) will land here over time.

## Using these skills

You need the [Antwork MCP connector](https://antwork.io) connected to Claude before any of these skills are useful — they call its tools.

### In Claude.ai

Skills submitted to the [Anthropic Skills Directory](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) surface automatically when you mention something the skill is designed for ("schedule a LinkedIn post", "draft a content batch for next week", etc.). No install step.

### In Claude Code

Drop a skill into your skills directory and Claude Code will load it on relevant prompts:

```sh
mkdir -p ~/.claude/skills
cp -r skills/antwork-poster ~/.claude/skills/
```

Or for a single project:

```sh
mkdir -p .claude/skills
cp -r skills/antwork-poster .claude/skills/
```

## Contributing

Each skill lives in `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`) followed by markdown instructions. Keep the `description:` specific — it's what determines when Claude auto-loads the skill.

## License

[MIT](LICENSE)
