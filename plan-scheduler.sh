#!/bin/bash
ROOT="$HOME/xau-sentinel"
TARGET="06:30"

while true; do
  NOW=$(date +%H:%M)
  if [ "$NOW" = "$TARGET" ]; then
    bash "$ROOT/plan-analyze.sh"
    sleep 60
  fi
  sleep 20
done
