# Other Channels (mostly free)

Game URL: https://abcdef1000.github.io/paper-duels/

| Channel | Cost | Effort | Reach to target | Notes |
|---|---|---|---|---|
| Daily Test share button (Wordle-style) | Free | Dev | Very high | Do this first |
| TikTok / Instagram Reels | Free organic; TikTok ads have a US$20/day ad group minimum | Medium | High (JC and upper-primary) | Under-18 ad targeting not verified, so stay organic |
| Telegram study groups/channels | Free | Low | High | Ask admins first |
| Discord study servers (e.g. SGExams Discord, ~12k members on its invite page) | Free | Low | Medium | Use the promo channels only |
| Teachers / tutors / CCA (Physics Society, Science Club) | Free | Medium | Very high per contact (8 players a room) | Send a ready-made lesson-starter pitch |
| Show HN | Free | Low | Low SG reach, high dev feedback | Must be "something people can play with", no signup barriers |
| Product Hunt | Free to launch | Medium | Low SG reach, good backlinks | Don't ask for upvotes |
| Parent newsletters / resource lists (e.g. Schoolbag newsletter, free-resource roundups) | Free to pitch | Low | Medium (PSLE parents) | Pitch as a free resource. Editorial inclusion isn't guaranteed. |

---

## Timing calendar

From SEAB-derived 2026 dates. **Check the 2027 dates on SEAB when they're published.**

| When | Who's revising | Action |
|---|---|---|
| **Now: late Nov–Dec 2026** | 2027 JC2s (current JC1s), P5 to P6 | Soft launch: share button, first r/SGExams post (after modmail), Telegram/Discord |
| Jan 2027 | New school year | Show HN, then Product Hunt a week later. Teacher outreach as Term 1 starts. |
| Mar–May | Common tests / WA | TikTok series "1 MCQ a day" |
| June holidays | Mid-year revision | Reddit post plus a paid Reddit burst |
| Jul–Sep | **JC prelims; PSLE written papers (late Sep in 2026)** | Main paid window: Reddit (students), Spotify/YouTube (parents) |
| Oct–Nov | **A-Levels** (2026: Physics practical 19 Oct, H2 Physics P1 27 Nov) | Daily Test threads only, and low-key. Students are stressed. |

---

## Wordle-style Daily Test share text

**Principles (from Wordle):** spoiler-free (no question content), fits in a group chat or tweet, one tap to copy, includes the URL. Wordle went from 90 players to over 2M a week in about 2 months, largely because people pasted their grids.

### Suggested format

```
🛰️ Paper One Duel · Daily #142 · H2 Physics
🟩🟩🟨⬛  3/4
⚡ 48s · 📈 Top 22%
abcdef1000.github.io/paper-duels
```

**Legend (keep it consistent):**
- 🟩 correct and fast (under the median time)
- 🟨 correct but slow
- ⬛ wrong or timed out
- The squares run Q1 to Q4 in rising difficulty, so a grid like 🟩🟩🟩⬛ reads as "nearly cleared the hard one".

**Variants:**
- Perfect run: `🟩🟩🟩🟩 4/4 · 🔥 Top 3%`
- PSLE: `🛰️ Paper One Duel · Daily #142 · PSLE Maths`
- Streak line (optional): `🔥 7-day streak`

**Implementation tips:**
- A "Copy result" button using `navigator.clipboard.writeText`, with `navigator.share` on mobile so it opens WhatsApp/Telegram directly.
- Daily number = days since launch. That makes "#142" a shared reference point.
- Add `?ref=share` to the URL in the share text, so share-driven visits can be counted without collecting personal data.
- Leaderboard hook: "Beat my score" deep link: `.../paper-duels/?daily=142`.

### Referral and leaderboard mechanics (free)
- **Room link sharing:** one-tap "Invite" that copies `Join my Paper One Duel room: CODE · link`.
- **School/class tag (optional, anonymous):** let players pick a JC or class nickname, and show a "top schools today" board. Friendly rivalry drives sharing. Make sure no real names are needed.
- **Weekly streak badge** that's worth screenshotting.

---

## Ready-to-paste copy

### Telegram (study group / channel)

> Ask the admin before posting. One message only, then answer questions.

**JC version**
> Hi all! Sharing a free thing I built for H2 Physics Paper 1 MCQ practice: **Paper One Duel**
> 🎮 Make a room, race up to 8 friends
> 💣 Hot Core mode: answer right to pass the bomb
> 📊 Daily Test: 4 Qs, ranked on a bell curve vs everyone
> No login, no ads, free. Feedback on wrong answers very welcome 🙏
> https://abcdef1000.github.io/paper-duels/

**Parent group version**
> Sharing a free PSLE Science and Maths practice game (no account, no payment). Kids can do a daily 4-question test, practise solo, or play with friends in a room. It also tracks which questions they've gotten right.
> https://abcdef1000.github.io/paper-duels/

### Discord (#resources or #self-promo channel only)

> **Paper One Duel**: free multiplayer quiz for **H2 Physics (P1 MCQ)**, **PSLE Science** and **PSLE Maths**
> • Race / Hot Core live rooms (2–8 players), works great on voice calls
> • Daily Test: 4 questions, accuracy + speed, bell-curve ranking
> • No account needed
> https://abcdef1000.github.io/paper-duels/
> I made it, so roast the questions pls. Reply here or DM if you find an error.

**Server event idea:** offer the server mods a weekly "Friday Hot Core night" in a voice channel. You host a room, top 3 get a role or shoutout.

### TikTok / Reels captions

Content format: 9:16 screen recordings of real rounds. Hook in the first second ("you have 3 seconds"), facecam optional, chiptune sound.

1. `POV: your study group discovers Hot Core mode 💣 #sgexams #alevels #h2physics #studytok #jc`
2. `4 questions a day. ranked against all of SG. where you landing? 📈 #h2physics #alevelphysics #singapore #studywithme`
3. `rating my friends' physics by how fast they explode 💥 (free game, link in bio) #jclife #sgstudents #physics`
4. `PSLE Maths but it's a game your kid will actually open 🛰️ free, no login #psle #psle2027 #sgparents`
5. `Q4 of today's daily test humbled me. can you get it in 15s? #alevels #physicsmcq #sg`

Put the link in your bio. TikTok captions don't make links clickable.

**Paid TikTok (optional, later):** TikTok's help centre puts the minimum at above US$50/day per campaign and above US$20/day per ad group. Rules on targeting under-18s weren't confirmed in this research, so check TikTok's ad policies before any paid run.

### Teacher / tutor / CCA email (cold outreach to public school or tuition contacts)

> **Subject:** Free MCQ game for H2 Physics / PSLE class warm-ups
>
> Dear [Teacher],
>
> I'd like to share a free browser game that some teachers may find useful as a 10-minute lesson starter: **Paper One Duel** (https://abcdef1000.github.io/paper-duels/).
>
> - Up to 8 students join a live room with a code (no accounts or installs). Run several rooms for a full class.
> - "Race" or "Hot Core" (hot-potato) modes with H2 Physics Paper 1-style MCQs, or PSLE Science/Maths
> - A daily 4-question test students can do at home
>
> It's free, with no ads and no student data collected for sale. If you spot any question errors or have topics you'd like added, I'd be grateful for the feedback.
>
> Best regards,
> The Paper One Duel team

*(Check whether school devices or networks allow the site before suggesting it for class. Only send to publicly listed contacts, and don't send in bulk.)*

### Show HN

**Title:** `Show HN: Paper One Duel – a multiplayer pixel-art quiz for Singapore exam MCQs`

**First comment:**
> I built this for Singapore students doing A-level Physics (Paper 1 MCQ) and PSLE Science/Maths. It runs in the browser with no signup. You can create a room for 2–8 players with a Race mode or a hot-potato "Hot Core" mode, or take a 4-question daily test that's ranked on a bell curve against everyone who played that day.
>
> Tech notes: [stack, how live rooms sync, how the bell curve is computed]. A Roblox port is in progress.
>
> I'd love feedback on the game feel and on the daily-test scoring.

Rules: the title must start with "Show HN", you must be there to discuss it, and don't ask friends to upvote or comment.

### Product Hunt

- **Tagline (60 chars max):** `Multiplayer pixel-art quiz duels for exam MCQs`
- **Description:** `Free, no-login quiz game for Singapore A-level Physics and PSLE Science/Maths. Race friends in live rooms, play hot-potato "Hot Core", or take the 4-question Daily Test ranked on a bell curve.`
- **Maker's first comment:** the story of why you built it, plus what feedback you want.
- Launch mid-week at 12:01am PT (Product Hunt's day starts then). That's 3:01pm or 4:01pm SGT depending on daylight saving. Launching is free. Ask people to "check it out and leave feedback", **never** to upvote.

### Parent newsletter / resource-list pitch (short)

> Hi [Editor], a free PSLE Science and Maths practice game might suit your free-resources roundup: Paper One Duel (https://abcdef1000.github.io/paper-duels/). No account, no payment, a daily 4-question test plus multiplayer rooms. Happy to provide screenshots. Thank you!
