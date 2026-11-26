// Opens a URL in headless Chrome, waits, then prints the game's connection state and console errors.
// Usage: node test/probe.mjs <url> [waitSeconds]
import { spawn } from "node:child_process";
import { mkdtempSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const url = process.argv[2], wait = (+process.argv[3] || 12) * 1000;
const port = 19222 + Math.floor(Math.random() * 500);
const chrome = spawn("google-chrome", ["--headless=new", "--disable-gpu", "--no-sandbox", `--remote-debugging-port=${port}`,
  `--user-data-dir=${mkdtempSync(join(tmpdir(), "p1d-"))}`, "about:blank"], { stdio: "ignore" });
const sleep = ms => new Promise(r => setTimeout(r, ms));
let target;
for (let i = 0; i < 50 && !target; i++) {
  await sleep(200);
  try { target = (await (await fetch(`http://127.0.0.1:${port}/json`)).json()).find(t => t.type === "page"); } catch {}
}
const ws = new WebSocket(target.webSocketDebuggerUrl);
await new Promise(r => ws.onopen = r);
let id = 0; const pending = {}; const logs = [];
ws.onmessage = ev => {
  const m = JSON.parse(ev.data);
  if (m.id && pending[m.id]) { pending[m.id](m); delete pending[m.id]; }
  if (m.method === "Runtime.consoleAPICalled") logs.push(m.params.type + ": " + m.params.args.map(a => a.value ?? a.description ?? "").join(" "));
  if (m.method === "Runtime.exceptionThrown") logs.push("exception: " + (m.params.exceptionDetails.exception?.description || m.params.exceptionDetails.text));
  if (m.method === "Log.entryAdded") logs.push("log " + m.params.entry.level + ": " + m.params.entry.text + " " + (m.params.entry.url || ""));
};
const send = (method, params = {}) => new Promise(r => { pending[++id] = r; ws.send(JSON.stringify({ id, method, params })); });
await send("Runtime.enable"); await send("Log.enable");
await send("Page.navigate", { url });
await sleep(wait);
const r = await send("Runtime.evaluate", { expression: `JSON.stringify({ roomState: S.roomState, storeMode: S.storeMode, uid: S.uid, setupMissing: !!S.setupMissing, peers: S.peers.length, google: S.google, acct: document.getElementById("acct").textContent })`, returnByValue: true });
console.log("state:", r.result.result.value);
console.log(logs.length ? logs.join("\n") : "(no console messages)");
ws.close(); chrome.kill();
