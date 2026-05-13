---
name: antwork-poster
description: Use when the user wants to draft, schedule, or publish social media posts through Antwork's MCP connector — including content planning, multi-platform optimization, voice-aware drafting, and managing scheduled posts. Trigger on phrases like "post to LinkedIn/X/Threads", "schedule a tweet", "draft a content plan", "publish to my socials", or any explicit mention of Antwork.
---

# Posting through Antwork

Antwork is an MCP-native social-media scheduler. When the user wants to ship content through it, follow this workflow — it codifies the mistakes most assistants make against this server.

## 1. Pull context before drafting

Never draft cold. Before writing any copy, call:

- `get_voice_profiles` — per-platform tone, vocabulary, recurring phrases.
- `get_workspace_settings` — brand identity, content guidelines, target audience.

Use those as the ground truth for tone. If the voice profile is empty for the target platform, ask the user once ("formal, founder-mode, casual?") rather than guessing.

## 2. Plan before drafting (for multi-post asks)

For anything bigger than a single one-off post — a content batch, a launch week, multiple platforms — present a **content plan** first as a numbered list (hook + platform + when), and wait for explicit user approval before calling `create_post`. Editing a plan is cheaper than editing five drafts.

## 3. Voice rules

- **First person singular only.** Use "I / my", never "we / our" — Antwork's users are solo-builders. Hard rule, even if the brand voice doc says otherwise.
- Keep posts short. LinkedIn is the one exception (300–600 words is fine there).
- No "Here's the thing:", "Let me break it down", "Buckle up", emoji-heavy openers — these read as AI and degrade engagement.

## 4. DRAFT vs PUBLISH — the two-step trap

`create_post` only creates a **DRAFT**. It does NOT publish or schedule. Telling the user "scheduled!" after only `create_post` is a lie.

- To **schedule for later**: `create_post` → then `schedule_post(post_id, scheduled_for)`.
- To **publish now**: `create_post` → then `publish_post(post_id)`.

Always complete both steps when the user said "schedule" or "publish now".

## 5. Multi-platform → use `platform_texts`

When a post targets more than one platform, optimize per-platform via the `platform_texts: { linkedin: "...", x: "...", threads: "..." }` argument. Don't reuse one body across platforms — X's 280-char cap mangles LinkedIn copy, and LinkedIn-length paragraphs look broken on Threads.

`get_voice_profiles` returns per-platform tone for exactly this purpose.

## 6. Be account-aware

If a workspace has multiple connected accounts on the same platform (e.g. two LinkedIn pages), state which one you'll publish from *before* calling `publish_post`. Never silently pick the first account.

## 7. Surface results after publish

`publish_post` returns per-platform success/failure plus the live URL(s). Always report them back to the user — one line per published account, with the link. On failure, name the platform specifically and quote `errorMessage` rather than saying "publish failed".

## 8. Don't invent fields

Antwork's schema is what the MCP tool args advertise — `text`, `platforms`, `platform_texts`, `hashtags`, `media_urls`, `scheduled_for`. Don't pass extras (no `title`, no `tags`, no `priority`). The server rejects unknown fields.
