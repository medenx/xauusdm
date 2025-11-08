import express from 'express';
import fetch from 'node-fetch';

const app = express();
const PORT = 3000;

// Fungsi ambil harga dari Metals.live
async function getFromMetalsLive() {
  const resp = await fetch("https://api.metals.live/v1/spot/gold", {
    headers: { "User-Agent": "Mozilla/5.0" }
  });
  const data = await resp.json();
  return data?.[0]?.price || null;
}

// Fallback ambil dari Yahoo Finance
async function getFromYahoo() {
  const resp = await fetch("https://query1.finance.yahoo.com/v7/finance/quote?symbols=XAUUSD=X");
  const data = await resp.json();
  return data?.quoteResponse?.result?.[0]?.regularMarketPrice || null;
}

// Endpoint utama
app.get('/xau', async (req, res) => {
  try {
    let price = await getFromMetalsLive();
    if (!price) price = await getFromYahoo();

    if (!price) return res.json({ error: "Gagal ambil harga emas" });
    res.json({ symbol: "XAUUSD", price });
  } catch (err) {
    res.json({ error: "Server error" });
  }
});

app.listen(PORT, () => console.log(`✅ Proxy harga XAU aktif di port ${PORT}`));
