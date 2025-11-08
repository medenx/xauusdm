import fetch from "node-fetch";

export async function sendTelegram(text, chatId) {
  try {
    const token = process.env.TELEGRAM_BOT_TOKEN;
    const defaultChat = process.env.TELEGRAM_CHAT_ID;
    const targetChat = chatId || defaultChat;

    if (!token || !targetChat) {
      return console.log("⚠️ TOKEN atau CHAT ID belum diatur di .env");
    }

    const res = await fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ chat_id: targetChat, text })
    });

    const data = await res.json();
    if (!data.ok) {
      console.log("⚠️ Telegram API respon error:", data);
    }
  } catch (err) {
    console.error("❌ Error kirim Telegram:", err);
  }
}
