---
name: antwork-calendar
description: Use when the user wants to plan and batch-schedule a content calendar through Antwork — filling a week or month with posts across accounts, spacing them at optimal times, and avoiding clashes with what's already scheduled. Trigger on phrases like "plan my week/month of content", "build a posting calendar", "schedule a batch of posts", "fill my calendar", "what should I post this week", or any request to lay out and schedule multiple posts at once.
---

# Planning a content calendar with Antwork

Antwork is an MCP-native social scheduler. A calendar is just a set of drafts each bound to one account and a `scheduled_for` time. The job is to plan the whole grid *first*, get approval, then create and schedule each slot. This workflow codifies the mistakes assistants make when batch-scheduling.

## 1. Read the existing calendar before proposing anything

Never schedule into a vacuum. First call:

- `get_calendar(date_from, date_to)` — what's already scheduled or published in the target window. Plan *around* it; don't double-book a slot or repeat a topic that just went out.
- `get_optimal_posting_times` — the workspace's configured posting times and timezone, plus which accounts are selected per platform. These times are your default slots.
- `list_social_accounts` — the accounts you can target (with `account_id`, platform, handle, token health). Skip accounts whose `tokenHealthStatus` isn't `healthy` — flag them for reconnect instead of scheduling onto a dead token.

If multiple workspaces exist and none is default, resolve with `set_default_workspace` before anything else.

## 2. Present the calendar as a plan — and wait

Editing a plan is cheaper than editing fifteen drafts. Present the calendar as a **numbered table** and stop for explicit approval before creating a single post. One row per slot:

`# | date · time (tz) | account / platform | hook | goal`

Use `templates/content-calendar.md` as the skeleton. Space slots across the `get_optimal_posting_times` windows — don't stack three posts at 09:00. Respect per-platform cadence norms (X tolerates several a day; LinkedIn one a day is plenty). Vary topics and formats across the week so the feed doesn't read as repetitive.

Do **not** call `create_post` during planning.

## 3. Draft in the account's voice, per slot

Once approved, work slot by slot. For each row, before writing copy:

- `get_post_context(platform, account_id)` — pulls brand, the account's voice profile, recent posts, and a `voiceStale` flag. Match that voice; don't impose a house style. If `voiceStale` is true, mention it and offer to refresh via the `antwork-voice` skill before drafting a whole week in a stale voice.

Write each post to its single target account. There is no multi-platform field — **one `create_post` per account**. If the same idea should run on three accounts, that's three `create_post` calls; give them a shared `campaign_id` so they stay grouped.

Respect the hard character limit for each platform (X 280, Threads 500, Pinterest 800, Instagram 2200, LinkedIn 3000, TikTok 4000, YouTube 5000, Facebook 63206). `schedule_post` refuses anything over the limit, so trim before you schedule.

## 4. Create, then schedule — the two-step

`create_post` produces a **DRAFT**. It does not put the post on the calendar. For each slot:

1. `create_post(text, account_id, hashtags?, goal?, campaign_id?)` → returns `post_id`.
2. `schedule_post(post_id, scheduled_for)` with an ISO 8601 timestamp at the planned slot.

Only after `schedule_post` succeeds is the post actually on the calendar. Telling the user "your week is scheduled" after only `create_post` is false.

`schedule_post` runs an account health check and a character-limit check. If it blocks, name the specific slot and reason (over limit, or `needs_reconnect` with the `reauthUrl`) rather than saying "scheduling failed."

## 5. Confirm with the calendar view

After scheduling the batch, call `get_calendar` again for the window and report back the filled grid — date, time, account, hook — so the user sees the whole week at a glance. Note any slots that were skipped and why (dead token, over limit) instead of silently dropping them.

## 6. Edits and reschedules

- Move a slot: `update_post(post_id, scheduled_for=...)` — it reschedules only when the time actually changes.
- Reuse a strong post on another account: `duplicate_post(post_id, account_id=..., text=...)` to clone and retarget, then `schedule_post` the clone.
- Pull a slot: `update_post(post_id, status="draft")` to take it off the calendar without deleting, or `delete_post` to remove it (confirm first — deleting a scheduled draft is a hard delete).
