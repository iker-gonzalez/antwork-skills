---
name: antwork-poster
description: Use when the user wants to draft, schedule, or publish a social media post through Antwork's MCP connector — single posts or a multi-platform fan-out. Handles voice-aware drafting, the draft→publish/schedule two-step, per-platform character limits, and account health. Trigger on phrases like "post to LinkedIn/X/Threads", "schedule a tweet", "publish this", "draft a post", or any explicit mention of posting through Antwork.
---

# Posting through Antwork

Antwork is an MCP-native social-media scheduler. This skill codifies the mistakes most assistants make against the server — get the tool sequence right and the post ships correctly the first time.

## 1. Resolve the workspace and account first

- `workspace_id` is optional on every tool. It auto-resolves when the user has one workspace. If they have several and no default, call `set_default_workspace` (or pass `workspace_id`) before anything else.
- `create_post` targets **one account** via `account_id`. Call `list_social_accounts` to get the target account's id and check its `tokenHealthStatus`. If the account is `expired` / `needs_reconnection`, stop and surface its `reauthUrl` — a post against a dead account will fail at publish time.

## 2. Pull context before drafting — never write cold

Call `get_post_context(platform, account_id)` before writing any copy. It returns:

- **Brand identity** — workspace name, website, logo, `brandVersion`.
- **Voice profile** for that account — tone, style, emoji/hashtag policy, CTA patterns, example phrases.
- **Recent posts** (the last 3) so you don't repeat yourself.
- **`voiceStale`** — if true (no profile, or older than 30 days), recommend a quick `antwork-voice` pass first, or ask the user once for tone ("formal, founder-mode, casual?") rather than guessing.

The voice profile and brand are the ground truth. Match them — pronouns ("I/my" for solo founders, "we/our" for teams), tone, and the account's recurring vocabulary.

## 3. The platform model: one account per post

There is **no** `platforms` or `platform_texts` argument. `create_post` writes to a single `account_id`, and the platform is derived from that account.

- **Single platform:** one `create_post`.
- **Multiple platforms:** one `create_post` per account, each with copy reshaped for that platform, all sharing the **same `campaign_id`** so they stay grouped. Don't reuse one body across platforms — X's 280-char cap mangles LinkedIn copy, and LinkedIn-length paragraphs look broken on Threads. Call `get_post_context` for each platform so each variant matches that account's voice.

## 4. Respect character limits

Per-platform hard limits, enforced by the server at schedule/publish time:

| Platform | Limit | Platform | Limit |
|---|---|---|---|
| X | 280 | Instagram | 2,200 |
| Threads | 500 | LinkedIn | 3,000 |
| Pinterest | 800 | TikTok | 4,000 |
| YouTube | 5,000 | Facebook | 63,206 |

Keep posts short by default; LinkedIn is the one place where longer (300–600 words) is fine. If copy is over limit, `schedule_post`/`publish_post` will refuse — trim before dispatching, don't let the call bounce.

## 5. DRAFT vs PUBLISH — the two-step trap

`create_post` creates a **DRAFT**. It does NOT publish or schedule on its own. (You can pass `scheduled_for` to `create_post`, but the reliable, legible pattern is two explicit steps.)

- **Schedule for later:** `create_post` → `schedule_post(post_id, scheduled_for)` with an ISO 8601 time. Use `get_optimal_posting_times` to land on the workspace's preferred windows + timezone.
- **Publish now:** `create_post` → `publish_post(post_id)`. It waits up to ~60s and returns live URLs per platform.

Always complete the second step when the user said "schedule" or "publish now." Telling the user "scheduled!" after only `create_post` is false.

## 6. Plan before drafting for multi-post asks

For anything bigger than a one-off — a batch, a launch week, several platforms — present a short **plan** first (hook + account/platform + when) as a numbered list and wait for approval before calling `create_post`. Editing a plan is cheaper than editing five drafts. For full campaigns, hand off to `antwork-campaign`; for calendars, `antwork-calendar`.

## 7. Voice — avoid the AI tells

Across every voice, avoid openers that read as AI: "Here's the thing:", "Let me break it down", "Buckle up", emoji-stuffed hooks. Pass `hashtags` as a list (no `#` prefix) and only when the account's voice profile uses them. Use `goal` to tag the post's intent when the user states one.

## 8. Surface results, name failures

`publish_post` returns per-platform success/failure plus live URL(s). Report them back — one line per account, with the link. On failure, name the platform and quote the error rather than "publish failed." If a post failed mid-publish, `retry_failed_post(post_id)` re-attempts it.

## 9. Don't invent fields

`create_post` accepts: `text`, `account_id`, `hashtags`, `goal`, `scheduled_for`, `campaign_id`, `user_tags`, `workspace_id`. Media is **not** a create-time field — attach it afterward with `attach_media` (see `antwork-media`). Don't pass `platforms`, `platform_texts`, `title`, `tags`, or `priority`; the server rejects unknown fields.
