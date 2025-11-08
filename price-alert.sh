#!/bin/bash
ROOT="$HOME/xau-sentinel"
PLAN="$ROOT/plans/$(date +%F).md"
LOG="$ROOT/.price.log"

log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG"; }

# ✅ Ambil harga XAU/USD via finviz (tanpa HTTPS)
get_price() {
  curl -s http://finviz.com/fut_chart.ashx?t=GC | \
  grep -o "last\":[0-9]*\.[0-9]*" | head -1 | cut -d':' -f2
}

# ✅ Ambil Key Level dari Trading Plan
get_key_levels() {
  grep -i "Key Level" "$PLAN" | cut -d':' -f2- | tr -d ' ' | tr '/' ' ' | tr ',' ' '
}

log "=== PRICE ALERT STARTED ($(date)) ==="

while true; do
  PRICE=$(get_price)

  if [ -z "$PRICE" ]; then
    log "⚠️ Gagal ambil harga dari Finviz (non-SSL)"
    sleep 60
    continue
  fi

  log "✅ Harga XAUUSD sekarang: $PRICE"

  LEVELS=$(get_key_levels)

  for LEVEL in $LEVELS; do
    DIFF=$(echo "$PRICE - $LEVEL" | bc)
    ABS_DIFF="${DIFF#-}"

    if (( $(echo "$ABS_DIFF < 0.50" | bc -l) )); then
      source "$ROOT/.env"
      MSG="⚠️ XAUUSD mendekati Key Level $LEVEL
Harga saat ini: $PRICE
Cek potensi sweep atau rejection."

      curl -s -X POST "http://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        --data-urlencode text="$MSG" >/dev/null

      log "📨 ALERT DIKIRIM: Level=$LEVEL | Price=$PRICE"
    fi
  done

  sleep 60
done
