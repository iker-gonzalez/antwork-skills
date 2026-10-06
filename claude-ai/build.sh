#!/usr/bin/env bash
# Builds the claude.ai skill package: one ZIP holding a single `antwork` skill.
#
# claude.ai installs skills one upload at a time and has no plugins, so the
# router becomes the skill and every other skill rides along as a reference
# file it reads on demand. Generated from skills/, agents/ and templates/ on
# every build, so the package cannot drift from the Claude Code plugin.
#
#   claude-ai/build.sh            -> dist/antwork-claude-ai-skill.zip
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/dist"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
SKILL="$STAGE/antwork"

# claude.ai caps a skill description at 200 characters, so the package gets
# its own; the router's longer one stays for Claude Code.
DESCRIPTION="Plan content calendars, repurpose, run campaigns, read an account's voice, report analytics and audit social accounts through the Antwork connector."
if [ "${#DESCRIPTION}" -gt 200 ]; then
  echo "description is ${#DESCRIPTION} chars; claude.ai allows 200" >&2
  exit 1
fi

strip_frontmatter() {
  awk 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {fm=0; next} !fm' "$1"
}

mkdir -p "$SKILL/references/agents" "$SKILL/templates"

{
  printf -- '---\nname: antwork\ndescription: %s\n---\n' "$DESCRIPTION"
  strip_frontmatter "$ROOT/skills/antwork/SKILL.md"
} > "$SKILL/SKILL.md"

for dir in "$ROOT"/skills/antwork-*/; do
  name="$(basename "$dir")"
  strip_frontmatter "$dir/SKILL.md" > "$SKILL/references/$name.md"
done
for agent in "$ROOT"/agents/*.md; do
  strip_frontmatter "$agent" > "$SKILL/references/agents/$(basename "$agent")"
done
cp "$ROOT"/templates/*.md "$SKILL/templates/"

# Every reference the router's table names must have shipped.
for name in $(grep -o '`antwork-[a-z]*`' "$ROOT/skills/antwork/SKILL.md" | tr -d '`' | sort -u); do
  [ -f "$SKILL/references/$name.md" ] || { echo "router names $name but it was not packaged" >&2; exit 1; }
done

mkdir -p "$OUT"
rm -f "$OUT/antwork-claude-ai-skill.zip"
# Fixed mtimes, so an unchanged tree builds a byte-identical ZIP.
find "$SKILL" -exec touch -t 202601010000 {} +
(cd "$STAGE" && find antwork -type f | LC_ALL=C sort | zip -qX -@ "$OUT/antwork-claude-ai-skill.zip")
echo "$OUT/antwork-claude-ai-skill.zip"
