const express = require("express");
const cors = require('cors');
const logger = require("pino-http");

const app = express();

const PORT = process.env.PORT || 3000;
const DELAY_MS = process.env.DELAY_MS || 1000;

const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const rand = (min, max) => Math.floor(Math.random() * (max - min + 1) + min);

app.use(cors());
app.use(logger());

app.get("/", async (_req, res) => {
  await wait(DELAY_MS);
  res.send("Hello World!");
});

app.get("/random", async (_req, res) => {
  await wait(DELAY_MS);
  res.send(`Random number: ${rand(1, 100)}`);
});

app.listen(PORT, () => {
  console.log(`App listening at http://localhost:${PORT}`);
});
