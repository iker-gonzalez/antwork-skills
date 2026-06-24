---
name: antwork-audit
description: Use when the user wants a full audit, health check, or scorecard of their social-media presence managed through Antwork — engagement performance, voice consistency, posting cadence, content quality, and platform coverage. Trigger on "audit my socials", "how's my LinkedIn/X doing", "social health check", "review my Antwork account", "what should I fix", "grade my content".
---

# Antwork Social Presence Audit

A comprehensive, data-driven audit of everything the user ships through Antwork. It mirrors a 5-dimension marketing audit: five specialized agents run in parallel, each owning one dimension, then you synthesize a single scored report.

## 1. Establish scope first

Before spawning anything, gather the lay of the land so the agents (and the report) reference real accounts and real numbers:

- `whoami` — confirm the user and default workspace.
- `list_workspaces` — if more than one and no default, ask which to audit (or `set_default_workspace`).
- `list_social_accounts` — the connected platforms, handles, and token health. This is the audit's universe.
- `get_workspace_settings` — timezone, preferred posting times, brand identity.

If no accounts are connected, stop and route the user to `antwork-setup` instead — there's nothing to audit yet.

## 2. Spawn the five dimension agents in parallel

Launch all five in a single batch so they run concurrently. Each is read-only and returns a structured findings block with a 0–100 sub-score and its top 3 fixes. Pass each the workspace and the account list you gathered.

| Dimension | Agent | Weight | Primary MCP tools |
|---|---|---|---|
| Performance | `antwork-performance` | 30% | `get_performance`, `get_engagement_history`, `get_optimal_posting_times` |
| Voice Consistency | `antwork-voice-analyst` | 20% | `get_post_context` (per account), `list_posts` |
| Cadence & Timing | `antwork-cadence` | 20% | `list_posts`, `get_calendar`, `get_optimal_posting_times` |
| Content Quality | `antwork-content` | 20% | `fetch_platform_posts`, `get_post`, `list_posts` |
| Platform Coverage & Growth | `antwork-growth` | 10% | `list_social_accounts`, `get_workspace_settings` |

Do not analyze the dimensions inline yourself — the parallel agents are the point. If one agent fails or returns nothing, note the gap and score that dimension conservatively rather than blocking the report.

## 3. Compute the composite Social Health Score

Weighted sum of the five sub-scores (0–100):

```
Score = Performance·0.30 + Voice·0.20 + Cadence·0.20 + Content·0.20 + Growth·0.10
```

Band it: **80–100 Strong · 60–79 Healthy · 40–59 Needs work · 0–39 At risk.**

## 4. Write ANTWORK-AUDIT.md

Produce a client-ready Markdown file with:

- **Header** — workspace name, audited accounts (platform + handle), date, and the composite score with its band.
- **Executive summary** — 3–5 sentences: the single biggest strength, the single biggest leak, and the one move with the highest payoff.
- **Scorecard table** — each dimension, its sub-score, and a one-line verdict.
- **Per-dimension findings** — one section per agent, carrying through its findings and top-3 fixes verbatim-in-spirit (don't dilute the specifics).
- **Prioritized action plan** — a single merged, impact-ranked checklist drawn from all five agents' fixes. Each item: what to do, which Antwork skill/tool does it (`antwork-voice` to refresh a stale profile, `antwork-calendar` to fill cadence gaps, etc.), and expected payoff.

## 5. Close with the next move

End by offering to execute the top action immediately through the relevant skill — e.g. "Want me to refresh the stale X voice profile now?" (`antwork-voice`) or "Want me to fill next week's empty slots?" (`antwork-calendar`). The audit is only valuable if it turns into shipped posts.

## Guardrails

- The audit is **read-only**. Never create, edit, schedule, publish, or delete anything during an audit.
- `refresh_post_metrics` burns platform API quota — only suggest it; don't have agents call it during a routine audit unless the user explicitly wants live-refreshed numbers.
- Quote real numbers from the analytics rows. Never fabricate engagement figures or invent posts that aren't in the data.
