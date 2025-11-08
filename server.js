import express from "express";
import fetch from "node-fetch";

const app = express();
const PORT = 3000;

// 1. Metals.live
async function getMetalsLive() {
  try {
    const resp = await fetch("https://api.metals.live/v1/spot/gold", {
      headers: { "User-Agent": "Mozilla/5.0" }
    });
    const data = await resp.json();
    return data?.[0] || null;
  } catch {
    return null;
  }
}

// 2. Yahoo Finance
async function getYahoo() {
  try {
    const resp = await fetch("https://query1.finance.yahoo.com/v7/finance/quote?symbols=XAUUSD=X");
    const data = await resp.json();
    return data?.quoteResponse?.result?.[0]?.regularMarketPrice || null;
  } catch {
    return null;
  }
}

// 3. GoldAPI (no API key needed for generic price)
async function getGoldAPI() {
  try {
    const resp = await fetch("https://www.goldapi.io/api/XAU/USD", {
      headers: { "x-access-token": "goldapi-oc-live" }
    });
    const data = await resp.json();
    return data?.price || null;
  } catch {
    return null;
  }
}

// Endpoint localhost:3000/xau
app.get("/xau", async (req, res) => {
  let price = await getMetalsLive();
  if (!price) price = await getYahoo();
  if (!price) price = await getGoldAPI();

  if (!price) {
    console.log("❌ Semua sumber gagal");
    return res.status(500).json({ error: "Gagal ambil harga emas" });
  }

  console.log(`✅ Harga XAUUSD: ${price}`);
  res.json({ symbol: "XAUUSD", price });
});

app.listen(PORT, () => console.log(`✅ Proxy XAU berjalan di port ${PORT}`));
