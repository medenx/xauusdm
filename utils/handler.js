import { sendTelegram } from "./telegram.js";

export async function handleUpdate(update) {
  if (!update.message) return;
  const chatId = update.message.chat.id;
  const text = update.message.text || "";

  if (text.startsWith("/start")) {
    return sendTelegram("✅ Bot aktif — sistem berjalan lancar.", chatId);
  }

  return sendTelegram(`📩 Kamu kirim: ${text}`, chatId);
}
