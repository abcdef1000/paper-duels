# Paper One Duel: Orbit Station (Roblox)

The Roblox version of the web game. Crew stand on pads around a reactor ring on a space station. **Race:** the first correct answer scores. **Hot Core:** a glowing core hovers over whoever must answer. Answer right to pass it on; answer wrong or run out of time and it blows (visual only), costing a life.

The server holds the answers (`src/server/Banks.luau`, in ServerScriptService), so clients can't read them. Progress is saved per player in a DataStore and shown as **Wins** and **Mastered** in the player list.

## Set up on Ubuntu

Roblox Studio has no Linux version. You write code on Ubuntu with Rojo, and run Studio through **Vinegar**, which runs it under Wine.

1. **Install Flatpak and Vinegar**
   ```
   sudo apt install flatpak
   flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
   flatpak install flathub org.vinegarhq.Vinegar
   flatpak run org.vinegarhq.Vinegar
   ```
   Sign in to Roblox when Studio opens. If Studio won't start, check Vinegar's GitHub issues: Roblox updates sometimes break Wine for a while. The fallback is a Windows machine or VM. The workflow below is the same there.

2. **Install Rokit and Rojo** (from this `roblox/` folder)
   ```
   curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
   # open a new terminal so `rokit` is on your PATH, then:
   rokit install          # installs the Rojo version pinned in rokit.toml
   rojo plugin install    # puts the Rojo plugin into Studio
   ```
   If `rojo plugin install` can't find Studio's plugins folder under Vinegar, run `rojo build -o plugin.rbxm --plugin` instead. Copy the file into `~/.var/app/org.vinegarhq.Vinegar/data/vinegar/prefixes/studio/drive_c/users/$USER/AppData/Local/Roblox/Plugins/`.

3. **Open the game in Studio**
   - In Studio: **New → Baseplate**.
   - In a terminal here: `rojo serve`
   - In Studio: **Plugins → Rojo → Connect**. The scripts appear in ServerScriptService, ReplicatedStorage and StarterPlayerScripts. Edits you save on Ubuntu sync live.

4. **Turn on saving and set the room size**
   - **Home → Game Settings → Security → Enable Studio Access to API Services** (for the DataStore).
   - **Game Settings → Places → Max Players: 8**. One server is one room.

5. **Play-test**
   - Solo: press **Play**. In Studio you can launch alone (`ALLOW_SOLO_IN_STUDIO` in `Config.luau`).
   - Multiplayer: **Test → Clients and Servers → 2 or 3 players → Start**. The first player in is the captain and gets the Launch button.

6. **Publish**
   - **File → Publish to Roblox**, then make the experience public in its settings on create.roblox.com.

## Updating questions

The questions come from the website's `docs/*.json`. After editing those, regenerate the Luau bank:
```
python3 tools/json2luau.py
```
Questions with diagrams are skipped, because the SVG figures don't exist in Roblox.

## Files

- `src/server/Game.server.luau`: rooms, rounds, scoring, the station build, the core, DataStore progress.
- `src/client/Client.client.luau`: the HUD (question, answer buttons, timer, crew list, captain's launch controls).
- `src/shared/Config.luau`: timings, sizes and the Orbit Station palette.
- `src/server/Banks.luau`: generated question banks.
