#!/bin/bash
ROOT="$HOME/xau-sentinel"
PLAN="$ROOT/plans/$(date +%F).md"
ANALYZE="$ROOT/analyses/$(date +%F).md"
mkdir -p "$ROOT/plans" "$ROOT/analyses"

log(){ echo "[$(date '+%H:%M:%S')] $1"; }

# 1. Plan cek / buat
if [ ! -f "$PLAN" ]; then
  cp "$ROOT/plan-template.md" "$PLAN"
  sed -i "s/YYYY-MM-DD/$(date +%F)/" "$PLAN"
  log "⚠ Plan dibuat dari template"
else
  log "✅ Plan ditemukan: $PLAN"
fi

# 2. Extract data plan
BIAS=$(grep -i "Bias:" "$PLAN" | cut -d':' -f2- | xargs)
HTF=$(grep -i "HTF" "$PLAN" | cut -d':' -f2- | xargs)
KEY=$(grep -i "Key Level" "$PLAN" | cut -d':' -f2- | xargs)
LIQ=$(grep -i "Liq" "$PLAN" | cut -d':' -f2- | xargs)
ENTRY=$(grep -i "Entry" "$PLAN" | cut -d':' -f2- | xargs)

[ -z "$BIAS" ] && BIAS="(isi Bias)"
[ -z "$HTF" ] && HTF="(isi Struktur H4/H1)"
[ -z "$KEY" ] && KEY="(isi Key Level)"
[ -z "$LIQ" ] && LIQ="(isi Liquidity)"
[ -z "$ENTRY" ] && ENTRY="(isi Entry Model)"

if echo "$BIAS" | grep -qi "bear"; then
  DIR="Bias: BEARISH"
  STRAT="Tunggu PREMIUM → sweep Buyside Liquidity → konfirmasi FVG/OB → SELL."
else
  DIR="Bias: BULLISH"
  STRAT="Tunggu DISCOUNT → sweep Sellside Liquidity → konfirmasi FVG/OB → BUY."
fi

read -r -d '' WARNING << 'WAR'
==================== WARNING ====================
- Hindari entry tanpa konfirmasi M5/M1
- Waspada MSS palsu tanpa retest OB/FVG
- Jangan entry di equilibrium (premium/discount)
- Sweep vs breakout pastikan candle close
- Hindari entry Asia tanpa sweep + konfirmasi
- Wajib catat jurnal setelah entry
=================================================
WAR

cat > "$ANALYZE" << EOF2
🔎 ANALISIS TRADING PLAN ($(date +%F))

$DIR
Struktur HTF: $HTF
Key Level: $KEY
Liquidity: $LIQ
Entry Model: $ENTRY

Strategi:
$STRAT

$WARNING
EOF2

log "✅ Analisis tersimpan: $ANALYZE"

# Kirim Telegram
if [ -f "$ROOT/.env" ]; then
  source "$ROOT/.env"
  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
    -d chat_id="$TELEGRAM_CHAT_ID" \
    --data-urlencode text@"$ANALYZE" >/dev/null 2>&1 \
    && log "📨 Terkirim ke Telegram" \
    || log "⚠ Gagal kirim Telegram"
fi

# Git push (tanpa error jika tidak ada perubahan)
git -C "$ROOT" add "$ANALYZE" >/dev/null 2>&1
if git -C "$ROOT" commit -m "Analysis $(date +%F-%H:%M:%S)" >/dev/null 2>&1; then
  git -C "$ROOT" push origin main >/dev/null 2>&1 && log "✅ Push GitHub" || log "⚠ Push GitHub gagal"
else
  log "ℹ Tidak ada perubahan baru — skip push"
fi
