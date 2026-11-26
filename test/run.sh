#!/usr/bin/env bash
# Plays a 3-player Race game and a Bomb game in headless Chrome, using a fake Firebase.
set -euo pipefail
cd "$(dirname "$0")"
rm -rf site && mkdir site
cp ../docs/index.html ../docs/*.json site/
cat > site/firebase-config.js <<'EOF'
window.FIREBASE_CONFIG = { apiKey: "test" };
window.firebase = parent.makeFakeFirebase(window);
EOF
PORT=${PORT:-18431}
python3 -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 &
SRV=$!
trap 'kill $SRV' EXIT
sleep 1
timeout 120 google-chrome --headless=new --disable-gpu --no-sandbox --virtual-time-budget=600000 \
  --dump-dom "http://127.0.0.1:$PORT/duel.html" 2>/dev/null \
  | python3 -I -c 'import sys,re,html; m=re.search(r"<pre id=\"out\">(.*?)</pre>", sys.stdin.read(), re.S); print(html.unescape(m.group(1)) if m else "no output")'
