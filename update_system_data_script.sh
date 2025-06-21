#!/usr/bin/env bash

# System data management script for Claude Code
# Creates and maintains .claude/system-data.yaml with current environment information

set -euo pipefail

CLAUDE_DIR=".claude"
SYSTEM_DATA_FILE="$CLAUDE_DIR/system-data.yaml"

# Function to update system data
update_system_data() {
    cat > "$SYSTEM_DATA_FILE" << EOF
LANG: ${LANG:-unknown}
WORKDIR: $(pwd)
ZIG_VERSION: $(zig version 2>/dev/null || echo 'unknown')
JETZIG_VERSION: $(jetzig --version 2>/dev/null || echo 'unknown')
LAST_VERIFICATION_DATE: $(date +%Y-%m-%d)
EOF
    echo "✅ System data updated: $SYSTEM_DATA_FILE"
}

# Check if file exists and if verification is needed
if [ ! -f "$SYSTEM_DATA_FILE" ]; then
    echo "📋 Creating system data file..."
    update_system_data
else
    LAST_DATE=$(grep "LAST_VERIFICATION_DATE:" "$SYSTEM_DATA_FILE" | cut -d' ' -f2 2>/dev/null || echo "")
    TODAY=$(date +%Y-%m-%d)
    
    if [ "$LAST_DATE" != "$TODAY" ]; then
        echo "🔄 Updating system data (last verification: $LAST_DATE, today: $TODAY)"
        update_system_data
    else
        echo "✅ System data is current (verified: $TODAY)"
    fi
fi

# Display current configuration
echo ""
echo "📊 Current system configuration:"
cat "$SYSTEM_DATA_FILE"