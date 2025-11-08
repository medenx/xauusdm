import { sendTelegram } from "./telegram.js";

export async function handleUpdate(update) {
  try {
    if (!update?.message?.chat?.id) {
      console.log("⚠️ Update tidak valid atau tanpa chat ID.");
      return;
    }
    const chatId = update.message.chat.id;
    const text = update.message.text || "";

    if (text.startsWith("/start")) {
      return sendTelegram("✅ Bot aktif dan siap menerima perintah.", chatId);
    }

    return sendTelegram(`📩 Kamu mengirim: ${text}`, chatId);
  } catch (err) {
    console.error("❌ Error di handleUpdate:", err);
  }
}
