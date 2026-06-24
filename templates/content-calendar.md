# Content Calendar — {{workspace}} · {{period}}

Timezone: {{IANA timezone}} · Optimal slots: {{from get_optimal_posting_times}}
Status legend: `idea` → `draft` → `scheduled` → `published`

## Week of {{start date}}

| # | Date · Time | Account / Platform | Hook | Goal | Status |
|---|-------------|--------------------|------|------|--------|
| 1 | Mon 09:00 | @handle / linkedin | {{one-line hook}} | {{awareness / signups / engagement}} | idea |
| 2 | Mon 18:00 | @handle / x | {{hook}} | {{goal}} | idea |
| 3 | Tue 09:00 | @handle / threads | {{hook}} | {{goal}} | idea |
| 4 | Wed 12:00 | @handle / instagram | {{hook}} | {{goal}} | idea |
| 5 | Thu 09:00 | @handle / linkedin | {{hook}} | {{goal}} | idea |
| 6 | Fri 16:00 | @handle / x | {{hook}} | {{goal}} | idea |
| 7 | {{...}} | {{...}} | {{...}} | {{...}} | idea |

## Notes

- **Themes this period:** {{e.g. Mon = insight, Wed = behind-the-scenes, Fri = proof}}
- **Do not clash with:** {{existing scheduled posts from get_calendar}}
- **Skipped accounts:** {{account + reason — e.g. dead token, awaiting reconnect}}

---
Fill one row per slot. Space rows across the optimal posting times — don't stack.
One row = one `create_post` (single account) → `schedule_post(post_id, scheduled_for)`.
Posts that should run on multiple accounts get one row each, sharing a `campaign_id`.
