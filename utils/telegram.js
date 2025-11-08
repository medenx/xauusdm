const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

const sendTelegramMessage = async (text, chatId = process.env.TELEGRAM_CHAT_ID) => {
  const token = process.env.TELEGRAM_BOT_TOKEN;
  if (!token || !chatId) return console.log("❌ Token / Chat ID belum diset");
  try {
    const res = await fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ chat_id: chatId, text })
    });
    const data = await res.json();
    console.log("✅ Telegram Response:", data);
  } catch (err) {
    console.error("❌ Gagal kirim pesan:", err);
  }
};
module.exports = { sendTelegramMessage };
