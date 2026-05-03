#!/usr/bin/env python3
"""
Читает course_import/full_course.json и пишет supabase/course_import_generated.sql

Запуск из корня репозитория:
  python tool/generate_course_import.py
  python tool/export_course_import_to_sql.py
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "course_import" / "full_course.json"
OUT = ROOT / "supabase" / "course_import_generated.sql"


def sql_text(s: str) -> str:
    return "'" + str(s).replace("'", "''") + "'"


def dollar_json(obj: dict) -> str:
    raw = json.dumps(obj, ensure_ascii=False)
    tag = "j"
    while f"${tag}$" in raw:
        tag += "x"
    return f"${tag}${raw}${tag}$::jsonb"


def main() -> None:
    if not SRC.is_file():
        raise SystemExit(f"Сначала сгенерируйте JSON: python tool/generate_course_import.py\nНет файла: {SRC}")

    data = json.loads(SRC.read_text(encoding="utf-8"))

    lines: list[str] = [
        "-- Автогенерация: python tool/export_course_import_to_sql.py",
        "BEGIN;",
        "",
    ]

    for cat in data["categories"]:
        cid = cat["id"]
        order = int(cat.get("order") or 0)
        lines.append(
            "INSERT INTO public.course_categories "
            "(id, sort_order, title_ru, title_en, title_isv_lat, title_isv_cyr, icon) "
            f"VALUES ({sql_text(cid)}, {order}, "
            f"{sql_text(cat['title_ru'])}, {sql_text(cat['title_en'])}, "
            f"{sql_text(cat.get('title_isv_lat') or '')}, "
            f"{sql_text(cat.get('title_isv_cyr') or '')}, "
            f"{sql_text(cat.get('icon') or 'school')}) "
            "ON CONFLICT (id) DO UPDATE SET "
            "sort_order = EXCLUDED.sort_order, "
            "title_ru = EXCLUDED.title_ru, "
            "title_en = EXCLUDED.title_en, "
            "title_isv_lat = EXCLUDED.title_isv_lat, "
            "title_isv_cyr = EXCLUDED.title_isv_cyr, "
            "icon = EXCLUDED.icon;",
        )

    lines.append("")

    for lesson in data["lessons"]:
        lid = lesson["id"]
        cat_id = lesson["category_id"]
        sort_order = int(lesson.get("order") or 0)
        payload = dollar_json(lesson)
        lines.append(
            "INSERT INTO public.course_lessons "
            "(id, category_id, sort_order, payload) "
            f"VALUES ({sql_text(lid)}, {sql_text(cat_id)}, {sort_order}, {payload}) "
            "ON CONFLICT (id) DO UPDATE SET "
            "category_id = EXCLUDED.category_id, "
            "sort_order = EXCLUDED.sort_order, "
            "payload = EXCLUDED.payload;",
        )

    lines.extend(["", "COMMIT;", ""])
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"OK -> {OUT} ({OUT.stat().st_size // 1024} KiB)")


if __name__ == "__main__":
    main()
