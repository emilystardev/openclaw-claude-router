#!/bin/bash

PIDFILE="$HOME/.claude-code-router/proxy.pid"

if [ -f "$PIDFILE" ]; then
  PID=$(cat "$PIDFILE")
  if ps -p "$PID" > /dev/null 2>&1; then
    echo "✅ Status: RUNNING (PID: $PID)"
    ps -p "$PID" -o pid,pcpu,pmem,etime --no-headers 2>/dev/null
    lsof -i:3456 -t 2>/dev/null | grep -q . && echo "📡 Port 3456: listening"
    LOG_SIZE=$(stat -c%s "$HOME/.claude-code-router/proxy.log" 2>/dev/null)
    [ -n "$LOG_SIZE" ] && echo "📝 Log: $((LOG_SIZE / 1024)) KB"
    echo ""
    echo "Stop:    bash stop.sh"
    echo "Logs:    tail -f ~/.claude-code-router/proxy.log"
  else
    echo "⚠️  Stale PID file. Cleaning up."
    rm -f "$PIDFILE"
    echo "To start: bash start.sh"
  fi
else
  echo "❌ Not running"
  lsof -i:3456 -t 2>/dev/null | grep -q . && echo "⚠️  Something else is on port 3456"
  echo "To start: bash start.sh"
fi
