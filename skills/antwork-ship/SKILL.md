---
name: antwork-ship
description: Use when the user wants to post about what they shipped — turning the current git repo's recent commits, merged PRs, tags or release notes into build-in-public posts through Antwork, drafted per account in each account's own voice. Trigger on "/antwork ship", "ship it", "post what I shipped", "build in public", "bip", "turn my commits/PRs/release into posts", "announce this release", "changelog to LinkedIn/X", or "what should I post about this week's work". Best from a coding agent (Claude Code, Codex, Cursor) running inside the repo.
---

# Ship: from what you built to posts about it

The writing is the easy part. The judgment is the job: picking the two or three things worth a post out of a week of commits, telling them as a story instead of a changelog, and never claiming more than the code shows. Run the steps in order, and stop where the steps say stop.

## Arguments

`/antwork ship [--since <date|ref>] [--release <tag>] [--platforms linkedin,x,...] [--repo <path>]`

- **No range given:** everything since the most recent tag (`git describe --tags --abbrev=0`). If the repo has no tags, the last 7 days.
- **`--release <tag>`:** that release only: the tag's notes, plus the commits between the previous tag and it.
- **`--since`:** a date (`2026-10-01`), a ref (`v1.4.0`, a SHA) or a span (`14 days`).
- **`--platforms`:** limit the accounts. Without it, every connected account, confirmed in step 4.
- **`--repo`:** a path other than the current directory.

## 1. Read what happened (read-only)

From inside the repo, collect the window:

- `git log --no-merges --format='%h%x09%ad%x09%s%n%b' --date=short <range>` for the commits.
- If `gh` is available and the remote is GitHub: `gh pr list --state merged --search "merged:>=<start date>" --json number,title,body,mergedAt,labels,url` (a merged PR's title and body already say what changed in human words, so they beat raw commits) and `gh release view <tag> --json name,body,url` for a release.
- `git diff --stat <range>` for the scale of each change, when you need it.

No shell here (claude.ai, ChatGPT)? Ask the user to paste the commit list, PR titles or release notes, or use a GitHub connector if one is connected.

**Private repo or unreleased work is a gate.** If the remote is private, say so and ask before turning anything in it into a public post. Some work isn't meant to be public yet.

## 2. Pick the few things worth a post

Score every candidate and surface only the top 3 to 5.

**Promote:**
- A tagged release.
- A user-facing feature, or a first-time capability ("X now does Y").
- A hard bug killed, or a speed-up **with a number**.
- A migration, rewrite or decision you can explain in one human sentence, and the lesson it taught.
- A milestone (first customer, Nth release, a metric crossing a line), stated plainly.

**Skip (never post these raw):** dependency and lockfile bumps, version-only commits, lint and formatting, CI and workflow tweaks, generated files, merge commits, reverts, `wip`, typo fixes.

Then **group by feature, not by commit.** One capability spread across eight commits is one post, not eight.

**Stop and show the shortlist** before writing anything: one line each, *development → why it matters → suggested angle*, with the PR or commit link. Editing a shortlist is cheaper than editing drafts.

## 3. Turn each pick into an angle

A changelog is not content. Frame each survivor as one of:

- **The problem it removes:** what was painful before, what is gone now.
- **The lesson:** what building it taught you. Usually the strongest.
- **The milestone:** said plainly, without hype.
- **Behind the scenes:** the real, messy story of getting it working.
- **The contrarian take:** a belief the work changed.

## 4. Draft per account, in that account's voice

Follow the Antwork drafting protocol exactly:

1. Read `workspaceAccounts` on any workspace-scoped result for the connected accounts. If none are connected, call `get_connection_urls` and stop. Confirm which accounts get posts (or use `--platforms`).
2. Call `get_post_context(account_ids=[...])` once for the chosen accounts. The recent posts it returns **are** each account's voice: its length, tone, emoji and hashtag habits, and whether it writes in first person. Match them. Never impose a house style, and don't assume one account sounds like another.
3. Write a native version per account. Don't paste one body everywhere: X needs the sharpest line within 280 characters, LinkedIn has room for the lesson (up to 3,000), Threads wants one conversational idea (500). Respect every platform's hard limit.
4. Create drafts:
   - one development on one account: `create_post(text, account_id)`;
   - one development on several accounts: `create_campaign(variants=[{account_id, text}, ...])`, one variant per account, each written for that account.

   Both create **drafts only**. Nothing is scheduled or live yet.
5. Before drafting, `list_posts(query=<feature name>)` for anything already posted about the same development, so you don't announce it twice.

Show the user every draft. Change what they ask to change with `update_post`.

## 5. Proof, optional

A post lands harder with a receipt: the release page, the PR, a screenshot of the feature. If the user has an image file, attach it with the route the `create_post` or `get_post` response names for this host. In a terminal that is usually `request_upload_url` → upload the file to the signed URL → `register_uploaded_media(..., attach_to_post_id=...)`. **Show the user each image before attaching:** dashboards and admin pages leak customer names, metrics and config.

## 6. Schedule or publish, only on an explicit yes

- **Schedule:** `get_workspace_settings` for the preferred posting times, `get_calendar` for the days around them so posts don't stack on one slot, then `schedule_post(post_id, scheduled_for)` or `schedule_campaign(campaign_id, scheduled_for)`. At most 30 days ahead.
- **Publish now:** `publish_post(post_id)` or `publish_campaign(campaign_id)`.
- **Leave as drafts** if the user hasn't said which.

Report what actually happened. Never say "scheduled" when only drafts exist.

## Guardrails

- **Claim only what the repo shows.** Check the diff, not just an optimistic commit message. A refactor isn't a launch. Your audience includes people who can read your commits.
- **Never leak** secrets or tokens from commit messages, customer names or data, internal hostnames, or the details of an unreleased security fix.
- **Private repo, explicit approval,** every time.
