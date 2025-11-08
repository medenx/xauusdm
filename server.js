import express from "express";
import fetch from "node-fetch";

const app = express();
const PORT = 3000;

// Ambil harga XAUUSD dari Yahoo Finance (tidak butuh API key)
app.get("/xau", async (req, res) => {
  try {
    const url = "https://query1.finance.yahoo.com/v7/finance/quote?symbols=XAUUSD=X";
    const resp = await fetch(url);
    const data = await resp.json();
    const price = data.quoteResponse.result[0]?.regularMarketPrice;

    if (!price) return res.json({ error: "Harga tidak ditemukan" });

    res.json({ price });
  } catch (err) {
    res.json({ error: "Gagal ambil harga" });
  }
});

app.listen(PORT, () => console.log(`✅ Proxy XAU aktif di port ${PORT}`));
