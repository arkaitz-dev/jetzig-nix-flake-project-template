#!/usr/bin/env bash

# Development server with automatic asset rebuilding
# Combines Jetzig hot reload with esbuild asset watching

set -euo pipefail

echo "🚀 Starting Jetzig Development Server with Asset Watching"
echo ""

# Trap to cleanup background processes on exit
cleanup() {
    echo ""
    echo "🛑 Stopping development server..."
    jobs -p | xargs -r kill
    exit 0
}
trap cleanup SIGINT SIGTERM

# Step 1: Initial asset build
echo "📦 Building initial assets..."
bash .claude/build-assets-dev.sh

# Step 2: Start asset watching in background
echo "👀 Starting asset watcher..."
bash build-assets-dev.sh --watch &
ASSET_WATCHER_PID=$!

# Give asset watcher a moment to start
sleep 2

# Step 3: Start Jetzig server (foreground)
echo "🔥 Starting Jetzig server with hot reload..."
echo "   - Zig/Zmpl changes: Automatic reload via Jetzig"
echo "   - JS/CSS changes: Automatic rebuild via esbuild"
echo "   - Press Ctrl+C to stop both services"
echo ""

jetzig server

# This line should never be reached due to trap, but just in case
cleanup
