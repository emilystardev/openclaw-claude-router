#!/bin/bash

PIDFILE="$HOME/.claude-code-router/proxy.pid"
LOGFILE="$HOME/.claude-code-router/proxy.log"

if [ ! -f "$PIDFILE" ]; then
  echo "⚠️  No PID file found. Checking port 3456..."
  PORT_PROCS=$(lsof -t -i:3456 2>/dev/null)
  if [ -n "$PORT_PROCS" ]; then
    kill -9 $PORT_PROCS 2>/dev/null
    echo "✅ Killed processes on port 3456"
  fi
  exit 0
fi

PID=$(cat "$PIDFILE")

if ! ps -p "$PID" > /dev/null 2>&1; then
  echo "⚠️  Stale PID file. Cleaning up."
  rm -f "$PIDFILE"
  exit 0
fi

echo "🛑 Stopping proxy (PID: $PID)..."
kill "$PID" 2>/dev/null
sleep 1

if ps -p "$PID" > /dev/null 2>&1; then
  kill -9 "$PID" 2>/dev/null
  sleep 1
fi

rm -f "$PIDFILE"
echo "✅ Stopped"
echo ""
tail -5 "$LOGFILE" 2>/dev/null
