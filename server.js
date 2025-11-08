const express = require("express");
const bodyParser = require("body-parser");
require("dotenv").config();
const { sendTelegramMessage } = require("./utils/telegram");
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

const app = express();
app.use(bodyParser.json());
const TELEGRAM_API = `https://api.telegram.org/bot${process.env.TELEGRAM_BOT_TOKEN}`;
let lastUpdateId = 0;

// Root
app.get("/", (req, res) => res.send("✅ XAU-Sentinel Server Aktif"));

// Endpoint manual kirim Telegram
app.post("/send", async (req, res) => {
  const { text } = req.body;
  if (!text) return res.status(400).json({ error: "Text tidak boleh kosong" });
  await sendTelegramMessage(text);
  res.json({ status: "Pesan dikirim", text });
});

// Polling /start aman tanpa crash
async function pollUpdates() {
  try {
    const res = await fetch(`${TELEGRAM_API}/getUpdates?offset=${lastUpdateId + 1}`);
    const data = await res.json();
    if (!data.result || data.result.length === 0) return; // ❤ Fix utama anti crash

    for (const update of data.result) {
      lastUpdateId = update.update_id;
      const msg = update.message;
      if (msg && msg.text === "/start") {
        await sendTelegramMessage("✅ Bot aktif & siap menerima perintah, masukkan pesan atau instruksi.");
      }
    }
  } catch (err) {
    console.error("Polling error:", err.message);
  }
}
setInterval(pollUpdates, 2000);

// Jalankan server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`✅ Server berjalan di port ${PORT}`));
