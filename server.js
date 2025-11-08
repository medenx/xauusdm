import express from "express";
import dotenv from "dotenv";
import { handleUpdate } from "./utils/handler.js";

dotenv.config();
const app = express();
app.use(express.json());

app.post("/webhook", async (req, res) => {
  await handleUpdate(req.body);
  res.sendStatus(200);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Server aktif di port ${PORT}`));
