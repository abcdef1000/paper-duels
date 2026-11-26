# Paper One Duel

Party-style multiple-choice game for 2–8 players with three question banks: H2 Physics (9478) Paper 1 style, PSLE Science and PSLE Maths. Players sit around a round table. There is also solo practice, per-question progress and a leaderboard.

- **Race:** everyone gets the same question. The first correct answer scores, and a wrong answer locks you out of that question.
- **Bomb:** the holder must answer before the fuse runs out. Right passes the bomb on. Wrong or too slow loses a life. The last player standing wins.

- `docs/`: the website GitHub Pages serves (`index.html`, `firebase-config.js`, and the banks `questions.json` (H2 Physics), `psle-science.json`, `psle-maths.json`).
- `database.rules.json`: security rules to paste into Firebase.
- `test/run.sh`: plays a 3-player Race game and a Bomb game in headless Chrome against a fake Firebase.
- `claude-artifact/`: the claude.ai-hosted version of the same game.

## Setup (about 10 minutes, all free)

You need a **GitHub account** and a **Google account** (for Firebase). Nothing else.

### 1. Firebase (the realtime backend for duels, progress and the leaderboard)

1. Go to <https://console.firebase.google.com>, click **Create a project**, name it (e.g. `paper-one-duel`). Google Analytics can be turned off.
2. **Build → Realtime Database → Create database.** Pick the region nearest your players (Singapore: `asia-southeast1`). Start in **locked mode**.
3. On the database's **Rules** tab, replace everything with the contents of `database.rules.json` and click **Publish**.
4. **Build → Authentication → Get started → Sign-in method:** enable **Anonymous**.
   Optional: also enable **Google**, so players can sync progress across devices with "Sync with Google".
5. **Project settings (gear icon) → General → Your apps → Web (`</>`)**: register an app (no hosting needed). Copy the `firebaseConfig` values into `docs/firebase-config.js`. Make sure `databaseURL` is included. If it's missing, copy it from the top of the Realtime Database page.

The config values are safe to publish. Access is controlled by the rules you pasted in step 3.

### 2. GitHub Pages (the hosting)

1. Create a new **public** repository on GitHub (e.g. `paper-one-duel`) and push this folder to it.
2. In the repo: **Settings → Pages → Build and deployment → Deploy from a branch**, branch `main`, folder **`/docs`**. Save.
3. After a minute the site is live at `https://<your-username>.github.io/<repo-name>/`.
4. If you enabled Google sign-in: Firebase console → **Authentication → Settings → Authorized domains → Add domain** → `<your-username>.github.io`.

## Free-tier limits

Firebase's free Spark plan allows 100 simultaneous connections and 10 GB/month of downloads. That's plenty for a class or a few CCAs. Each open tab is one connection.

## Editing questions

Questions live in `docs/questions.json` (H2 Physics), `docs/psle-science.json` and `docs/psle-maths.json`. Ids must be unique across all three files. To add a subject, add a file and an entry to `BANKS` in `docs/index.html`. Questions marked `"quick": true` form the Quick-fire set (mental maths, constants given), which Bomb mode uses by default. A question may carry a `fig`: an inline SVG drawn with `currentColor` and the classes `ac`, `acf`, `guide`, `dim`, `thick`, `hollow` and `solid`, so it follows light and dark mode. Each question has a stable `id`, a `topic` (which must match one listed under `sections`), the stem `q`, four options `o`, the index `a` of the correct option (0–3), and an explanation `x`. Option order is shuffled in play, so explanations shouldn't refer to letters. Progress is keyed by `id`, so don't reuse an id for a different question.

## Testing

```
test/run.sh
```
This needs Google Chrome and Python 3. It prints each round's outcome and ends with `DONE`, or `FAIL: …`.
