/**
 * Capture live preview PNGs for the links README.
 * Usage: node scripts/capture-previews.mjs
 */
import { chromium } from "playwright";
import { mkdir } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.join(__dirname, "..", "docs", "previews", "apps");

const TARGETS = [
  { file: "links-hub.png", url: "https://dacameragirl.github.io/links/", wait: 1200 },
  { file: "spectrum.png", url: "https://dacameragirl.github.io/Spectrum/", wait: 2500 },
  { file: "sporelight.png", url: "https://dacameragirl.github.io/Sporelight/", wait: 2500 },
  { file: "ai-eval-job-radar.png", url: "https://dacameragirl.github.io/ai-eval-job-radar/", wait: 2000 },
  { file: "ai-video-annotator.png", url: "https://dacameragirl.github.io/AI-Video-Annotator/", wait: 2000 },
  { file: "jaxons-rhyming-clock.png", url: "https://dacameragirl.github.io/Jaxons-Rhyming-Clock/", wait: 2000 },
  { file: "gatekeeper.png", url: "https://dacameragirl.github.io/gatekeeper/", wait: 2000 },
  { file: "compass-ultra-web-intel.png", url: "https://dacameragirl.github.io/Compass-Ultra-Web-Intel/", wait: 2000 },
  { file: "shawns-pressure-washing.png", url: "https://dacameragirl.github.io/shawns-pressure-washing/", wait: 2000 },
  { file: "andys-woodworks.png", url: "https://dacameragirl.github.io/andys-woodworks/", wait: 2000 },
  { file: "openclaw-academy.png", url: "https://dacameragirl.github.io/OpenClaw-Academy/", wait: 2000 },
  { file: "roseops-studio.png", url: "https://dacameragirl.github.io/RoseOps-Studio/", wait: 2000 },
];

await mkdir(outDir, { recursive: true });

const browser = await chromium.launch();
const context = await browser.newContext({
  viewport: { width: 1280, height: 720 },
  deviceScaleFactor: 1,
});

for (const target of TARGETS) {
  const page = await context.newPage();
  try {
    await page.goto(target.url, { waitUntil: "domcontentloaded", timeout: 45000 });
    await page.waitForTimeout(target.wait);
    await page.screenshot({
      path: path.join(outDir, target.file),
      fullPage: false,
      type: "png",
    });
    console.log(`✓ ${target.file}`);
  } catch (error) {
    console.warn(`✗ ${target.file}: ${error.message}`);
  } finally {
    await page.close();
  }
}

await browser.close();
console.log("Done.");