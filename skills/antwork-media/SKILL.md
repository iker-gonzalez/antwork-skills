---
name: antwork-media
description: Use when the user wants to add images, video, or PDFs to Antwork posts, or manage their media library — uploading a file, attaching an AI-generated image, browsing or deleting media. Trigger on phrases like "add an image to this post", "attach a photo/video/PDF", "upload this picture", "use this AI-generated image", "show my media library", or "remove that image".
---

# Media in Antwork

Attaching media depends on **where you're running**. Every post tool response carries a `hostSupportsUi` flag — read it and pick the right path. Get this wrong and you'll either call a tool that doesn't exist on this host, or make the user do manual work the UI would have done for them.

## Path A — UI hosts (Claude.ai, Claude Desktop)

When `hostSupportsUi` is true, the post card renders its own **Add media** picker. The user drops a file straight onto the card and it attaches automatically.

- **Do NOT call `upload_media_inline` from chat** — it's an iframe-internal tool wired to the picker over a postMessage bridge (`from_ui_bridge=True`). Calling it from a normal tool turn fails.
- Your job here is just to tell the user to use the Add media button on the card.

## Path B — CLI hosts (Claude Code, Cursor, shells)

When `hostSupportsUi` is false there's no picker. Use the signed-upload flow for a local file:

1. `request_upload_url(mime_type, byte_size)` → returns a short-lived signed PUT URL, a `gcsPath`, and `expiresInSeconds`.
2. The user (or you, via a shell) PUTs the file straight to that URL, e.g. `curl -X PUT -H "Content-Type: image/png" --data-binary @photo.png "<signedUrl>"`.
3. `register_uploaded_media(gcs_path, mime_type, byte_size, attach_to_post_id)` verifies the object landed in GCS, registers it in the workspace library, and — with `attach_to_post_id` — attaches it to the post in the same call.

The signed URL expires, so finalize promptly after the PUT.

## Public images (incl. AI-generated)

If the media is already at a public **HTTPS** URL — an AI image you just generated, a hosted asset — skip the signed flow: `upload_media(image_url, mime_type)` downloads it server-side and stores it in the library. Then `attach_media` it (below), or pass it through `register_uploaded_media`'s attach hook if applicable.

## Attaching to an existing post

`attach_media(post_id, media_urls)` attaches a list of media URLs to a post. It **replaces** the post's existing media rather than appending — pass the full set you want, not just the new one.

## Browsing and cleaning up

- `list_media(media_type, limit, cursor)` — paginate the library; `media_type` is `image` / `video` / `document`; follow `nextCursor` for more.
- `get_media(media_id)` — one item's URL, name, type, size, upload date.
- `delete_media(media_id)` is **destructive** — confirm first. It removes the Firestore record; the underlying GCS file may persist, so don't promise it's wiped everywhere.

## Limits and types

- **Types:** `image/*`, `video/*`, `application/pdf`.
- **Size:** ~10 MB for images, ~100 MB for video/PDF.
- Check `mime_type` and `byte_size` against these *before* requesting an upload URL — failing the limit after the PUT wastes the round trip.
