#!/bin/bash
SESSION="xau-sentinel"
cd ~/xau-sentinel || exit 1

if tmux has-session -t $SESSION 2>/dev/null; then
  echo "⚙️ Session sudah aktif."
else
  echo "🚀 Membuat session baru: $SESSION"
  tmux new-session -d -s $SESSION "
    node server.js >> server.log 2>&1 &
    bash price-alert.sh >> .price.log 2>&1 &
    bash entry-auto.sh >> .entry.log 2>&1 &
    node bot.js >> bot.log 2>&1
  "
  echo "✅ Semua service dijalankan di tmux: $SESSION"
fi
