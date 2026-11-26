#!/usr/bin/env python3
"""Validate every pack registered in docs/packs.json against QUESTION_FORMAT.md.

    python3 tools/validate_packs.py              # check all packs
    python3 tools/validate_packs.py --prefixes   # list id prefixes already in use

Exit code 0 and "OK" when everything passes; otherwise a list of errors."""
import json, os, re, sys
from collections import Counter

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
DOCS = os.path.join(ROOT, "docs")
FIG_TAGS = {"svg", "line", "path", "polyline", "polygon", "rect", "circle", "ellipse", "text", "g"}
FIG_ATTRS = {"viewBox", "role", "aria-label", "class", "x", "y", "x1", "y1", "x2", "y2", "cx", "cy", "r", "rx", "ry",
             "width", "height", "d", "points", "text-anchor", "transform"}
FIG_CLASSES = {"hollow", "solid", "ac", "acf", "thick", "guide", "dim", "dash", "hd", "muted", "acfill", "solidline"}


def check_fig(fig, where, errors):
    if not isinstance(fig, str) or not fig.startswith("<svg "):
        errors.append(f"{where}: fig must be an SVG string starting with <svg ")
        return
    if "aria-label=" not in fig.split(">", 1)[0]:
        errors.append(f"{where}: fig's <svg> needs an aria-label describing the figure")
    for m in re.finditer(r"<\s*/?\s*([a-zA-Z][\w:-]*)([^>]*)>", fig):
        tag, attrs = m.group(1), m.group(2)
        if tag not in FIG_TAGS:
            errors.append(f"{where}: fig uses <{tag}>, which isn't allowed")
        for a, v in re.findall(r"([\w:-]+)\s*=\s*'([^']*)'", attrs) + re.findall(r'([\w:-]+)\s*=\s*"([^"]*)"', attrs):
            if a not in FIG_ATTRS:
                errors.append(f"{where}: fig attribute {a!r} isn't allowed")
            if a == "class":
                bad = set(v.split()) - FIG_CLASSES
                if bad:
                    errors.append(f"{where}: fig classes {sorted(bad)} aren't allowed")
    if re.search(r"javascript:|on\w+\s*=|<script|href|style\s*=", fig, re.I):
        errors.append(f"{where}: fig contains scripts, links, styles or event attributes")


def check_question(q, i, topics, errors):
    where = f"question {i + 1} ({q.get('id', '?')})"
    if not isinstance(q.get("id"), str) or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.:-]{1,40}", q.get("id", "")):
        errors.append(f"{where}: id must be 2–41 characters of letters, digits, - _ . :")
    if q.get("topic") not in topics:
        errors.append(f"{where}: topic {q.get('topic')!r} isn't listed in sections")
    t = q.get("type", "mcq")
    if t not in ("mcq", "short"):
        errors.append(f"{where}: type must be 'mcq' or 'short'")
    if not isinstance(q.get("q"), str) or len(q["q"].strip()) < 5:
        errors.append(f"{where}: q (the question) is missing or too short")
    elif "<" in q["q"] and re.search(r"<\s*[a-zA-Z/]", q["q"]):
        errors.append(f"{where}: q must be plain text, not HTML")
    if t == "mcq":
        o = q.get("o")
        if not (isinstance(o, list) and len(o) == 4 and all(isinstance(s, str) and s.strip() for s in o)):
            errors.append(f"{where}: o must be a list of exactly 4 non-empty strings")
        elif len({s.strip().lower() for s in o}) != 4:
            errors.append(f"{where}: the 4 options must be different")
        if not (isinstance(q.get("a"), int) and 0 <= q["a"] <= 3):
            errors.append(f"{where}: a must be the index 0–3 of the correct option")
    else:
        ans, num = q.get("answers"), q.get("num")
        if ans is None and num is None:
            errors.append(f"{where}: a short question needs answers and/or num")
        if ans is not None and not (isinstance(ans, list) and ans and all(isinstance(s, str) and s.strip() for s in ans)):
            errors.append(f"{where}: answers must be a non-empty list of strings")
        if num is not None and not (isinstance(num, dict) and isinstance(num.get("value"), (int, float)) and isinstance(num.get("tol", 0), (int, float)) and num.get("tol", 0) >= 0):
            errors.append(f"{where}: num must be {{\"value\": number, \"tol\": number ≥ 0, \"unit\": string}}")
    if not isinstance(q.get("x"), str) or len(q["x"].strip()) < 10:
        errors.append(f"{where}: x (the explanation) is missing or too short")
    elif re.search(r"\b(option|answer|choice)\s+[A-D]\b|\b[A-D] is (correct|right|wrong)\b", q["x"]):
        errors.append(f"{where}: x refers to an option letter, but options are shuffled")
    if q.get("d") not in (1, 2, 3, 4):
        errors.append(f"{where}: d (difficulty) must be 1, 2, 3 or 4")
    if "quick" in q and not isinstance(q["quick"], bool):
        errors.append(f"{where}: quick must be true or false")
    if "fig" in q:
        check_fig(q["fig"], where, errors)
    if "of" in q:
        if t != "mcq" or not (isinstance(q["of"], list) and len(q["of"]) == 4):
            errors.append(f"{where}: of (picture options) must be a list of 4 SVG strings on an mcq question")
        else:
            for k, f in enumerate(q["of"]):
                check_fig(f, f"{where} option {k + 1}", errors)
    unknown = set(q) - {"id", "topic", "type", "q", "o", "a", "answers", "num", "x", "d", "quick", "fig", "of"}
    if unknown:
        errors.append(f"{where}: unknown fields {sorted(unknown)}")


def main():
    registry = json.load(open(os.path.join(DOCS, "packs.json"), encoding="utf-8"))
    errors, all_ids, prefixes = [], Counter(), {}
    keys = Counter(p.get("key") for p in registry)
    for k, n in keys.items():
        if n > 1:
            errors.append(f"packs.json: key {k!r} is used {n} times")
    for entry in registry:
        for f in ("key", "file", "name", "tag"):
            if not isinstance(entry.get(f), str) or not entry[f]:
                errors.append(f"packs.json: entry {entry} is missing {f}")
        path = os.path.join(DOCS, entry.get("file", ""))
        if not os.path.isfile(path):
            errors.append(f"packs.json: {entry.get('file')} doesn't exist in docs/")
            continue
        try:
            pack = json.load(open(path, encoding="utf-8"))
        except json.JSONDecodeError as e:
            errors.append(f"{entry['file']}: not valid JSON ({e})")
            continue
        pe = []
        secs = pack.get("sections")
        if not (isinstance(secs, list) and secs and all(isinstance(s.get("name"), str) and isinstance(s.get("topics"), list) and s["topics"] for s in secs)):
            pe.append("sections must be a non-empty list of {name, topics: [..]}")
            topics = set()
        else:
            topics = {t for s in secs for t in s["topics"]}
        qs = pack.get("questions")
        if not (isinstance(qs, list) and qs):
            pe.append("questions must be a non-empty list")
            qs = []
        for i, q in enumerate(qs):
            if not isinstance(q, dict):
                pe.append(f"question {i + 1} isn't an object")
                continue
            check_question(q, i, topics, pe)
            if isinstance(q.get("id"), str):
                all_ids[q["id"]] += 1
                prefixes.setdefault(q["id"].split("-")[0], set()).add(entry["key"])
        tiers = Counter(q.get("d") for q in qs if isinstance(q, dict))
        missing = [d for d in (1, 2, 3, 4) if not tiers.get(d)]
        if missing:
            pe.append(f"no questions with difficulty {missing}; the Daily Test needs every tier")
        used = {q.get("topic") for q in qs if isinstance(q, dict)}
        empty = sorted(topics - used)
        if empty:
            pe.append(f"topics with no questions: {empty}")
        errors += [f"{entry['file']}: {e}" for e in pe]
        print(f"{entry['name']}: {len(qs)} questions, tiers {dict(sorted(tiers.items()))}, "
              f"{sum(1 for q in qs if isinstance(q, dict) and q.get('type') == 'short')} short-answer")
    for i, n in all_ids.items():
        if n > 1:
            errors.append(f"id {i!r} appears {n} times across packs")
    if "--prefixes" in sys.argv:
        for p, ks in sorted(prefixes.items()):
            print(f"  {p}-  used by {', '.join(sorted(ks))}")
    if errors:
        print(f"\n{len(errors)} problem(s):")
        for e in errors:
            print("  - " + e)
        sys.exit(1)
    print("OK")


if __name__ == "__main__":
    main()
