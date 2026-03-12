#!/bin/bash

# Claude Code Router - Start proxy

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIDFILE="$HOME/.claude-code-router/proxy.pid"
LOGFILE="$HOME/.claude-code-router/proxy.log"

# Load .env if present
if [ -f "$SCRIPT_DIR/.env" ]; then
  set -a
  source "$SCRIPT_DIR/.env"
  set +a
fi

if [ -z "$OPENROUTER_API_KEY" ]; then
  echo "❌ OPENROUTER_API_KEY is not set."
  echo "   Copy .env.example to .env and add your key."
  exit 1
fi

# Check if already running
if [ -f "$PIDFILE" ]; then
  PID=$(cat "$PIDFILE")
  if ps -p "$PID" > /dev/null 2>&1; then
    echo "❌ Proxy is already running (PID: $PID)"
    echo "   Stop it first with: bash stop.sh"
    exit 1
  else
    rm -f "$PIDFILE"
  fi
fi

# Kill any leftover process on the port
PORT_IN_USE=$(lsof -t -i:3456 2>/dev/null)
if [ -n "$PORT_IN_USE" ]; then
  echo "⚠️  Killing process on port 3456 (PID: $PORT_IN_USE)"
  kill -9 "$PORT_IN_USE" 2>/dev/null
  sleep 1
fi

mkdir -p "$(dirname "$LOGFILE")"

echo "🚀 Starting Claude Code Router..."
nohup node "$SCRIPT_DIR/proxy.js" > "$LOGFILE" 2>&1 &
PROXY_PID=$!
echo "$PROXY_PID" > "$PIDFILE"

sleep 2

if ps -p "$PROXY_PID" > /dev/null 2>&1; then
  echo "✅ Proxy started (PID: $PROXY_PID)"
  echo ""
  echo "🔧 To use with Claude Code:"
  echo "   export ANTHROPIC_API_KEY=\"any-string-is-ok\""
  echo "   export ANTHROPIC_BASE_URL=\"http://127.0.0.1:3456\""
  echo "   claude"
else
  echo "❌ Failed to start. Check logs: $LOGFILE"
  rm -f "$PIDFILE"
  exit 1
fi
