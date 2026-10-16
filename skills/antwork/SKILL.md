---
name: antwork
description: Router for the Antwork social-media toolkit. Use when the user wants a multi-step Antwork workflow through its MCP connector — posting about what they shipped from a git repo, a content calendar, repurposing one piece across platforms, a campaign or launch week, data-driven post ideas, reading an account's voice, an analytics report, or a full social-presence audit. Routes "/antwork <command>" to the right skill. Trigger on "/antwork", "use Antwork to…", or any request to plan, analyze or audit social posting through Antwork.
---

# Antwork — social-media command center

Antwork is an MCP-native social-media scheduler. Its MCP server already tells you how to do the single steps: draft a post, schedule or publish it, attach media, connect an account, retry a failed post. Those need no skill — follow the server's instructions and each tool's description.

These skills cover the **multi-step workflows** the server can't spell out on its own: plans that need approval before any draft, batches that must avoid the existing calendar, reports that turn rows into decisions. This skill is the router.

## Commands

| Command | Skill | What it does |
|---|---|---|
| `/antwork calendar <theme>` | `antwork-calendar` | Plan and batch-schedule a content calendar across the week/month. |
| `/antwork repurpose <source>` | `antwork-repurpose` | Turn one piece (blog, transcript, long post) into platform-native variants. |
| `/antwork campaign <goal>` | `antwork-campaign` | Sequence a multi-post campaign / launch week toward a goal. |
| `/antwork ideas [topic]` | `antwork-ideas` | Generate data-driven hooks grounded in what already performed. |
| `/antwork voice [account]` | `antwork-voice` | Read an account's voice from its real posts, or capture one from samples for an account with no history. |
| `/antwork analytics [range]` | `antwork-analytics` | Pull performance + engagement and synthesize a report. |
| `/antwork audit` | `antwork-audit` | Full social-presence audit across 5 dimensions + a 0-100 Social Health Score. |
| `/antwork ship [--since …] [--release <tag>]` | `antwork-ship` | Turn the current repo's recent commits, merged PRs or a release into build-in-public posts. |

Where these skills aren't installed one by one (the claude.ai package), each one's instructions are in `references/<skill-name>.md` next to this file: read that file and follow it as the skill.

If the user just describes intent ("plan next week", "how did last month do?"), route to the matching skill — they don't have to type the command.

## Handled directly, without a skill

- **One post** ("post this to LinkedIn", "schedule a tweet for Tuesday"): `get_post_context` for the account, then `create_post`, then `schedule_post` or `publish_post`. One idea on several accounts: `create_campaign`, then `schedule_campaign` or `publish_campaign`.
- **Setup and connections** ("connect my X", "my account is disconnected"): `get_connection_urls`. Timezone, posting times and brand identity: `update_workspace`.
- **Media**: `attach_media` for a file already in the library, `upload_media(image_url=...)` then `attach_media` for a public URL, `attach_chatgpt_file` for a file attached in ChatGPT, or `request_upload_url` → upload → `register_uploaded_media(..., attach_to_post_id=...)` when you can run code with the file. Otherwise give the user the post's `mediaUrl`, which opens it in the Antwork composer with the media picker open. Post results also carry `editUrl` (the post in the composer) and `settingsUrl` (its platform settings, e.g. the TikTok audience, which only the user can choose).
- **Engagement**: `retry_failed_post` once the failure's cause is fixed, `fetch_platform_posts` for what is live.

## Routing logic

1. **Resolve the verb.** Map the request to one command above, or to a direct step. When ambiguous, prefer the narrowest: a single post is a direct step, not `antwork-campaign`.
2. **Check prerequisites once.** Every workflow needs a workspace and a connected account. The `workspaceAccounts` field on any workspace-scoped result lists the accounts; if none are connected, call `get_connection_urls` first.
3. **Hand off — don't reimplement.** Each skill owns its tool sequence. Pass along the user's intent and what you already know (workspace, accounts).

## Ground truth every workflow must respect

- **Draft → publish/schedule is two steps.** `create_post` and `create_campaign` create **drafts**. Nothing is scheduled until `schedule_post` / `schedule_campaign` succeeds, and nothing is live until `publish_post` / `publish_campaign` does.
- **One account per post, its own copy per account.** Several accounts means `create_campaign` with one variant per account, each written for that account. Never one body across many accounts.
- **Voice comes from the account's own posts.** `get_post_context` returns them; there is no stored voice profile. Call it before writing copy for any account.
- **Hard limits.** Character limits are per platform (X 280 · Threads 500 · Pinterest 800 · Instagram 2,200 · TikTok 2,200 · LinkedIn 3,000 · YouTube 5,000 · Facebook 63,206). TikTok and YouTube need a video; Instagram and Pinterest need an image or video. Scheduling reaches at most 30 days ahead. Each account has a daily cap per rolling 24 hours (`get_post_context` returns it as `dailyPostCap`; past it, `daily_cap_reached`) and at most 100 scheduled posts waiting on the free plan, 1,000 paid (`schedule_queue_full`). On X and Threads, a repeat of a recent post (`duplicate_post`) or a post within 30 minutes of another on the same account (`posting_too_close`) is refused: spread a batch out instead of retrying.
- **Plan before batches.** Anything bigger than one post gets a numbered plan the user approves before the first draft.
- **Confirm destructive ops.** `delete_post`, `disconnect_social_account` and `delete_media` need the user's go-ahead first.
