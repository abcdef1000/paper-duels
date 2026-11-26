# Paper One Duel

Live 1v1 multiple-choice duels on H2 Physics (9478) Paper 1-style questions, plus solo practice, per-question progress and a leaderboard.

- `docs/`: the website GitHub Pages serves (`index.html`, `questions.json`, `firebase-config.js`).
- `database.rules.json`: security rules to paste into Firebase.
- `test/run.sh`: plays a full two-player match in headless Chrome against a fake Firebase.
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

All questions live in `docs/questions.json`. Each has a stable `id`, a `topic` (which must match one listed under `sections`), the stem `q`, four options `o`, the index `a` of the correct option (0–3), and an explanation `x`. Option order is shuffled in play, so explanations shouldn't refer to letters. Progress is keyed by `id`, so don't reuse an id for a different question.

## Testing

```
test/run.sh
```
This needs Google Chrome and Python 3. It prints each round's outcome and ends with `DONE`, or `FAIL: …`.
