const express = require('express');
const axios = require('axios');
const app = express();
const PORT = process.env.PORT || 3000;

// Ambil harga XAU/USD dari Yahoo Finance (GC=F = Gold Futures)
async function getGoldPrice() {
  try {
    const res = await axios.get(
      'https://query1.finance.yahoo.com/v8/finance/chart/GC=F'
    );
    const result = res.data.chart.result[0];
    const price = result.meta.regularMarketPrice;
    return price;
  } catch (err) {
    console.error("Error Yahoo Finance:", err.message);
    return null;
  }
}

app.get('/xau', async (req, res) => {
  const price = await getGoldPrice();
  if (!price) {
    return res.status(500).json({ error: 'Gagal ambil harga emas dari Yahoo' });
  }
  res.json({ symbol: 'XAUUSD', price });
});

app.listen(PORT, () => {
  console.log(`✅ Proxy server aktif di port ${PORT}`);
});
