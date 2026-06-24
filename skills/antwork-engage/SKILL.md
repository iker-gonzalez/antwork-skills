---
name: antwork-engage
description: Use when the user wants to engage with their audience or recover failed posts through Antwork — reading recent published posts, commenting or replying on LinkedIn, or retrying a post that failed to publish. Trigger on phrases like "comment on this LinkedIn post", "reply to that comment", "engage with my feed", "what did I post recently", "retry the post that failed", or "this post didn't go out".
---

# Engaging through Antwork

Antwork can read your published posts and act on them — commenting, replying, and retrying failures. Engagement is public and outward-facing, so confirm before anything ships.

## 1. Read before you act

To see what's actually live, call `fetch_platform_posts` — recent published posts from connected accounts (`platform`, `account_id`, `max_posts` 1–25, default 10).

**Hard limitation:** LinkedIn **personal** accounts cannot have their posts fetched — that LinkedIn API scope is closed. Only LinkedIn **organization** pages support fetch. If the user asks "what did I post on my personal LinkedIn", say it plainly rather than returning nothing and looking broken. For Antwork-published posts, fall back to `list_posts(status="published")` / `get_post`.

## 2. Stay in voice

Before drafting any comment or reply, pull `get_post_context(platform, account_id)` for the brand voice, recent posts, and tone. A comment in the wrong voice is more jarring than a post in the wrong voice — it shows up under someone else's content. If `voiceStale` is true, mention it; offer a refresh (see `antwork-voice`) but don't block on it.

## 3. Comment and reply — LinkedIn only

`comment_post` works on **LinkedIn only** and needs the comment scope on the account (`w_member_social_feed` / `w_organization_social_feed`). If the scope is missing, the account must reconnect — point the user to `get_connection_urls`.

Two ways to target:

- **An Antwork post** you published: `comment_post(text, post_id)`.
- **An external LinkedIn post** (not created in Antwork): `comment_post(text, post_urn, account_id)` — pass the LinkedIn URN plus which account comments.
- **Replying to a comment:** add `parent_comment_urn` to nest the reply under it.

Always show the user the exact comment text and which account it posts from, and get explicit go-ahead before calling — this is public. Never silently pick an account when several could comment.

## 4. Retry failed posts

A post in `failed` status didn't make it out (dead token, transient platform error, over-limit text at dispatch time). To recover:

1. `list_posts(status="failed")` to find it, or `get_post(post_id)` for the failure detail.
2. Diagnose first — if the cause is a dead token, `retry_failed_post` will just fail again. Check the account's `tokenHealthStatus` via `list_social_accounts` and reconnect if needed (`antwork-setup`). If the text is over the platform limit, `update_post` to trim it first.
3. `retry_failed_post(post_id)` once the cause is cleared.

Report the outcome with the live URL on success, or name the platform and quote the error on failure — don't say "retried" and leave it ambiguous.

## 5. Don't invent engagement

Antwork exposes commenting and retry — not likes, follows, DMs, or reactions. If the user asks for those, say they're not available through Antwork rather than pretending. There is no "react" or "like" tool.
