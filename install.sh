#!/bin/bash
# Antwork Skills — Claude Code Skills Installer
# Installs the Antwork social-media toolkit (skills + agents + templates) into Claude Code.

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Antwork Skills — Claude Code Toolkit       ║${NC}"
echo -e "${CYAN}║   9 Skills · 5 Agents · 5 Templates          ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Detect script directory (support remote curl|bash install)
if [ -n "$BASH_SOURCE" ] && [ "$BASH_SOURCE" != "bash" ] && [ -f "$BASH_SOURCE" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
else
    echo -e "${YELLOW}Running remote install — cloning repository...${NC}"
    TEMP_DIR=$(mktemp -d)
    git clone --depth 1 https://github.com/polynode-co/antwork-skills.git "$TEMP_DIR/antwork-skills" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to clone repository.${NC}"
        exit 1
    fi
    SCRIPT_DIR="$TEMP_DIR/antwork-skills"
fi

# Target directories
SKILLS_DIR="$HOME/.claude/skills"
AGENTS_DIR="$HOME/.claude/agents"

echo -e "${BLUE}Source:${NC} $SCRIPT_DIR"
echo -e "${BLUE}Target:${NC} $SKILLS_DIR"
echo ""

# Check if Claude Code is available
if command -v claude &>/dev/null; then
    echo -e "${GREEN}✓ Claude Code detected${NC}"
else
    echo -e "${YELLOW}⚠ Claude Code not found in PATH${NC}"
    if [ -t 0 ]; then
        read -p "  Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
    else
        echo "  Continuing (non-interactive mode)..."
    fi
fi

# Create directories
echo -e "\n${BLUE}Creating directories...${NC}"
mkdir -p "$SKILLS_DIR"
mkdir -p "$AGENTS_DIR"

# Install skills (orchestrator + sub-skills, all under skills/)
echo -e "${BLUE}Installing skills...${NC}"
SKILLS=(
    "antwork"
    "antwork-voice"
    "antwork-calendar"
    "antwork-repurpose"
    "antwork-campaign"
    "antwork-ideas"
    "antwork-analytics"
    "antwork-audit"
    "antwork-ship"
)

# Retired in 1.2.0: the MCP server's own instructions cover single posts,
# setup, media and engagement, so these only went stale. Remove copies an
# older install left behind.
for retired in antwork-setup antwork-poster antwork-engage antwork-media; do
    if [ -d "$SKILLS_DIR/$retired" ]; then
        rm -rf "${SKILLS_DIR:?}/$retired"
        echo -e "  ${YELLOW}−${NC} $retired (retired, removed)"
    fi
done

SKILL_COUNT=0
for skill in "${SKILLS[@]}"; do
    if [ -f "$SCRIPT_DIR/skills/$skill/SKILL.md" ]; then
        # The whole folder: since 1.3.0 a skill carries its own templates
        # (and the audit its agents), so the skills CLI gets them too.
        rm -rf "${SKILLS_DIR:?}/$skill"
        cp -R "$SCRIPT_DIR/skills/$skill" "$SKILLS_DIR/$skill"
        echo -e "  ${GREEN}✓${NC} $skill"
        SKILL_COUNT=$((SKILL_COUNT + 1))
    else
        echo -e "  ${YELLOW}⚠${NC} $skill (not found, skipping)"
    fi
done

# Templates live inside the skills that use them since 1.3.0, so the folder
# copy above installed them (and replaced the shared antwork/templates/ that
# older versions created).

# Install agents
echo -e "\n${BLUE}Installing agents...${NC}"
AGENTS=(
    "antwork-performance"
    "antwork-voice-analyst"
    "antwork-cadence"
    "antwork-content"
    "antwork-growth"
)

AGENT_COUNT=0
for agent in "${AGENTS[@]}"; do
    if [ -f "$SCRIPT_DIR/skills/antwork-audit/agents/$agent.md" ]; then
        cp "$SCRIPT_DIR/skills/antwork-audit/agents/$agent.md" "$AGENTS_DIR/$agent.md"
        echo -e "  ${GREEN}✓${NC} $agent"
        AGENT_COUNT=$((AGENT_COUNT + 1))
    else
        echo -e "  ${YELLOW}⚠${NC} $agent (not found, skipping)"
    fi
done

# Cleanup temp directory if used
if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi

# Summary
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           Installation Complete!              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Skills installed:    ${GREEN}$SKILL_COUNT${NC} (incl. orchestrator)"
echo -e "  Agents installed:    ${GREEN}$AGENT_COUNT${NC}"
echo ""
echo -e "${YELLOW}Prerequisite:${NC} connect the Antwork MCP server in Claude — see https://antwork.io"
echo ""
echo -e "${CYAN}Available commands:${NC}"
echo "  /antwork voice [account]     Read an account's voice from its posts"
echo "  /antwork calendar <theme>    Plan & batch-schedule a content calendar"
echo "  /antwork repurpose <source>  One piece → platform-native variants"
echo "  /antwork campaign <goal>     Sequence a multi-post campaign / launch week"
echo "  /antwork ideas [topic]       Data-driven hooks from what performed"
echo "  /antwork analytics [range]   Performance & engagement report"
echo "  /antwork audit               Full social-presence audit (5 parallel agents)"
echo "  /antwork ship                Turn recent commits or a release into posts"
echo "  A single post, connecting an account or adding media: just ask; the connector handles it."
echo ""
echo -e "  ${YELLOW}Start a new Claude Code session to load the skills.${NC}"
echo ""
