#!/bin/bash
set -euo pipefail

ROOT="$HOME/xau-sentinel"
ENV="$ROOT/.env"
LOG="$ROOT/.entry.log"
STATE="$ROOT/.entry.state"          # simpan status per-level
PLAN="$ROOT/plans/$(date +%F).md"   # ambil Key Level dari plan harian
DATE="$(date '+%Y-%m-%d %H:%M:%S')"

# ===== USER SETTINGS =====
PAIR="XAUUSD"
THRESH=1.00            # ambang trigger USD
COOLDOWN_MIN=15        # jeda alert per level (menit)
MIN_MOVE=0.10          # minimal pergerakan sejak alert terakhir agar tidak spam
RISK_BALANCE=100       # modal (USD)
RISK_PERCENT=1         # risiko per entry (%)
STOPLOSS=20            # SL (USD poin)
TP=40                  # TP (USD poin)
SKIP_ASIA=1            # 1=hindari sesi Asia (23:00–07:00 WIB) kecuali ada trigger manual
# =========================

source "$ENV" 2>/dev/null || true
touch "$STATE"

# Sesi filter (WIB)
HOUR=$(date +%H)
if [ "$SKIP_ASIA" -eq 1 ] && { [ "$HOUR" -ge 23 ] || [ "$HOUR" -lt 7 ]; }; then
  echo "[$DATE] ⏸ Skip sesi Asia (anti overtrading)" >> "$LOG"
  exit 0
fi

# Harga dari proxy
PRICE=$(curl -s http://localhost:3000/xau | grep -o '"price":[0-9]*\.[0-9]*' | cut -d':' -f2)
if [ -z "$PRICE" ]; then
  echo "[$DATE] ❌ Gagal ambil harga dari Proxy" >> "$LOG"
  exit 0
fi

# Key Level dari plan; fallback
readarray -t LEVELS < <(grep -i "Key Level" "$PLAN" 2>/dev/null \
  | head -1 | cut -d':' -f2- | tr -d ' ' | tr ',' ' ')
if [ ${#LEVELS[@]} -eq 0 ]; then LEVELS=(4010 4000 3990); fi

echo "[$DATE] 🔍 Cek $PAIR | $PRICE | Levels: ${LEVELS[*]}" >> "$LOG"

get_state(){ grep -m1 "^$1|" "$STATE" || true; }
set_state(){
  local level="$1" when="$2" side="$3" lastp="$4"
  # hapus lama, tulis baru
  grep -v "^$level|" "$STATE" > "$STATE.tmp" 2>/dev/null || true
  mv "$STATE.tmp" "$STATE"
  echo "$level|$when|$side|$lastp" >> "$STATE"
}

for LEVEL in "${LEVELS[@]}"; do
  DIFF=$(echo "scale=4; $PRICE - $LEVEL" | bc -l)
  ABS=$(echo "${DIFF#-}")

  # hanya jika dekat level
  if (( $(echo "$ABS <= $THRESH" | bc -l) )); then
    # arah sinyal
    if (( $(echo "$PRICE >= $LEVEL" | bc -l) )); then
      SIGNAL="SELL"
      SL_LEVEL=$(echo "scale=2; $PRICE + $STOPLOSS" | bc -l)
      TP_LEVEL=$(echo "scale=2; $PRICE - $TP" | bc -l)
    else
      SIGNAL="BUY"
      SL_LEVEL=$(echo "scale=2; $PRICE - $STOPLOSS" | bc -l)
      TP_LEVEL=$(echo "scale=2; $PRICE + $TP" | bc -l)
    fi

    NOWS=$(date +%s)
    ST=$(get_state "$LEVEL")
    LAST_TS=0; LAST_SIDE=""; LAST_PRICE=""
    if [ -n "$ST" ]; then IFS='|' read -r _L LAST_TS LAST_SIDE LAST_PRICE <<< "$ST"; fi
    ELAPSE_MIN=$(( LAST_TS>0 ? ( (NOWS - LAST_TS)/60 ) : (COOLDOWN_MIN+1) ))

    # anti-duplikasi: butuh perubahan MIN_MOVE atau arah berubah, atau cooldown habis
    PRICE_DIFF_OK=1
    if [ -n "$LAST_PRICE" ]; then
      PD=$(echo "scale=4; $PRICE - $LAST_PRICE" | bc -l)
      APD=$(echo "${PD#-}")
      if (( $(echo "$APD < $MIN_MOVE" | bc -l) )); then PRICE_DIFF_OK=0; fi
    fi

    if [ "$ELAPSE_MIN" -lt "$COOLDOWN_MIN" ] && [ "$LAST_SIDE" = "$SIGNAL" ] && [ "$PRICE_DIFF_OK" -eq 0 ]; then
      echo "[$DATE] ⏳ Skip $LEVEL ($SIGNAL) — cooldown ${ELAPSE_MIN}/${COOLDOWN_MIN}m & move<$MIN_MOVE" >> "$LOG"
      continue
    fi

    # Risk & lot
    LOSS_PER_TRADE=$(echo "scale=2; $RISK_BALANCE * $RISK_PERCENT / 100" | bc -l)
    LOT_SIZE=$(echo "scale=2; $LOSS_PER_TRADE / $STOPLOSS" | bc -l)

    MSG="⚠️ *ENTRY SIGNAL*
Pair: $PAIR
Key Level: $LEVEL
Harga: $PRICE
Arah: *$SIGNAL*
Selisih: $ABS (≤ $THRESH)

SL: $SL_LEVEL
TP: $TP_LEVEL
Risk: ${RISK_PERCENT}% (≈ \$${LOSS_PER_TRADE})
Lot: ${LOT_SIZE}

*CHECK M5/M1*
- BOS valid
- Retest FVG/OB
- Sweep vs breakout (close candle)
- Hindari equilibrium"

    if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ]; then
      curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d parse_mode="Markdown" \
        --data-urlencode text="$MSG" >/dev/null \
        && echo "[$DATE] 📩 Entry $LEVEL | $SIGNAL (ELAPSE ${ELAPSE_MIN}m)" >> "$LOG"
    else
      echo "[$DATE] ⚠️ Token/Chat ID kosong — kirim dibatalkan" >> "$LOG"
    fi

    set_state "$LEVEL" "$NOWS" "$SIGNAL" "$PRICE"
  fi
done

# Rotate log sederhana (>100KB)
[ -f "$LOG" ] && [ "$(wc -c < "$LOG")" -gt 102400 ] && mv "$LOG" "$LOG.$(date +%H%M%S)"
