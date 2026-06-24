---
name: antwork-voice
description: Use when the user wants to build, refresh, or audit a per-account voice profile in Antwork so drafts sound like them — including analyzing their existing posts to extract tone, capturing brand voice for a new account, or fixing AI-sounding drafts. Trigger on phrases like "learn my voice", "match my writing style", "my posts sound like a robot", "set up my brand voice", "refresh my voice profile", "analyze my LinkedIn tone", or any request to make Antwork posts sound on-brand.
---

# Building voice profiles in Antwork

A voice profile is Antwork's per-account fingerprint of how someone writes — tone, vocabulary, emoji/hashtag habits, CTA patterns. It is the ground truth every drafting skill reads before writing copy. A stale or missing profile is the #1 reason Antwork drafts read as generic AI. This skill captures and refreshes it correctly.

## 0. One profile PER account, not per user

Voice lives on the **social account** (`save_voice_analysis` takes `account_id`), not on the workspace or the user. A founder's personal LinkedIn voice is not their company X voice. Analyze and save each account separately. Never copy one account's profile onto another.

## 1. Check staleness before doing anything

Call `get_post_context(platform, account_id)`. It returns the current profile plus two signals:

- `voiceStale: true` — profile is missing, older than 30 days, or its status isn't `completed`.
- `voiceLastSyncAt` — when it was last built.

If `voiceStale` is false and the user just wants to draft, you're done — hand back to `antwork-poster`. Only run the analysis loop below when the profile is stale, missing, or the user explicitly asks to refresh it.

## 2. Fetch posts for analysis — `prepare_voice_analysis`

Call `prepare_voice_analysis(platform, account_id, max_posts)` (default 50; range 5–100). It returns the account's recent posts **plus the analysis schema** you must fill.

**LinkedIn personal accounts can't fetch their own posts** — the `r_member_social` scope is closed. If the response signals `unsupportedFetch`, fall back to the account's **Antwork-published** posts instead (posts shipped through Antwork are readable). If there aren't enough of those yet, tell the user the profile will be thin and ask them to paste 3–5 representative posts so you have material to analyze — don't fabricate a voice from nothing.

## 3. Analyze the posts yourself, against the returned schema

You do the analysis with your own reading — there is no separate model call. Read the posts and extract, matching the schema fields `prepare_voice_analysis` returned:

- **Tone** — formal / founder-mode / playful / corporate / contrarian. Name it, don't default to it.
- **Voice & pronouns** — first-person singular ("I/my") for solo creators, "we/our" for brands/teams. Read it off the posts.
- **Style** — sentence length, paragraph rhythm, use of line breaks, lists, one-liners.
- **Emoji policy** — none / sparing / signature emoji. Note specific ones they actually use.
- **Hashtag policy** — count, placement (inline vs. footer), branded tags.
- **CTA patterns** — how they close: question, soft ask, hard CTA, link drop, none.
- **Example phrases & mannerisms** — recurring openers, signature words, the things that make it *them*.
- **Do / don't** — explicit anti-patterns (e.g. "never uses 'Here's the thing:'", "no em-dash openers").

Be specific and evidence-based — quote real phrases from their posts. A profile that says "professional and engaging" is useless; one that says "opens with a blunt one-line claim, no emoji, closes with a single question" is gold.

## 4. Save it — `save_voice_analysis`

Call `save_voice_analysis(account_id, analysis, post_count)` with the filled JSON matching the schema. Pass `post_count` so freshness is tracked accurately. This persists the profile to the social account.

## 5. Confirm it took

Re-call `get_post_context(platform, account_id)` and confirm `voiceStale` is now false and the profile is populated. Report back a short summary of the captured voice (tone + the 2–3 most distinctive traits) so the user can sanity-check it before you draft anything.

## 6. Across every voice — kill the AI tells

Whatever the profile says, strip the phrases that mark text as machine-written: "Here's the thing:", "Let me break it down", "Buckle up", "In today's fast-paced world", emoji-heavy openers, and the relentless rule-of-three. The profile defines what to *do*; this is the universal *don't*.

See `templates/voice-profile.md` for the field-by-field shape of a complete profile.
