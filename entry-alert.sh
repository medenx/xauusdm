#!/bin/bash

ROOT="$HOME/xau-sentinel"
ENV="$ROOT/.env"
LOG="$ROOT/.entry.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

source "$ENV"

# === SETTINGS TRADING ALERT ===
PAIR="XAUUSD"
LEVELS=(4010 4000 3990)    # Key Level — bisa otomatis dari file plan
THRESH=1.00                # Selisih trigger alert
RISK_BALANCE=100           # Modal akun
RISK_PERCENT=1             # Risiko per entry = 1%
STOPLOSS=20                # SL default (pip) ← ✅ diperbaiki (bukan OPLOSS)
TP=40                      # TP default (pip)

# === AMBIL HARGA DARI PROXY ===
PRICE=$(curl -s http://localhost:3000/xau | grep -o '"price":[0-9]*\.[0-9]*' | cut -d':' -f2)

if [ -z "$PRICE" ]; then
  echo "[$DATE] ❌ Gagal ambil harga dari Proxy" | tee -a "$LOG"
  exit 1
fi

echo "[$DATE] 🔍 Cek harga $PAIR | $PRICE" | tee -a "$LOG"

for LEVEL in "${LEVELS[@]}"; do
  DIFF=$(echo "scale=2; $PRICE-$LEVEL" | bc -l)
  ABS_DIFF=$(echo "${DIFF#-}")

  if (( $(echo "$ABS_DIFF <= $THRESH" | bc -l) )); then
    if (( $(echo "$PRICE >= $LEVEL" | bc -l) )); then
      SIGNAL="SELL"
      SL_LEVEL=$(echo "$PRICE + $STOPLOSS" | bc)
      TP_LEVEL=$(echo "$PRICE - $TP" | bc)
    else
      SIGNAL="BUY"
      SL_LEVEL=$(echo "$PRICE - $STOPLOSS" | bc)
      TP_LEVEL=$(echo "$PRICE + $TP" | bc)
    fi

    LOSS_PER_TRADE=$(echo "$RISK_BALANCE * $RISK_PERCENT / 100" | bc)
    LOT_SIZE=$(echo "scale=2; $LOSS_PER_TRADE / $STOPLOSS" | bc)

    MSG="⚠️ *ENTRY SIGNAL TERDETEKSI*
Pair: $PAIR
Key Level: $LEVEL
Harga Sekarang: $PRICE
Arah: *$SIGNAL*

SL: $SL_LEVEL
TP: $TP_LEVEL
Risk: ${RISK_PERCENT}% (≈ \$${LOSS_PER_TRADE})
Lot Size: ${LOT_SIZE} lot

⚠ Konfirmasi di M5/M1:
- BOS terkonfirmasi?
- Ada FVG / OB retest?
- Sweep liquidity jelas?"

    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
      -d chat_id="$TELEGRAM_CHAT_ID" \
      -d parse_mode="Markdown" \
      --data-urlencode text="$MSG" >/dev/null

    echo "[$DATE] 📩 Alert Entry terkirim ($LEVEL | $SIGNAL)" | tee -a "$LOG"
  fi
done
