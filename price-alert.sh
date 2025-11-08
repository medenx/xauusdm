#!/bin/bash
ROOT="$HOME/xau-sentinel"
PLAN="$ROOT/plans/$(date +%F).md"
LOG="$ROOT/.price.log"

# Ambil harga dari TradingView
get_price() {
  curl -s "https://api.tradingview.com/markets/quotes?symbols=OANDA:XAUUSD" \
  | grep -o '"lp":[0-9]*\.[0-9]*' | head -1 | cut -d: -f2
}

# Ambil key level dari trading plan
get_key_levels() {
  grep -i "Key Level" "$PLAN" | cut -d':' -f2- | tr -d ' ' | tr '/' ' '
}

log(){ echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG"; }

log "=== PRICE ALERT STARTED ($(date)) ==="

while true; do
  PRICE=$(get_price)

  if [ -z "$PRICE" ]; then
    log "⚠️ Gagal ambil harga (TradingView tidak merespon)"
    sleep 60
    continue
  fi

  LEVELS=$(get_key_levels)

  for LEVEL in $LEVELS; do
    DIFF=$(echo "$PRICE - $LEVEL" | bc)
    ABS_DIFF=$(echo "${DIFF#-}")

    if (( $(echo "$ABS_DIFF < 0.50" | bc -l) )); then
      source "$ROOT/.env"
      MSG="⚠️ XAUUSD dekat Key Level $LEVEL
Harga saat ini: $PRICE
Cek kemungkinan sweep atau rejection."
      
      curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        --data-urlencode text="$MSG" >/dev/null

      log "📨 ALERT DIKIRIM: Level $LEVEL, Price $PRICE"
    fi
  done

  sleep 60
done
