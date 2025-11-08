#!/bin/bash

PROJECT_DIR="$HOME/xau-sentinel"
cd "$PROJECT_DIR" || { echo "❌ Folder project tidak ditemukan"; exit 1; }

echo "🔄 Menarik update terbaru dari GitHub..."
git pull --rebase

# Cek perubahan
if git diff --quiet && git diff --cached --quiet; then
  echo "⚠️ Tidak ada perubahan untuk di-commit."
  exit 0
fi

echo "✅ Menambahkan perubahan..."
git add .

echo "✅ Commit otomatis..."
git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"

echo "🚀 Push ke GitHub..."
git push origin main

echo "✅ Sinkronisasi GitHub selesai!"
