---
name: antwork
description: Main orchestrator for the Antwork social-media toolkit. Use when the user wants to run any Antwork workflow through its MCP connector — drafting, scheduling, publishing, content calendars, repurposing, campaigns, voice profiles, analytics, ideation, engagement, media, account setup, or a full social-presence audit. Routes "/antwork <command>" to the right specialized skill. Trigger on "/antwork", "use Antwork to…", or any request to manage social posting through Antwork.
---

# Antwork — social-media command center

Antwork is an MCP-native social-media scheduler for solo founders and small teams. This skill is the **router**: it maps a user request (or an explicit `/antwork <command>`) to the specialized skill that does the work. Each specialized skill codifies the gotchas of the Antwork MCP server so the workflow runs correctly the first time.

## Commands

| Command | Skill | What it does |
|---|---|---|
| `/antwork setup` | `antwork-setup` | Connect accounts, set workspace timezone + posting times, brand identity. Run this first. |
| `/antwork voice [account]` | `antwork-voice` | Build or refresh a per-account voice profile from real posts. |
| `/antwork post <idea>` | `antwork-poster` | Draft → schedule/publish a single post (one account, or fan out via a shared campaign). |
| `/antwork calendar <theme>` | `antwork-calendar` | Plan and batch-schedule a content calendar across the week/month. |
| `/antwork repurpose <source>` | `antwork-repurpose` | Turn one piece (blog, transcript, long post) into platform-native variants. |
| `/antwork campaign <goal>` | `antwork-campaign` | Sequence a multi-post campaign / launch week toward a goal. |
| `/antwork ideas [topic]` | `antwork-ideas` | Generate data-driven hooks grounded in what already performed. |
| `/antwork analytics [range]` | `antwork-analytics` | Pull performance + engagement and synthesize a report. |
| `/antwork engage` | `antwork-engage` | Comment/reply (LinkedIn), retry failed posts, community work. |
| `/antwork media` | `antwork-media` | Upload, attach, and manage post media. |
| `/antwork audit` | `antwork-audit` | Full social-presence audit with 5 parallel agents + a 0-100 Social Health Score. |

If the user just describes intent in natural language ("schedule a LinkedIn post for Tuesday", "how did last month do?"), route to the matching skill — they don't have to type the command.

## Routing logic

1. **Resolve the verb.** Map the request to one command above. When ambiguous, prefer the narrowest skill (a single post → `antwork-poster`, not `antwork-campaign`).
2. **Check prerequisites once.** Most workflows need a workspace, a connected account, and ideally a voice profile. If `list_social_accounts` shows nothing connected, route to `antwork-setup` first. If `get_post_context` reports `voiceStale`, suggest `antwork-voice` before drafting at volume.
3. **Hand off — don't reimplement.** Each specialized skill owns its tool sequence. This orchestrator only picks the lane and passes along the user's intent and any context already gathered (which workspace, which account).

## Ground truth every Antwork workflow must respect

These hold across all skills — the specialized skills repeat the ones they depend on, but keep them in mind when routing:

- **Workspace resolution.** `workspace_id` is optional on every tool — it auto-resolves when the user has exactly one workspace. With multiple and no default, call `set_default_workspace` first (or pass `workspace_id` explicitly).
- **One account per post.** `create_post` targets a **single** `account_id`; the platform is derived from that account. There is **no** `platforms` or `platform_texts` array. To hit multiple platforms, make multiple `create_post` calls and group them with a shared `campaign_id`.
- **Draft → publish/schedule is two steps.** `create_post` creates a **draft**. Then `publish_post(post_id)` to go live now, or `schedule_post(post_id, scheduled_for)` (ISO 8601) for later. Saying "scheduled!" after only `create_post` is a lie.
- **Pull context before drafting.** `get_post_context(platform, account_id)` returns brand identity, the account's voice profile, recent posts, and a `voiceStale` flag — call it before writing copy.
- **Character limits are enforced.** X 280 · Threads 500 · Pinterest 800 · Instagram 2200 · LinkedIn 3000 · TikTok 4000 · YouTube 5000 · Facebook 63206. `schedule_post`/`publish_post` refuse to dispatch over-limit text.
- **Analytics is tabular.** `get_performance`, `get_engagement_history`, `get_post_history` return BigQuery-style `{schema, rows, rowCount}` — you render the charts/tables. `refresh_post_metrics` hits live platform APIs (≤25 posts) and burns quota; use it sparingly.
- **Confirm destructive ops.** `delete_post`, `disconnect_social_account`, and `delete_media` are destructive — confirm with the user first and report exactly what was removed.

## Suggested first-run path

For a new user, the highest-value order is: `setup` → `voice` → `ideas`/`calendar` → `post` → (later) `analytics` → `audit`. If someone jumps straight to `post` with nothing connected, route them through `setup` first, then come back.
