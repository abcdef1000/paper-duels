// Screenshot a page once a JS condition becomes true.
// Usage: node test/snap.mjs <url> <condition-js> <out.png> [light|dark] [width] [height] [clipSelector]
import { spawn } from "node:child_process";
import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const [url, cond, outPng, scheme = "light", w = "1280", h = "900", clipSel] = process.argv.slice(2);
const port = 19222 + Math.floor(Math.random() * 500);
const chrome = spawn("google-chrome", ["--headless=new", "--disable-gpu", "--no-sandbox", "--hide-scrollbars", `--remote-debugging-port=${port}`,
  `--user-data-dir=${mkdtempSync(join(tmpdir(), "p1d-"))}`, "about:blank"], { stdio: "ignore" });
const sleep = ms => new Promise(r => setTimeout(r, ms));
let target;
for (let i = 0; i < 50 && !target; i++) { await sleep(200); try { target = (await (await fetch(`http://127.0.0.1:${port}/json`)).json()).find(t => t.type === "page"); } catch {} }
const ws = new WebSocket(target.webSocketDebuggerUrl);
await new Promise(r => ws.onopen = r);
let id = 0; const pending = {};
ws.onmessage = ev => { const m = JSON.parse(ev.data); if (m.id && pending[m.id]) { pending[m.id](m); delete pending[m.id]; } };
const send = (method, params = {}) => new Promise(r => { pending[++id] = r; ws.send(JSON.stringify({ id, method, params })); });
await send("Emulation.setDeviceMetricsOverride", { width: +w, height: +h, deviceScaleFactor: 1, mobile: +w < 600 });
await send("Emulation.setEmulatedMedia", { features: [{ name: "prefers-color-scheme", value: scheme }] });
await send("Page.navigate", { url });
let ok = false;
for (let i = 0; i < 600 && !ok; i++) {
  await sleep(200);
  const r = await send("Runtime.evaluate", { expression: `(()=>{try{return !!(${cond})}catch{return false}})()`, returnByValue: true });
  ok = r.result?.result?.value === true;
}
await sleep(700);
let clip;
if (clipSel) {
  const r = await send("Runtime.evaluate", { expression: `JSON.stringify((()=>{const e=${clipSel}; const b=e.getBoundingClientRect(); return {x:b.x+scrollX,y:b.y+scrollY,width:b.width,height:b.height,scale:1};})())`, returnByValue: true });
  clip = JSON.parse(r.result.result.value);
}
const shot = await send("Page.captureScreenshot", { format: "png", captureBeyondViewport: true, ...(clip ? { clip } : {}) });
writeFileSync(outPng, Buffer.from(shot.result.data, "base64"));
console.log(ok ? "captured" : "condition never true; captured anyway", outPng);
ws.close(); chrome.kill();
