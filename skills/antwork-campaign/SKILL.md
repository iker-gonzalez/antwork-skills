---
name: antwork-campaign
description: Use when the user wants to run a multi-post campaign or launch week through Antwork — a sequence of posts spread over days that build toward a goal (product launch, event, sale, announcement, content series). Trigger on phrases like "plan a launch week", "build a campaign", "tease and launch a product", "a series of posts leading up to X", "drip a campaign over the next two weeks", or any request to coordinate several posts toward one outcome.
---

# Running a campaign with Antwork

A campaign is a sequence of posts, each bound to one account, all sharing a `campaign_id`, scheduled across days toward a single goal. The work is to design the arc first, get approval, then create and schedule the sequence. This workflow codifies the mistakes assistants make when coordinating multi-post pushes.

## 1. Define the campaign before drafting

Pin down the brief before any copy. Capture it in `templates/campaign-brief.md`:

- **Goal** — what the campaign should achieve (signups, attendance, sales, awareness) and the single success metric.
- **Window & cadence** — start/end dates and how many posts on which days.
- **Audience & key message** — the through-line every post reinforces.
- **Platforms/accounts** — which `account_id`s (check `list_social_accounts`; skip unhealthy tokens).

For launch-shaped campaigns, use `templates/launch-week.md` for the classic arc: pre-launch teasers → launch-day push → follow-up / social proof.

## 2. Pull context and design the arc

- `get_optimal_posting_times` — default slots and timezone.
- `get_calendar(date_from, date_to)` — so the campaign weaves around existing posts, not on top of them.
- `get_post_context(platform, account_id)` per account — voice, brand, `voiceStale`. Refresh stale voices (via `antwork-voice`) before drafting a multi-day sequence.

Design the sequence so each post has a distinct job (tease → reveal → proof → last call), not five rewordings of the same announcement.

## 3. Present the sequence as a plan — and wait

Present the full sequence as a **numbered plan** and stop for explicit approval before creating anything. One row per post:

`# | date · time (tz) | account / platform | role in arc | hook | goal`

Editing a 7-post plan is far cheaper than editing 7 drafts. Don't call `create_post` during planning.

## 4. Create the sequence under one campaign_id

Generate one `campaign_id` for the whole push. For each post in the approved sequence:

- `create_post(text, account_id, hashtags?, goal="<per-post goal>", campaign_id="<shared-id>")`.

Set a meaningful per-post `goal` (e.g. "tease", "launch", "social-proof", "last-call") — it makes later performance analysis legible. Multi-platform on the same day = multiple `create_post` calls sharing the same `campaign_id`; there is no platforms array. Everything is still a DRAFT at this point.

Respect hard char limits per platform (X 280, Threads 500, Pinterest 800, IG 2200, LinkedIn 3000, TikTok 4000, YouTube 5000, FB 63206) — scheduling rejects anything over.

## 5. Schedule across the window

Schedule each draft to its slot: `schedule_post(post_id, scheduled_for)` with ISO 8601 timestamps drawn from the optimal times, spread across the campaign days. A draft isn't on the calendar until `schedule_post` succeeds. If a call is blocked (over limit, or `needs_reconnect` with a `reauthUrl`), name the specific post and reason.

For a hard launch moment you want live to the second, `publish_post(post_id)` at the moment instead of pre-scheduling — it returns live URLs; report them.

## 6. Track the campaign as it runs

- `list_posts(status="scheduled")` and `get_calendar` — confirm the full arc is queued and see it laid out.
- `search_posts(query, ...)` or filter by the campaign topic to pull the set together.
- After posts go live, hand off to the `antwork-analytics` skill — filter on the campaign's posts (shared `campaign_id`, per-post `goal`) to measure against the success metric.
- Any post that failed to publish: `retry_failed_post(post_id)`.

## 7. Cleanup

If the user cuts a post from the campaign, `update_post(post_id, status="draft")` to pull it off the calendar, or `delete_post` to remove it — confirm first, since deleting a scheduled draft is a hard delete. Published posts soft-delete by default and preserve analytics.
