const express = require("express");
const bodyParser = require("body-parser");
require("dotenv").config();
const { sendTelegramMessage } = require("./utils/telegram");
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

const TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const CHAT_ID = process.env.TELEGRAM_CHAT_ID;
let last_update_id = 0;

const app = express();
app.use(bodyParser.json());

// Root Cek Status
app.get("/", (req,res)=>res.send("✅ XAU-Sentinel Server Aktif"));

// Endpoint manual kirim
app.post("/send", async (req,res)=>{
  const { text } = req.body;
  if (!text) return res.status(400).json({error:"Teks kosong"});
  await sendTelegramMessage(text);
  res.json({status:"Pesan dikirim", text});
});

// Polling Telegram
async function pollTelegram() {
  try {
    const res = await fetch(`https://api.telegram.org/bot${TOKEN}/getUpdates?offset=${last_update_id+1}`);
    const data = await res.json();
    if (data.ok && data.result.length > 0) {
      for (const msg of data.result) {
        last_update_id = msg.update_id;
        const chatId = msg.message.chat.id;
        const text = msg.message.text || "";

        if (text === "/start") {
          await sendTelegramMessage("🤖 Bot aktif ✅ Siap menerima perintah.", chatId);
        } else {
          await sendTelegramMessage(`Kamu mengirim: ${text}`, chatId);
        }
      }
    }
  } catch (err) {
    console.log("Polling error:", err.message);
  }
}
setInterval(pollTelegram, 2000);

// Start server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`✅ Server berjalan di port ${PORT}`);
  sendTelegramMessage("🚀 Server baru aktif & polling berjalan ✅");
});
