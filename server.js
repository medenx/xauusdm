import express from "express";
import dotenv from "dotenv";

dotenv.config();
const app = express();
app.use(express.json());

app.get("/", (req, res) => {
  res.json({ status: "OK", message: "Server lokal di Termux berjalan tanpa Telegram/Railway." });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Server lokal aktif di port ${PORT}`));

process.on("uncaughtException", (err) => console.error("⚠️ Uncaught Exception:", err));
process.on("unhandledRejection", (reason) => console.error("⚠️ Unhandled Rejection:", reason));
