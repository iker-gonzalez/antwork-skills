# Launch Week — {{product / announcement}}

`campaign_id`: {{shared id}} · Launch day: {{date}} · Timezone: {{IANA tz}}
Goal: {{the one outcome}} · Success metric: {{one number}}

The arc: build tension before, peak on launch day, sustain proof after.
One slot = one `create_post` (single account) → `schedule_post(post_id, scheduled_for)`.

## Pre-launch — teasers (T-5 to T-1)

| # | Day | Account / Platform | Role | Hook | `goal` |
|---|-----|--------------------|------|------|--------|
| 1 | T-5 | @handle / x | problem you're solving | {{hook}} | tease |
| 2 | T-3 | @handle / linkedin | behind-the-scenes / why | {{hook}} | tease |
| 3 | T-1 | @handle / x | "tomorrow…" + waitlist CTA | {{hook}} | tease |

## Launch day (T-0)

| # | Time | Account / Platform | Role | Hook | `goal` |
|---|------|--------------------|------|------|--------|
| 4 | 09:00 | @handle / linkedin | the reveal — what it is, who it's for | {{hook}} | launch |
| 5 | 09:05 | @handle / x | reveal, short + link | {{hook}} | launch |
| 6 | 13:00 | @handle / threads | the story behind it | {{hook}} | launch |
| 7 | 18:00 | @handle / x | early reactions / momentum | {{hook}} | launch |

> Consider `publish_post` live at the launch moment instead of pre-scheduling,
> so the reveal lands to the second. It returns live URLs — report them.

## Follow-up — proof & last call (T+1 to T+5)

| # | Day | Account / Platform | Role | Hook | `goal` |
|---|-----|--------------------|------|------|--------|
| 8 | T+1 | @handle / linkedin | early results / testimonial | {{hook}} | social-proof |
| 9 | T+3 | @handle / x | a use case / how people use it | {{hook}} | social-proof |
| 10 | T+5 | @handle / x | last call / recap + CTA | {{hook}} | last-call |

---
Track with `list_posts(status="scheduled")` and `get_calendar`. After launch,
measure the set via `antwork-analytics` (shared `campaign_id`, per-post `goal`).
