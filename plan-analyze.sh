#!/bin/bash

ROOT="$HOME/xau-sentinel"
PLAN_DIR="$ROOT/plans"
ANALYZE_DIR="$ROOT/analyses"
ENV="$ROOT/.env"
SEND="$ROOT/tg-send.sh"
LOG="$ROOT/.plan.log"

mkdir -p "$PLAN_DIR" "$ANALYZE_DIR"

DATE=$(date +%F)
PLAN_FILE="$PLAN_DIR/$DATE.md"
ANALYZE_FILE="$ANALYZE_DIR/$DATE.md"

log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG"; }

# 1. Cek / buat plan jika belum ada
if [ ! -f "$PLAN_FILE" ]; then
  sed "s/YYYY-MM-DD/$DATE/" "$ROOT/plan-template.md" > "$PLAN_FILE"
  log "Plan dibuat otomatis: $PLAN_FILE"
else
  log "Plan ditemukan: $PLAN_FILE"
fi

# 2. Ambil data dari plan
get_field() {
  awk -v KEY="$1" 'BEGIN{IGNORECASE=1} 
  $0 ~ "^"KEY"[[:space:]]*:" {sub("^[^:]*:[[:space:]]*", "", $0); print; exit}' "$PLAN_FILE"
}

BIAS=$(get_field "Bias")
HTF=$(get_field "HTF")
KEYLVL=$(get_field "Key Level")
LIQ=$(get_field "Liquidity")
ENTRY=$(get_field "Entry Model")
SESS=$(get_field "Session Fokus")
INVAL=$(get_field "Invalidation")

# 3. Default jika kosong
[ -z "$BIAS" ] && BIAS="(isi Bias)"
[ -z "$HTF" ] && HTF="(isi struktur H4/H1)"
[ -z "$KEYLVL" ] && KEYLVL="(isi level)"
[ -z "$LIQ" ] && LIQ="(isi liquidity)"
[ -z "$ENTRY" ] && ENTRY="(isi entry model)"
[ -z "$SESS" ] && SESS="(isi sesi)"
[ -z "$INVAL" ] && INVAL="(isi invalidation)"

# 4. Analisis otomatis berdasarkan bias dan struktur
bias_lower=$(echo "$BIAS" | tr '[:upper:]' '[:lower:]')
if echo "$bias_lower" | grep -qi "bear"; then
  DIRECTION="Bias: BEARISH"
  STRATEGY="Tunggu harga ke PREMIUM, cari sweep BuySide Liquidity lalu konfirmasi FVG/OB untuk sell."
else
  DIRECTION="Bias: BULLISH"
  STRATEGY="Tunggu harga ke DISCOUNT, cari sweep SellSide Liquidity lalu konfirmasi FVG/OB untuk buy."
fi

read -r -d '' WARNING << 'WAR'
==================== WARNING ====================
- Hindari entry tanpa konfirmasi M5/M1
- Waspada MSS palsu tanpa retest OB/FVG
- Jangan entry di equilibrium; tunggu premium/discount
- Perhatikan apakah sweep atau breakout (candlestick close)
- Hindari entry Asia kecuali ada sweep + konfirmasi
- Rutin catat jurnal setelah entry
=================================================
WAR

# 5. Susun hasil analisis
cat > "$ANALYZE_FILE" << EOF2
🔎 ANALISIS TRADING PLAN ($DATE)

$DIRECTION
Struktur HTF: $HTF
Key Level: $KEYLVL
Liquidity: $LIQ
Entry Model: $ENTRY
Session Fokus: $SESS
Invalidation: $INVAL

Strategi:
$STRATEGY

$WARNING
EOF2

log "Analisis tersimpan: $ANALYZE_FILE"

# 6. Kirim ke Telegram kalau bot aktif
if [ -f "$ENV" ] && [ -x "$SEND" ]; then
  bash "$SEND" "$(cat "$ANALYZE_FILE")" >/dev/null 2>&1 && log "✅ Terkirim ke Telegram"
else
  log "⚠️ Telegram tidak dikirim (token/chat ID tidak ditemukan)"
fi

# 7. Commit & push GitHub
git -C "$ROOT" add "$ANALYZE_FILE" >/dev/null 2>&1
git -C "$ROOT" commit -m "Analysis $DATE" >/dev/null 2>&1 || true
git -C "$ROOT" push origin main >/dev/null 2>&1 && log "✅ Push ke GitHub" || log "⚠️ Push gagal"

