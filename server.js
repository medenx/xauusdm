import express from "express";
import fetch from "node-fetch";
import dotenv from "dotenv";
dotenv.config();

const app = express();
const PORT = 3000;
const GOLD_KEY = process.env.GOLDAPI_KEY;

// ✅ 1) Sumber utama — GoldAPI (lebih stabil & cepat)
const getGoldAPI = async () => {
  try {
    const r = await fetch("https://www.goldapi.io/api/XAU/USD", {
      headers: {
        "x-access-token": GOLD_KEY,
        "Content-Type": "application/json"
      }
    });
    const d = await r.json();
    return d?.price || null;
  } catch {
    return null;
  }
};

// ✅ 2) Fallback — Yahoo (pakai user-agent)
const getYahoo = async () => {
  try {
    const r = await fetch("https://query1.finance.yahoo.com/v7/finance/quote?symbols=XAUUSD=X", {
      headers: { "User-Agent": "Mozilla/5.0" }
    });
    const d = await r.json();
    return d.quoteResponse?.result[0]?.regularMarketPrice || null;
  } catch {
    return null;
  }
};

// Endpoint utama
app.get("/xau", async (_, res) => {
  let price = await getGoldAPI();
  if (!price) price = await getYahoo();
  if (!price) return res.json({ error: "Semua sumber gagal" });
  res.json({ price });
});

app.listen(PORT, () =>
  console.log(`✅ Proxy Harga XAU aktif di port ${PORT}`)
);
