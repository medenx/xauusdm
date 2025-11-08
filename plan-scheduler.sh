#!/bin/bash
PROJECT="$HOME/xau-sentinel"
TIME_TARGET="06:30"

while true; do
  NOW=$(date +%H:%M)
  if [ "$NOW" == "$TIME_TARGET" ]; then
    echo "[⏰ $(date '+%F %H:%M:%S')] Menjalankan plan-analyze.sh..."
    bash "$PROJECT/plan-analyze.sh"

    sleep 60  # supaya tidak eksekusi berkali-kali di menit sama
  fi
  sleep 20    # cek setiap 20 detik
done
