// Headless-Chrome screenshot harness for the Flutter web build.
//
// Flutter web renders to canvas, so a plain DOM screenshot shows nothing -
// we have to let the engine boot and then capture real pixels. Used to verify
// layout changes that widget tests cannot see (overlaps, crops, spacing).
const { chromium } = require('playwright-core');

const URL = process.env.SHOOT_URL || 'http://127.0.0.1:8899/';
const OUT = process.env.SHOOT_OUT || 'shot';
const CHROME =
  'C:/Program Files/Google/Chrome/Application/chrome.exe';

(async () => {
  const browser = await chromium.launch({
    executablePath: CHROME,
    args: ['--no-sandbox', '--disable-dev-shm-usage', '--force-device-scale-factor=2'],
  });
  const page = await browser.newPage({
    viewport: { width: 412, height: 900 },
    deviceScaleFactor: 2,
  });

  const errors = [];
  page.on('console', (m) => {
    if (m.type() === 'error') errors.push(m.text());
  });
  page.on('pageerror', (e) => errors.push(String(e)));

  await page.goto(URL, { waitUntil: 'load', timeout: 120000 });
  // Flutter web needs a beat to paint its first frame and clear the loader.
  await page.waitForTimeout(9000);

  // --- Intro screen --------------------------------------------------------
  await page.screenshot({ path: `${OUT}-00-intro.png` });

  // Tap "Explore the Fleet" (bottom CTA) to reach the home screen.
  await page.mouse.click(206, 812);
  await page.waitForTimeout(3000);

  // --- Home screen ---------------------------------------------------------
  await page.screenshot({ path: `${OUT}-01-home.png` });

  // --- Scroll down to the fleet list --------------------------------------
  await page.mouse.move(206, 500);
  for (let i = 0; i < 6; i++) {
    await page.mouse.wheel(0, 260);
    await page.waitForTimeout(160);
  }
  await page.waitForTimeout(900);
  await page.screenshot({ path: `${OUT}-02-list.png` });

  // --- Open the first car's details ---------------------------------------
  await page.mouse.click(206, 420);
  await page.waitForTimeout(2600);
  await page.screenshot({ path: `${OUT}-03-details-top.png` });

  // --- Scroll to the performance dashboard --------------------------------
  for (let i = 0; i < 5; i++) {
    await page.mouse.wheel(0, 220);
    await page.waitForTimeout(170);
  }
  await page.waitForTimeout(2800); // let the gauge finish its sweep
  await page.screenshot({ path: `${OUT}-04-speedometer.png` });

  console.log('errors:', errors.length ? errors.slice(0, 8) : 'none');
  await browser.close();
})();
