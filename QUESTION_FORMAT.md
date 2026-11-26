# Orbit Station question packs

Every subject in the game is a **pack**: one JSON file in `docs/` plus one entry in `docs/packs.json`. To add a subject, write a pack file, register it, and run the validator. No game code changes are needed.

This file is the brief for anyone writing questions, including AI agents. Read it fully before writing a pack.

## Workflow

1. Pick a short pack key (`chem`, `psle-eng`, `h2-econ`) and an ID prefix (`HC-`, `PE-`) that no other pack uses. Run `python3 tools/validate_packs.py --prefixes` to see which prefixes are taken.
2. Write `docs/<file>.json` in the format below.
3. Add an entry to `docs/packs.json`:
   ```json
   { "key": "chem", "file": "h2-chemistry.json", "name": "H2 Chemistry", "tag": "Orbit Station · H2 Chemistry 9476 · Paper 1 style" }
   ```
4. Run `python3 tools/validate_packs.py`. Fix every error and re-run until it prints `OK`.
5. Run `test/run.sh` if you changed anything besides pack files.
6. For Roblox, run `python3 roblox/tools/json2luau.py`. Short-answer questions and questions with figures are skipped there.

## File format

```json
{
  "format": "orbit-pack/1",
  "name": "H2 Chemistry",
  "constants": "Avogadro constant L = 6.02 × 10²³ mol⁻¹, …",
  "sections": [
    { "name": "Physical Chemistry", "topics": ["Atoms and Molecules", "Chemical Energetics"] }
  ],
  "questions": [ … ]
}
```

- `constants` is optional. It's shown in a collapsible "Data" box under every question. Leave it `""` if the subject has none.
- `sections` group `topics`. Every question's `topic` must be one of these topics. Aim for 2–5 questions per topic at the start.

### A multiple-choice question

```json
{
  "id": "HC-ENG-01",
  "topic": "Chemical Energetics",
  "type": "mcq",
  "q": "What is the enthalpy change when 2.0 mol of methane burns completely? (ΔHc of methane = −890 kJ mol⁻¹)",
  "o": ["−445 kJ", "−890 kJ", "−1780 kJ", "+1780 kJ"],
  "a": 2,
  "x": "Enthalpy change scales with amount: 2.0 × (−890) = −1780 kJ.",
  "d": 2,
  "quick": true
}
```

### A short-answer question

```json
{
  "id": "HC-ENG-02",
  "topic": "Chemical Energetics",
  "type": "short",
  "q": "Name the law that says the enthalpy change of a reaction is independent of the route taken.",
  "answers": ["Hess's law", "Hess law", "Hess"],
  "x": "Hess's law: the total enthalpy change is the same whichever route connects the same start and end states.",
  "d": 1,
  "quick": true
}
```

For a numerical short answer, use `num` instead of (or as well as) `answers`:

```json
"num": { "value": 2.4, "tol": 0.05, "unit": "V" }
```

`tol` is the accepted absolute error. The player types `2.4`, `2.40` or `2.4 V`; the first number in their answer is compared. Put the unit in the question ("Give your answer in V.") and in `unit`, which is shown with the correct answer on reveal.

### Fields

| field | required | meaning |
|---|---|---|
| `id` | yes | Unique across **all** packs. Use `<PREFIX>-<TOPICCODE>-<NN>`. Never reuse or renumber an id: player progress is keyed on it. |
| `topic` | yes | One of the pack's topics. |
| `type` | no | `"mcq"` (default) or `"short"`. |
| `q` | yes | The question stem. Plain text, no HTML. Use Unicode for maths: `×`, `÷`, `²`, `³`, `⁻¹`, `√`, `π`, `Ω`, `μ`, `λ`, `θ`, `°`. |
| `o` | mcq | Exactly 4 distinct options, plain text. Order doesn't matter: the game shuffles them. |
| `a` | mcq | Index (0–3) of the correct option in `o`. |
| `answers` | short | Accepted answers. Matching ignores case, extra spaces and end punctuation. List common spellings. |
| `num` | short | `{ "value": number, "tol": number, "unit": "string" }` for numerical answers. |
| `x` | yes | The worked explanation shown after answering: 1–3 sentences, with the key step and numbers. Never refer to an option letter ("B is right"), because options are shuffled. |
| `d` | yes | Difficulty 1–4: 1 recall, 2 one-step application, 3 multi-step, 4 hardest in the syllabus. The Daily Test takes one question from each tier, so give every pack some of each. |
| `quick` | no | `true` if it can be done in your head in under ~30 s with the constants given. Hot Core mode uses these. |
| `fig` | no | An inline SVG diagram. See Figures below. Official packs only. |

## Writing good questions

- **Correct first.** Work every answer out, and check the arithmetic twice. A wrong answer key is the worst possible bug.
- **Original wording.** Don't copy questions from past papers, school prelims, assessment books or websites; they're copyrighted. Write new questions in the same style and at the same level.
- **Distractors are real mistakes:** forgetting a ½, a unit slip, using °C instead of K, the wrong formula, a reversed ratio. Explain the trap in `x` where useful.
- **Give what's needed.** If a value or constant is needed and isn't in `constants`, put it in the stem. Round numbers make mental maths possible.
- **One clear answer.** No "all of the above", and no options that are both defensibly right.
- **Match the syllabus** named in the pack's `tag`, e.g. SEAB 9478 for H2 Physics, or the current PSLE syllabus.
- **Spread the difficulty.** Roughly a quarter of the pack in each tier.

## Figures (official packs)

`fig` is an SVG string whose root is `<svg viewBox='0 0 W H' role='img' aria-label='…'>`. Use single quotes inside it. To follow the theme it may only use:

- shapes: `line`, `path`, `polyline`, `polygon`, `rect`, `circle`, `ellipse`, `text`, `g`
- classes: `hollow` (outlined shape), `solid` (filled), `ac` (accent stroke), `acf` (accent fill), `thick`, `guide` (dashed), `dim` (dimension line), `dash`, `hd` (arrowhead), `muted` / `acfill` (text)
- no colours, `style` attributes, scripts, links, images or event attributes

Write `aria-label` as a full description of the figure. The validator rejects anything else. Render your figures and look at them: labels must not overlap or be clipped. `roblox/tools/json2luau.py` drops questions with figures.

Player-made packs (created in the game's Packs tab) can't contain figures.
