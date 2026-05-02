"""Хелперы для сборки уроков в формате seed_data.json."""
from __future__ import annotations

from typing import Any


def block_text(ru: str, en: str) -> dict[str, Any]:
    return {"type": "text", "content_ru": ru, "content_en": en}


def block_tip(ru: str, en: str) -> dict[str, Any]:
    return {"type": "tip", "content_ru": ru, "content_en": en}


def block_vocab(items: list[dict[str, str]]) -> dict[str, Any]:
    return {"type": "vocabulary_table", "items": items}


def block_grammar(rows: list[list[str]]) -> dict[str, Any]:
    return {"type": "grammar_table", "rows": rows}


def vocab_row(lat: str, cyr: str, ru: str, en: str) -> dict[str, str]:
    return {"isv_lat": lat, "isv_cyr": cyr, "ru": ru, "en": en}


def theory(title_ru: str, title_en: str, blocks: list[dict[str, Any]]) -> dict[str, Any]:
    return {"title_ru": title_ru, "title_en": title_en, "blocks": blocks}


def ex_word_match(
    pairs: list[dict[str, str]],
    ru_ins: str,
    en_ins: str,
    xp: int = 12,
    hint_ru: str = "",
    hint_en: str = "",
) -> dict[str, Any]:
    return {
        "type": "word_match",
        "instruction_ru": ru_ins,
        "instruction_en": en_ins,
        "pairs": pairs,
        "xp": xp,
        "hint_ru": hint_ru or "Памятайте: корни часто близки к русским.",
        "hint_en": hint_en or "Remember: roots are often close to Russian.",
    }


def ex_multiple_choice(
    q_lat: str,
    q_cyr: str,
    options_ru: list[str],
    options_en: list[str],
    correct_index: int,
    ru_ins: str,
    en_ins: str,
    xp: int = 12,
    hint_ru: str = "",
    hint_en: str = "",
) -> dict[str, Any]:
    return {
        "type": "multiple_choice",
        "instruction_ru": ru_ins,
        "instruction_en": en_ins,
        "question_isv_lat": q_lat,
        "question_isv_cyr": q_cyr,
        "options_ru": options_ru,
        "options_en": options_en,
        "correct_index": correct_index,
        "xp": xp,
        "hint_ru": hint_ru,
        "hint_en": hint_en,
    }


def ex_fill_blank(
    sent_lat: str,
    sent_cyr: str,
    ans_lat: str,
    ans_cyr: str,
    tr_ru: str,
    tr_en: str,
    ru_ins: str,
    en_ins: str,
    xp: int = 15,
    hint_ru: str = "",
    hint_en: str = "",
) -> dict[str, Any]:
    return {
        "type": "fill_blank",
        "instruction_ru": ru_ins,
        "instruction_en": en_ins,
        "sentence_isv_lat": sent_lat,
        "sentence_isv_cyr": sent_cyr,
        "answer_isv_lat": ans_lat,
        "answer_isv_cyr": ans_cyr,
        "translation_ru": tr_ru,
        "translation_en": tr_en,
        "xp": xp,
        "hint_ru": hint_ru,
        "hint_en": hint_en,
    }


def ex_text_input(
    prompt_ru: str,
    prompt_en: str,
    ans_lat: str,
    ans_cyr: str,
    ru_ins: str,
    en_ins: str,
    xp: int = 18,
    hint_ru: str = "",
    hint_en: str = "",
) -> dict[str, Any]:
    return {
        "type": "text_input",
        "instruction_ru": ru_ins,
        "instruction_en": en_ins,
        "prompt_ru": prompt_ru,
        "prompt_en": prompt_en,
        "answer_isv_lat": ans_lat,
        "answer_isv_cyr": ans_cyr,
        "xp": xp,
        "hint_ru": hint_ru,
        "hint_en": hint_en,
    }


def lesson(
    lid: str,
    cat_id: str,
    order: int,
    title_ru: str,
    title_en: str,
    theory_obj: dict[str, Any],
    exercises: list[dict[str, Any]],
) -> dict[str, Any]:
    return {
        "id": lid,
        "category_id": cat_id,
        "title_ru": title_ru,
        "title_en": title_en,
        "order": order,
        "theory": theory_obj,
        "exercises": exercises,
    }


def category(
    cid: str,
    order: int,
    title_ru: str,
    title_en: str,
    title_isv_lat: str,
    title_isv_cyr: str,
    icon: str,
) -> dict[str, Any]:
    return {
        "id": cid,
        "order": order,
        "title_ru": title_ru,
        "title_en": title_en,
        "title_isv_lat": title_isv_lat,
        "title_isv_cyr": title_isv_cyr,
        "icon": icon,
    }
