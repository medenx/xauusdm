import fetch from "node-fetch";

const TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const API_URL = `https://api.telegram.org/bot${TOKEN}`;

export async function sendTelegram(chatId, text) {
  try {
    const res = await fetch(`${API_URL}/sendMessage`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ chat_id: chatId, text }),
    });
    const data = await res.json();
    if (!data.ok) console.error("⚠ Telegram API:", data);
    return data;
  } catch (err) {
    console.error("❌ Gagal kirim ke Telegram:", err.message);
  }
}
