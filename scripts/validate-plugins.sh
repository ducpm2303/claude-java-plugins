#!/usr/bin/env bash
# validate-plugins.sh — validates all plugins in the plugins/ directory
# Usage: ./scripts/validate-plugins.sh [plugin-name]
# Exit code: 0 if all pass, 1 if any fail

set -euo pipefail

PLUGINS_DIR="$(cd "$(dirname "$0")/.." && pwd)/plugins"
ERRORS=0
WARNINGS=0

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

error()   { echo -e "${RED}  [ERROR]${NC} $1"; ((ERRORS++)); }
warn()    { echo -e "${YELLOW}  [WARN]${NC}  $1"; ((WARNINGS++)); }
ok()      { echo -e "${GREEN}  [OK]${NC}    $1"; }
section() { echo -e "\n${CYAN}→ $1${NC}"; }

validate_plugin() {
    local plugin_dir="$1"
    local plugin_name
    plugin_name=$(basename "$plugin_dir")

    section "Validating plugin: $plugin_name"

    # 1. plugin.json exists and is valid JSON
    local manifest="$plugin_dir/.claude-plugin/plugin.json"
    if [[ ! -f "$manifest" ]]; then
        error ".claude-plugin/plugin.json not found"
        return
    fi
    if ! jq empty "$manifest" 2>/dev/null; then
        error ".claude-plugin/plugin.json is not valid JSON"
        return
    fi
    ok ".claude-plugin/plugin.json is valid JSON"

    # 2. Required manifest fields
    local name version description
    name=$(jq -r '.name // empty' "$manifest")
    version=$(jq -r '.version // empty' "$manifest")
    description=$(jq -r '.description // empty' "$manifest")

    [[ -z "$name" ]]        && error "plugin.json missing 'name'"        || ok "name: $name"
    [[ -z "$version" ]]     && error "plugin.json missing 'version'"     || ok "version: $version"
    [[ -z "$description" ]] && error "plugin.json missing 'description'" || ok "description present"

    # 3. Validate SKILL.md files
    if [[ -d "$plugin_dir/skills" ]]; then
        local skill_count=0
        while IFS= read -r -d '' skill_file; do
            ((skill_count++))
            local skill_name
            skill_name=$(basename "$(dirname "$skill_file")")

            # Check description frontmatter
            if ! grep -q '^description:' "$skill_file"; then
                error "skills/$skill_name/SKILL.md missing 'description' in frontmatter"
            else
                local desc
                desc=$(grep '^description:' "$skill_file" | head -1)
                # Check for trigger phrases
                if ! echo "$desc" | grep -qi 'use when\|trigger\|asks to'; then
                    warn "skills/$skill_name/SKILL.md description has no trigger phrases ('Use when user asks to...')"
                else
                    ok "skills/$skill_name — description OK"
                fi
            fi
        done < <(find "$plugin_dir/skills" -name "SKILL.md" -print0 2>/dev/null)
        ok "$skill_count skill(s) found"
    else
        warn "No skills/ directory"
    fi

    # 4. Validate commands/*.md
    if [[ -d "$plugin_dir/commands" ]]; then
        local cmd_count=0
        while IFS= read -r -d '' cmd_file; do
            ((cmd_count++))
            local cmd_name
            cmd_name=$(basename "$cmd_file" .md)
            if ! grep -q '^description:' "$cmd_file"; then
                error "commands/$cmd_name.md missing 'description' in frontmatter"
            else
                ok "commands/$cmd_name — description OK"
            fi
        done < <(find "$plugin_dir/commands" -name "*.md" -print0 2>/dev/null)
        ok "$cmd_count command(s) found"
    fi

    # 5. Validate rules/*.md — must have globs frontmatter
    if [[ -d "$plugin_dir/rules" ]]; then
        local rule_count=0
        while IFS= read -r -d '' rule_file; do
            ((rule_count++))
            local rule_name
            rule_name=$(basename "$rule_file" .md)
            if ! grep -q '^globs:' "$rule_file"; then
                error "rules/$rule_name.md missing 'globs:' frontmatter"
            else
                ok "rules/$rule_name — globs OK"
            fi
        done < <(find "$plugin_dir/rules" -name "*.md" -print0 2>/dev/null)
        ok "$rule_count rule file(s) found"
    fi

    # 6. Validate hooks/hooks.json
    if [[ -f "$plugin_dir/hooks/hooks.json" ]]; then
        if ! jq empty "$plugin_dir/hooks/hooks.json" 2>/dev/null; then
            error "hooks/hooks.json is not valid JSON"
        else
            ok "hooks/hooks.json is valid JSON"
        fi
    fi

    # 7. Agents have a description in frontmatter
    if [[ -d "$plugin_dir/agents" ]]; then
        local agent_count=0
        while IFS= read -r -d '' agent_file; do
            ((agent_count++))
            local agent_name
            agent_name=$(basename "$agent_file" .md)
            if ! grep -q '^description:' "$agent_file"; then
                warn "agents/$agent_name.md missing 'description' in frontmatter"
            else
                ok "agents/$agent_name — description OK"
            fi
        done < <(find "$plugin_dir/agents" -name "*.md" -print0 2>/dev/null)
        ok "$agent_count agent(s) found"
    fi
}

# Validate marketplace.json
section "Validating marketplace"
marketplace=".claude-plugin/marketplace.json"
if [[ -f "$marketplace" ]]; then
    if jq empty "$marketplace" 2>/dev/null; then
        ok "marketplace.json is valid JSON"
        plugin_count=$(jq '.plugins | length' "$marketplace")
        ok "$plugin_count plugin(s) listed in marketplace"
    else
        error "marketplace.json is not valid JSON"
    fi
else
    warn "No marketplace.json found"
fi

# Run validation on each plugin
if [[ "${1:-}" != "" ]]; then
    # Validate specific plugin
    if [[ -d "$PLUGINS_DIR/$1" ]]; then
        validate_plugin "$PLUGINS_DIR/$1"
    else
        echo "Plugin not found: $1"
        exit 1
    fi
else
    # Validate all plugins
    for plugin_dir in "$PLUGINS_DIR"/*/; do
        [[ -d "$plugin_dir" ]] && validate_plugin "$plugin_dir"
    done
fi

# Summary
echo ""
echo "══════════════════════════════════════"
if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}FAILED — $ERRORS error(s), $WARNINGS warning(s)${NC}"
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}PASSED with $WARNINGS warning(s)${NC}"
else
    echo -e "${GREEN}ALL CHECKS PASSED${NC}"
fi
echo "══════════════════════════════════════"
