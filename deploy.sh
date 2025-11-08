#!/bin/bash

PROJECT_DIR="$HOME/xau-sentinel"
cd "$PROJECT_DIR" || { echo "❌ Folder project tidak ditemukan"; exit 1; }

echo "✅ Cek perubahan lokal sebelum pull..."

# Kalau ada perubahan yang belum di-commit → langsung commit dulu
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "📌 Perubahan lokal terdeteksi → commit dulu sebelum pull"
  git add .
  git commit -m "Auto-commit sebelum pull: $(date '+%Y-%m-%d %H:%M:%S')"
fi

echo "🔄 Menarik update dari GitHub (git pull --rebase)..."
git pull --rebase || { echo "⚠️ Gagal git pull, cek konflik!"; exit 1; }

# Cek ulang apakah ada perubahan baru setelah pull
if git diff --quiet && git diff --cached --quiet; then
  echo "⚠️ Tidak ada perubahan baru untuk di-push."
  exit 0
fi

echo "✅ Commit perubahan yang baru..."
git add .
git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"

echo "🚀 Push ke GitHub..."
git push origin main

echo "🎉 Selesai! Repo sudah sinkron dengan GitHub."
