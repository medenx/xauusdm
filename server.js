import express from "express";
import fetch from "node-fetch";
const app = express();
const PORT = process.env.PORT || 3000;

app.get("/xau", async (req, res) => {
  try {
    const resp = await fetch("https://api.metals.live/v1/spot/gold");
    const data = await resp.json();
    if (!data || !data[0] || !data[0][1]) throw "Invalid Response";
    res.json({ symbol: "XAUUSD", price: data[0][1] });
  } catch (e) {
    res.json({ error: "Gagal ambil harga emas" });
  }
});

app.listen(PORT, () => console.log(`✅ Proxy XAU aktif di port ${PORT}`));
