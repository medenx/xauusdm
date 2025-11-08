import express from "express";
import fetch from "node-fetch";

const app = express();
const PORT = 3000;

// ✅ Fungsi ambil harga dari Yahoo
const fetchYahoo = async () => {
  try {
    const url = "https://query1.finance.yahoo.com/v7/finance/quote?symbols=XAUUSD=X";
    const resp = await fetch(url);
    const data = await resp.json();
    return data.quoteResponse?.result[0]?.regularMarketPrice || null;
  } catch {
    return null;
  }
};

// ✅ Fungsi fallback ke GoldAPI (tanpa API key)
const fetchGoldAPI = async () => {
  try {
    const resp = await fetch("https://api.metals.live/v1/spot/gold");
    const data = await resp.json();
    return data[0]?.price || null;
  } catch {
    return null;
  }
};

app.get("/xau", async (req, res) => {
  let price = await fetchYahoo();
  if (!price) price = await fetchGoldAPI();

  if (!price) return res.json({ error: "Semua sumber gagal" });
  res.json({ price });
});

app.listen(PORT, () => console.log(`✅ Proxy XAU aktif di port ${PORT}`));
