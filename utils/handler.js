import { sendTelegram } from "./telegram.js";

export async function handleUpdate(update) {
  if (!update.message) return;
  const chatId = update.message.chat.id;
  const text = update.message.text || "";

  if (text.startsWith("/start")) {
    return sendTelegram(chatId, "Bot siap ✔ Sistem otomatis aktif.");
  }

  return sendTelegram(chatId, `📩 Kamu kirim: ${text}`);
}
