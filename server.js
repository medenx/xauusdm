const express = require("express");
const bodyParser = require("body-parser");
require("dotenv").config();
const { sendTelegramMessage } = require("./utils/telegram");

const app = express();
app.use(bodyParser.json());

// Root endpoint
app.get("/", (req, res) => {
  res.send("✅ XAU-Sentinel Server Aktif");
});

// Endpoint kirim Telegram manual
app.post("/send", async (req, res) => {
  const { text } = req.body;
  if (!text) return res.status(400).json({ error: "Text tidak boleh kosong" });

  await sendTelegramMessage(text);
  res.json({ status: "Pesan dikirim", text });
});

// Jalankan server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`✅ Server berjalan di port ${PORT}`);
});
