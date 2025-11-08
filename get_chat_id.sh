#!/bin/bash
source ~/xau-sentinel/.env

echo "Silakan chat bot kamu (@medenx_bot), lalu jalankan script ini lagi."
curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getUpdates" | grep -o '"chat":{"id":[0-9]*' | head -1
