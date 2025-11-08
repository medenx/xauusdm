#!/bin/bash
ROOT="$HOME/xau-sentinel"
LOG="$ROOT/.entry.log"

while true; do
  bash "$ROOT/entry-alert.sh"
  sleep 60  # cek tiap 1 menit
done
