---
name: antwork-repurpose
description: Use when the user wants to turn ONE piece of source content into platform-native posts through Antwork — a blog post, newsletter, long LinkedIn post, podcast/video transcript, or talk reshaped into versions for each platform. Trigger on phrases like "repurpose this", "turn this blog into posts", "make this into a LinkedIn + X + Threads version", "atomize this content", "spin this into social", or pasting long-form content and asking to distribute it.
---

# Repurposing one piece into platform-native posts

Antwork binds each post to a single account, and platform is derived from that account. Repurposing means writing a *distinct, native* version per platform — never one body copy-pasted everywhere — and grouping them as one campaign. This workflow codifies the mistakes assistants make when atomizing content.

## 1. Anchor the source

Identify the one source piece and its core idea. If the user hasn't pasted it, ask for the text, URL, or transcript. Extract the spine before reshaping:

- The single biggest claim or takeaway.
- 3–5 supporting points or moments that can each stand alone.
- Any quotable line, stat, or hook.

This spine is what gets reshaped per platform — not the prose itself.

## 2. Pick targets and pull each voice

Confirm which accounts to publish to (`list_social_accounts` if unsure — note `account_id`, platform, token health). For **each** target platform, before writing:

- `get_post_context(account_ids=[...])` — brand plus each account's recent posts, which are its voice. Each account has its own; LinkedIn-you and X-you are not the same writer.

## 3. Reshape — do not reuse

Write a **native variant per platform**. Reusing one body across platforms is the core failure: X's 280-char cap mangles LinkedIn prose, and LinkedIn-length paragraphs look broken on Threads. Reshape for each:

- **X (280)** — the sharpest single claim, or a thread broken into beats. No fluff.
- **Threads (500)** — conversational, one idea, lighter than LinkedIn.
- **LinkedIn (3000)** — room to tell the story; hook line, whitespace, a takeaway. Longer (300–600 words) is fine *only here*.
- **Instagram (2200)** — caption that works under a visual; front-load the hook.
- **Facebook / YouTube / Pinterest / TikTok** — match the platform's norm and limit.

Honor every hard limit (X 280, Threads 500, Pinterest 800, IG 2200, LinkedIn 3000, TikTok 2200, YouTube 5000, FB 63206) — `schedule_post`/`publish_post` reject anything over. Match each account's recent posts for tone, emoji and hashtag use, and CTA style. Avoid AI tells ("Here's the thing:", "Let me break it down", emoji-heavy openers).

Capture the brief in `templates/campaign-brief.md` if the user wants a record of the repurpose set.

## 4. Create as one grouped set

Create every variant in one call:

- `create_campaign(variants=[{account_id, text, hashtags?, goal?}, ...])`, one entry per target account, each with its own copy.

It returns the `campaign_id` and one post per account, so the set can be tracked, compared and cleaned up together. A variant that fails validation is reported with its reason and the others are still created. Shared media goes in `media_urls` on the same call. Everything is still a DRAFT; nothing is live yet.

## 5. Present, pick, ship

Show the drafts side by side (platform → variant) and let the user edit or drop any before anything goes out. Then per the user's intent:

- **Schedule, staggered**: `schedule_post(post_id, scheduled_for)` (ISO 8601) per variant, spread across the day/week using the preferred times from `get_workspace_settings` rather than firing all variants at once. At most 30 days ahead.
- **Schedule, all at one time**: `schedule_campaign(scheduled_for, campaign_id)`.
- **Publish now**: `publish_campaign(campaign_id)`. It publishes the whole set in one call and returns live URLs; report them back, one line per account. Don't call `publish_post` once per variant: each one waits on its platform in turn.

Never claim a variant is "posted" after only `create_post`. Complete the second step.

## 6. Media carries over, but per platform

If the source has an image or video, attach the right asset to each variant — `attach_media(post_id, media_urls)` (it replaces the post's media, so pass the full set), or `upload_media(image_url)` first for a public/AI-generated image. One asset that suits every platform can go in `create_campaign`'s `media_urls` instead. Don't assume one aspect ratio fits every platform; flag when a visual needs reformatting for, e.g., Instagram vs. LinkedIn.
