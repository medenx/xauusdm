import fetch from "node-fetch";

export async function sendTelegram(text, chatId) {
  try {
    const token = process.env.TELEGRAM_BOT_TOKEN;
    const defaultChat = process.env.TELEGRAM_CHAT_ID;
    const targetChat = chatId || defaultChat;

    if (!token || !targetChat) {
      console.log("⚠️  Bot token atau chat ID belum diatur (ENV).");
      return;
    }

    const res = await fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ chat_id: targetChat, text })
    });

    const data = await res.json();
    console.log("✅ Telegram Response:", data);
  } catch (err) {
    console.error("❌ Gagal mengirim Telegram:", err);
  }
}
