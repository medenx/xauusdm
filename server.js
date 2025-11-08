const express = require('express');
const axios = require('axios');
const app = express();
const PORT = 3000;

// Ambil harga dari Metals.live (fallback API cepat)
async function getGoldPrice() {
  try {
    const { data } = await axios.get('https://api.metals.live/v1/spot');
    return data[0].gold; // format: [{ gold: 4009.8, silver: xx }]
  } catch (err) {
    return null;
  }
}

// Endpoint utama
app.get('/xau', async (req, res) => {
  const price = await getGoldPrice();
  if (!price) {
    return res.json({ error: "Gagal ambil harga emas" });
  }
  res.json({ symbol: "XAUUSD", price });
});

// Root cek server
app.get('/', (req, res) => {
  res.send("✅ XAU Proxy Server aktif. Gunakan /xau");
});

app.listen(PORT, () => {
  console.log(`🚀 Server berjalan di http://localhost:${PORT}`);
});
