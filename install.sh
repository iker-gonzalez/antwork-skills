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
echo -e "${CYAN}║   12 Skills · 5 Agents · 5 Templates         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Detect script directory (support remote curl|bash install)
if [ -n "$BASH_SOURCE" ] && [ "$BASH_SOURCE" != "bash" ] && [ -f "$BASH_SOURCE" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
else
    echo -e "${YELLOW}Running remote install — cloning repository...${NC}"
    TEMP_DIR=$(mktemp -d)
    git clone --depth 1 https://github.com/iker-gonzalez/antwork-skills.git "$TEMP_DIR/antwork-skills" 2>/dev/null
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

SKILL_COUNT=0
for skill in "${SKILLS[@]}"; do
    if [ -f "$SCRIPT_DIR/skills/$skill/SKILL.md" ]; then
        mkdir -p "$SKILLS_DIR/$skill"
        cp "$SCRIPT_DIR/skills/$skill/SKILL.md" "$SKILLS_DIR/$skill/SKILL.md"
        echo -e "  ${GREEN}✓${NC} $skill"
        SKILL_COUNT=$((SKILL_COUNT + 1))
    else
        echo -e "  ${YELLOW}⚠${NC} $skill (not found, skipping)"
    fi
done

# Copy templates alongside the orchestrator so skills can reference them
echo -e "\n${BLUE}Installing templates...${NC}"
TEMPLATES_TARGET="$SKILLS_DIR/antwork/templates"
mkdir -p "$TEMPLATES_TARGET"

TEMPLATE_COUNT=0
if [ -d "$SCRIPT_DIR/templates" ]; then
    for template in "$SCRIPT_DIR/templates"/*.md; do
        if [ -f "$template" ]; then
            cp "$template" "$TEMPLATES_TARGET/$(basename "$template")"
            echo -e "  ${GREEN}✓${NC} $(basename "$template")"
            TEMPLATE_COUNT=$((TEMPLATE_COUNT + 1))
        fi
    done
fi

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
    if [ -f "$SCRIPT_DIR/agents/$agent.md" ]; then
        cp "$SCRIPT_DIR/agents/$agent.md" "$AGENTS_DIR/$agent.md"
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
echo -e "  Templates installed: ${GREEN}$TEMPLATE_COUNT${NC}"
echo ""
echo -e "${YELLOW}Prerequisite:${NC} connect the Antwork MCP server in Claude — see https://antwork.io"
echo ""
echo -e "${CYAN}Available commands:${NC}"
echo "  /antwork setup               Connect accounts, set timezone & posting times"
echo "  /antwork voice [account]     Build/refresh a per-account voice profile"
echo "  /antwork post <idea>         Draft → schedule/publish a post"
echo "  /antwork calendar <theme>    Plan & batch-schedule a content calendar"
echo "  /antwork repurpose <source>  One piece → platform-native variants"
echo "  /antwork campaign <goal>     Sequence a multi-post campaign / launch week"
echo "  /antwork ideas [topic]       Data-driven hooks from what performed"
echo "  /antwork analytics [range]   Performance & engagement report"
echo "  /antwork engage              Comments, replies, retry failed posts"
echo "  /antwork media               Upload & attach post media"
echo "  /antwork audit               Full social-presence audit (5 parallel agents)"
echo ""
echo -e "  ${YELLOW}Start a new Claude Code session to load the skills.${NC}"
echo ""
