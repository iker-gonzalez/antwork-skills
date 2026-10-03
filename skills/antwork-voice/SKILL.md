---
name: antwork-voice
description: Use when the user wants Antwork drafts to sound like them — reading an account's voice from its real posts, capturing a voice for an account with no history, auditing whether drafts match, or fixing AI-sounding copy. Trigger on phrases like "learn my voice", "match my writing style", "my posts sound like a robot", "set up my brand voice", "analyze my LinkedIn tone", or any request to make Antwork posts sound on-brand.
---

# Reading an account's voice in Antwork

Antwork keeps **no stored voice profile**. An account's voice is its own recent posts: `get_post_context` returns up to 15 of them, with their engagement, every time it is called. This skill turns those posts into a precise read of how the account writes, so drafts match it instead of sounding like generic AI.

## 0. One voice PER account, not per user

Voice belongs to the **social account**. A founder's personal LinkedIn is not their company X. Read each account on its own and never carry one account's voice onto another.

## 1. Load the posts

Call `get_post_context(platform, account_id)`, or `get_post_context(account_ids=[...])` for several accounts in one call. `recentPosts` holds the account's published posts with likes, comments, shares and impressions. Weight the posts that performed: they are the voice the audience responds to.

**No history?** An empty `recentPosts` means there is nothing to imitate. Ask the user to paste 3–5 posts that sound like them (or that they wish they had written) and read those instead. Never invent a voice from nothing.

## 2. Read the voice, with evidence

Read the posts yourself and name what you see, quoting real phrases. Use `templates/voice-read.md` for the full shape:

- **Tone** — formal / founder-mode / playful / corporate / contrarian. Name it, don't default to it.
- **Voice & pronouns** — "I/my" for solo creators, "we/our" for brands and teams. Read it off the posts.
- **Style** — sentence length, paragraph rhythm, line breaks, lists, one-liners.
- **Emoji** — none / sparing / signature, and which ones they actually use.
- **Hashtags** — count, placement (inline vs. footer), branded tags.
- **Closers** — question, soft ask, hard CTA, link drop, none.
- **Signature phrases & mannerisms** — recurring openers, words, habits that make it *them*.

A read that says "professional and engaging" is useless. One that says "opens with a blunt one-line claim, no emoji, closes with a single question" is what makes a draft sound right.

## 3. Show it, then use it

Give the user the 2–3 most distinctive traits in a few lines so they can correct you, then apply the read to every draft for that account in this conversation. Nothing is saved: the next session reads the posts again, which means the voice keeps up as the account's writing changes.

## 4. Auditing drafts against the voice

When the user says a draft sounds off, compare it line by line with the read: wrong pronouns, emoji the account never uses, a closer it never writes, a length far outside its range. Redraft with `update_post`, not a new post.

## 5. Across every voice — kill the AI tells

Whatever the account's voice, strip the phrases that mark text as machine-written: "Here's the thing:", "Let me break it down", "Buckle up", "In today's fast-paced world", emoji-heavy openers, and the relentless rule-of-three. The read says what to *do*; this is the universal *don't*.
