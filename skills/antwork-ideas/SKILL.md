---
name: antwork-ideas
description: Use when the user wants content ideas, hooks, or angles for their social posts grounded in what has actually worked for their account — not generic brainstorming. Trigger on phrases like "give me post ideas", "what should I post", "I'm out of ideas", "content ideas for this week", "hooks for LinkedIn", "ideate", or any request for what to write next. Pulls the account's top performers and voice first, then generates ideas in that proven lane.
---

# Generating content ideas in Antwork

Generic brainstorming is worthless — the user can get "10 LinkedIn post ideas" from any chatbot. Antwork's edge is **data**: this account's real top performers and its captured voice. Ground every idea in both. Ideas should look like "more of what already worked for *you*," not a listicle.

## 1. Pull the evidence first — never ideate cold

Before generating anything, gather:

1. `get_performance(limit)` — the account's top posts by lifetime engagement. This is the proven lane.
2. `get_post_context(platform, account_id)` — the voice profile, brand context, and recent 3 posts. If `voiceStale` is true, hand to **`antwork-voice`** first; ideas in the wrong voice waste everyone's time.

If the account is new and has no performance history, say so plainly and ideate from voice + brand + the user's stated goals instead — but don't pretend you're being data-driven when you aren't.

## 2. Find the pattern, then extend it

Read the top performers and name *why* they worked — hook type (bold claim, contrarian take, question, personal story, useful list), topic cluster, format, length. Then generate ideas that reuse the winning mechanism on fresh material. "Your contrarian one-liners outperform — here are 6 more contrarian takes on adjacent topics" beats a random grab bag.

Mix the slate so it isn't one-note: ~60% in the proven lane, ~40% adjacent experiments to find the next winner.

## 3. Output a ranked, decision-ready list

Give a numbered list. Each idea is one row:

- **Hook** — the actual opening line, written in the account's voice (not a topic label).
- **Platform** — the account it fits, respecting that platform's norms.
- **Angle** — the one-sentence shape of the post.
- **Why** — the evidence: which past winner or voice trait it draws on.

Rank by expected payoff (proven-lane ideas first). Keep hooks tight and in-voice — apply the same anti-AI-tells rule the voice profile enforces (no "Here's the thing:", no "Let me break it down", no emoji-spray openers).

## 4. Hand off cleanly

Ideas are upstream of action. Close by offering the next step:

- Turn a pick into a draft → **`antwork-poster`**.
- Spread a batch across the week → **`antwork-calendar`**.
- Build a themed sequence → **`antwork-campaign`**.

Don't call `create_post` from here unless the user picks an idea and says go — ideation produces a menu, not drafts.
