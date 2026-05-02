#!/usr/bin/env python3
"""Усиливает подсказки в seed_data: добавляет отсылку к словам из теории урока."""

from __future__ import annotations

import json
import re
from pathlib import Path


def collect_vocab_from_theory(theory: dict) -> tuple[list[str], list[str]]:
    isv_words: list[str] = []
    ru_words: list[str] = []
    for block in theory.get("blocks") or []:
        if block.get("type") != "vocabulary_table":
            continue
        for it in block.get("items") or []:
            lat = (it.get("isv_lat") or "").strip()
            if lat and lat not in isv_words:
                isv_words.append(lat)
            ru = (it.get("ru") or "").strip()
            if ru and ru not in ru_words:
                ru_words.append(ru)
    return isv_words[:14], ru_words[:14]


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    path = root / "interslavic_learn" / "assets" / "data" / "seed_data.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    lessons = data.get("lessons") or []
    touched = 0

    for lesson in lessons:
        theory = lesson.get("theory") or {}
        isv_vocab, ru_vocab = collect_vocab_from_theory(theory)
        if not isv_vocab:
            continue

        isv_line = ", ".join(isv_vocab[:10])
        ru_line = ", ".join(ru_vocab[:10])
        add_ru = f" Сверьтесь с таблицей теории: {isv_line} ({ru_line})." if ru_line else f" Сверьтесь с таблицей теории: {isv_line}."
        add_en = f" Check the lesson vocabulary: {isv_line}."

        for ex in lesson.get("exercises") or []:
            hr = (ex.get("hint_ru") or "").strip()
            he = (ex.get("hint_en") or "").strip()
            if "Сверьтесь с таблицей теории" in hr or "Check the lesson vocabulary" in he:
                continue
            if hr:
                ex["hint_ru"] = (hr + add_ru).strip()
                touched += 1
            else:
                ex["hint_ru"] = add_ru.strip()
                touched += 1
            if he:
                ex["hint_en"] = (he + " " + add_en).strip()
            else:
                ex["hint_en"] = add_en.strip()

    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"OK: усилено подсказок: {touched}, файл: {path}")


if __name__ == "__main__":
    main()
