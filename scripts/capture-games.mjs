import { chromium } from "playwright";
import path from "node:path";
import { fileURLToPath } from "node:url";
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.join(__dirname, "..", "docs", "previews", "games");
const games = [
  ["sea-drifter.png","https://dacameragirl.github.io/sea-drifter/",3000],
  ["frogger-forge.png","https://dacameragirl.github.io/FroggerForge/",3000],
  ["floating-panda-dream.png","https://dacameragirl.github.io/floating-panda-dream/",3000],
  ["pixelforge.png","https://dacameragirl.github.io/pixelforge/",3000],
  ["quantum-command-52.png","https://dacameragirl.github.io/quantum-command-52/",3000],
  ["pride-game-jam-2026.png","https://dacameragirl.github.io/pride-game-jam-2026/",3000],
  ["jaxons-potty-time.png","https://dacameragirl.github.io/Jaxons_Potty_Time/",2500],
  ["math-bingo.png","https://dacameragirl.github.io/math-bingo/",2500],
];
const browser = await chromium.launch();
const ctx = await browser.newContext({ viewport: { width: 1280, height: 720 } });
for (const [file, url, wait] of games) {
  const page = await ctx.newPage();
  try {
    await page.goto(url, { waitUntil: "domcontentloaded", timeout: 45000 });
    await page.waitForTimeout(wait);
    await page.screenshot({ path: path.join(outDir, file), type: "png" });
    console.log("ok", file);
  } catch (e) { console.warn("fail", file, e.message); }
  await page.close();
}
await browser.close();
