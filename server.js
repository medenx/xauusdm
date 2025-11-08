import express from "express";
import dotenv from "dotenv";
import { handleUpdate } from "./utils/handler.js";

dotenv.config();
const app = express();
app.use(express.json());

// Webhook endpoint untuk Telegram
app.post("/webhook", async (req, res) => {
  await handleUpdate(req.body);
  res.sendStatus(200);
});

// Jalankan server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Server aktif di port ${PORT}`));

// Anti-crash global
process.on("uncaughtException", (err) => {
  console.error("⚠️ Uncaught Exception:", err);
});

process.on("unhandledRejection", (reason, promise) => {
  console.error("⚠️ Unhandled Rejection:", reason);
});
