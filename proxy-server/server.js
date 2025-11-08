const express = require('express');
const axios = require('axios');
const app = express();
const PORT = process.env.PORT || 3000;

async function getGoldPrice() {
  try {
    const res = await axios.get('https://api.metals.live/v1/spot/gold', {
      headers: { 'User-Agent': 'Mozilla/5.0' }
    });
    // Format data: [[timestamp, price]]
    if (Array.isArray(res.data) && res.data.length > 0) {
      return res.data[0][1];
    } else {
      throw new Error('Format API berubah');
    }
  } catch (err) {
    console.error("Gagal ambil harga:", err.message);
    return null;
  }
}

app.get('/xau', async (req, res) => {
  const price = await getGoldPrice();
  if (!price) {
    return res.status(500).json({ error: "Gagal ambil harga emas" });
  }
  res.json({ symbol: "XAUUSD", price });
});

app.listen(PORT, () => {
  console.log(`✅ Proxy server aktif di port ${PORT}`);
});
