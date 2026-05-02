#!/usr/bin/env python3
"""
Собирает course_import/full_course.json из генератора course_gen/.

Запуск из корня репозитория:
  python tool/generate_course_import.py
"""
from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tool"))

from course_gen.curriculum import build_categories_and_lessons  # noqa: E402
from course_gen.syllabus import merge_with_full_syllabus  # noqa: E402


def main() -> None:
    cats_raw, les = build_categories_and_lessons()
    cats = merge_with_full_syllabus(cats_raw)
    data = {
        "version": "2.0.0",
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "note": "Сгенерировано tool/generate_course_import.py — дополняйте course_gen/curriculum_extend.py",
        "categories": cats,
        "lessons": les,
    }
    dest = ROOT / "course_import" / "full_course.json"
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"OK: {len(cats)} categories, {len(les)} lessons -> {dest}")


if __name__ == "__main__":
    main()
