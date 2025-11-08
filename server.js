import express from "express";
import dotenv from "dotenv";
import { handleUpdate } from "./utils/handler.js";

dotenv.config();
const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());

app.get("/", (req, res) => {
  res.send("✅ XAU Sentinel aktif");
});

app.post("/webhook", async (req, res) => {
  try {
    await handleUpdate(req.body);
    res.status(200).json({ ok: true });
  } catch (err) {
    console.error("❌ Webhook Error:", err.message);
    res.status(500).json({ ok: false });
  }
});

app.listen(PORT, () => {
  console.log(`✅ Server berjalan di port ${PORT}`);
});
