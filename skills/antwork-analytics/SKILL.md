---
name: antwork-analytics
description: Use when the user wants to understand how their social content is performing through Antwork — pulling engagement metrics, ranking top posts, spotting per-platform trends, comparing time periods, or turning numbers into a what-to-do-next report. Trigger on phrases like "how are my posts doing", "what's my best post", "engagement report", "analytics", "which platform is working", "show my growth", "refresh my metrics", or any request for social performance data.
---

# Reporting on performance in Antwork

Antwork's analytics tools return **BigQuery-style tabular data** — `{ schema: { fields }, rows, rowCount }` — not charts. Your job is to pull the right table, then synthesize it into a decision: what's working, on which platform, and what to make more of. Numbers without a recommendation are not a report.

## 1. Pick the right query — don't pull everything

| Question | Tool | Notes |
|---|---|---|
| "What are my best posts?" | `get_performance(limit)` | Lifetime totals per published post (likes, comments, shares, impressions, totalEngagement). Best for **rankings**. 1–50, default 30. |
| "How is engagement trending?" | `get_engagement_history(days)` | Daily series per platform + an "all" aggregate, plus platformTotals/rangeTotals. Best for **trends over time**. 1–365 days, default 30. |
| "How did *this* post grow?" | `get_engagement_history(post_id=..., days?)` | Per-day metrics for one post, both cumulative and daily-delta. Best for **single-post lifecycle**. Omit `days` for full history. |
| "When should I post?" | `get_workspace_settings()` | The workspace's configured times (`defaultPostingSchedule`) + timezone + selected accounts. |

Start with `get_performance` for almost any "how am I doing" ask, then drill in with the others.

## 2. Numbers are a few hours old, by design

Metrics refresh on their own every 6 hours, and there is no tool to force a refresh. A post published minutes ago shows its first numbers after the next refresh; say so rather than reporting zeros as a result.

## 3. Read the table, then interpret

The rows are raw. Turn them into findings:

- **Top performers** — rank by `totalEngagement`, but look *past* the number to the pattern. What do the top 3 share — format, hook style, topic, length, platform, posting time?
- **Per-platform trends** — from `get_engagement_history` platformTotals: which platform is growing, which is flat, where's the effort/return mismatch.
- **Outliers** — one post 5× the median is a signal, not noise. Name what made it land.
- **Gaps** — platforms with no recent posts, or with traffic but no posting cadence.

## 4. Tie every finding to an action

The report's value is the "so what." Each finding gets a next step, and the strongest ones feed straight into other skills:

- Winning hooks/topics → hand to **`antwork-ideas`** to generate more in the same vein.
- Best posting windows → feed **`antwork-calendar`** when scheduling.
- A high performer worth a sequel → **`antwork-repurpose`** it to other platforms.

## 5. Output

For a quick ask, give a tight terminal summary (top 3 posts + the one thing to do more of). For a full report, write a markdown file following `templates/analytics-report.md` — header with workspace/date/range, executive summary, top-performers table, per-platform trends, and a prioritized recommendations list. Always state the date range the numbers cover, so a stale report can't be mistaken for current.
