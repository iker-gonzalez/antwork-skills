#!/bin/bash
# Antwork Skills — Uninstaller
# Removes the Antwork toolkit (skills + agents + templates) from Claude Code.

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}Antwork Skills — Uninstaller${NC}"
echo ""

SKILLS_DIR="$HOME/.claude/skills"
AGENTS_DIR="$HOME/.claude/agents"

SKILLS=(
    "antwork"
    "antwork-setup"
    "antwork-voice"
    "antwork-poster"
    "antwork-calendar"
    "antwork-repurpose"
    "antwork-campaign"
    "antwork-ideas"
    "antwork-analytics"
    "antwork-engage"
    "antwork-media"
    "antwork-audit"
)

AGENTS=(
    "antwork-performance"
    "antwork-voice-analyst"
    "antwork-cadence"
    "antwork-content"
    "antwork-growth"
)

echo -e "${BLUE}Removing skills...${NC}"
REMOVED=0
for skill in "${SKILLS[@]}"; do
    if [ -d "$SKILLS_DIR/$skill" ]; then
        rm -rf "$SKILLS_DIR/$skill"
        echo -e "  ${GREEN}✓${NC} removed $skill"
        REMOVED=$((REMOVED + 1))
    fi
done

echo -e "\n${BLUE}Removing agents...${NC}"
for agent in "${AGENTS[@]}"; do
    if [ -f "$AGENTS_DIR/$agent.md" ]; then
        rm -f "$AGENTS_DIR/$agent.md"
        echo -e "  ${GREEN}✓${NC} removed $agent"
        REMOVED=$((REMOVED + 1))
    fi
done

echo ""
if [ "$REMOVED" -eq 0 ]; then
    echo -e "${YELLOW}Nothing to remove — Antwork skills were not installed.${NC}"
else
    echo -e "${GREEN}Uninstall complete.${NC} Removed $REMOVED item(s)."
    echo -e "${YELLOW}Restart your Claude Code session to unload them.${NC}"
fi
echo ""
