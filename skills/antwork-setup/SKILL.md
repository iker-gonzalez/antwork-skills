---
name: antwork-setup
description: Use when the user is getting started with Antwork or fixing a broken connection — first-time onboarding, connecting or reconnecting social accounts, setting the workspace timezone and preferred posting times, or naming/branding a workspace. Trigger on phrases like "set up Antwork", "connect my LinkedIn/X/Instagram", "my account is disconnected", "reauthorize", "set my posting times", "set my timezone", "create a workspace", or "why won't my posts publish".
---

# Setting up Antwork

This skill gets a user from "just connected the Antwork MCP" to "ready to publish." Run it top to bottom for first-time onboarding; jump to the relevant step for a specific fix (e.g. a dead token). Antwork is MCP-native — everything here is a tool call, not a dashboard click.

## 1. Confirm who's authenticated

Start with `whoami`. It returns the user ID, email, display name, subscription status, and default workspace.

- If it errors on auth, the MCP connector isn't authorized — tell the user to connect/authorize the Antwork connector in their client, then retry.
- Note the **subscription status** (`active` / `trialing` / `canceled` / `past_due`). If it's `canceled` or `past_due`, surface that early — publishing may be blocked — rather than letting them hit a wall later.

## 2. Resolve the workspace

Call `list_workspaces`.

- **No workspaces** → `create_workspace(name)` (1–50 chars). The first one is auto-set as default.
- **Multiple workspaces, no default** → ask which one, then `set_default_workspace(workspace_id)`. Until a default is pinned, every other tool will keep asking you to disambiguate.
- **One workspace** → it's auto-selected; nothing to do.

Then `get_workspace_settings` to read the current name, timezone, preferred posting times, and connected platforms — this is your baseline for steps 4–5.

## 3. Audit connected accounts

Call `list_social_accounts`. For each account check `tokenHealthStatus`:

- `healthy` — good.
- `expiring_soon` — works now, flag it; reconnect soon.
- `expired` / `needs_reconnection` — **broken**; scheduled posts on this account will NOT publish until reconnected.

List back what's connected vs. broken vs. missing, one line per platform, before doing anything.

## 4. Connect or reconnect platforms

For any platform the user wants but isn't connected (or is unhealthy), call `get_connection_urls`. It returns per-platform OAuth URLs and a connected/notConnected breakdown.

- On **UI hosts** (Claude.ai, Claude Desktop) it renders a connections panel — point the user at it.
- On **CLI hosts** (Claude Code, Cursor) there's no panel — give the user the exact OAuth URL to open in a browser, one per platform they asked for.

**Threads is special:** its OAuth token can't be refreshed. When a Threads account goes stale, the only fix is `disconnect_social_account` then reconnect from scratch — there's no silent re-auth. Confirm before disconnecting (it's destructive: the account is soft-deleted and its scheduled posts won't publish until reconnected).

Supported platforms: `linkedin`, `x`, `facebook`, `instagram`, `threads`, `youtube`, `tiktok`, `pinterest`.

## 5. Set posting defaults

Two calls make the workspace publish-ready:

- `update_workspace_settings(timezone, preferred_times)` — `timezone` is an IANA name (e.g. `"Europe/Madrid"`, `"America/New_York"`); `preferred_times` is a list of `HH:MM` strings (e.g. `["09:00", "18:00"]`). These drive scheduling suggestions and the calendar. Ask the user's timezone if you don't already know it — don't guess.
- `update_workspace_identity(name, website, logo_url)` — brand identity used when drafting. Changing it bumps `brandVersion`, which downstream voice/drafting context keys off.

## 6. Hand off to voice

A connected account with no voice profile drafts in a generic tone. Once accounts are healthy, recommend a voice pass (the `antwork-voice` skill / `prepare_voice_analysis` → `save_voice_analysis`) for each platform the user will actually post on. That's the difference between "it posts" and "it sounds like me."

## Quick diagnostic: "why won't my posts publish?"

1. `whoami` → subscription not `active`/`trialing`? That's it.
2. `list_social_accounts` → target account `expired`/`needs_reconnection`? Reconnect via `get_connection_urls` (or disconnect+reconnect for Threads).
3. `get_workspace_settings` → timezone/preferred_times unset can make scheduled times land oddly.
4. The post itself may be over the platform character limit — `schedule_post`/`publish_post` refuse over-limit text. Check the post.
