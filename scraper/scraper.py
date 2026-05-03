#!/usr/bin/env python3
"""
Scraper for interslavic.fun — extracts grammar theory, vocabulary,
and audio links, then outputs structured JSON seed data for the
Interslavic Learn Flutter app.

Etiquette: between HTTP requests use time.sleep(0.5–1.5) (already used in
loops) so as not to hammer interslavic.fun. Increase delay if you get 429/503.
After a successful run, copy data/seed_data.json to
interslavic_learn/assets/data/seed_data.json (single source of truth for the app build).
"""

import json
import os
import re
import time
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup

BASE_URL = "https://interslavic.fun"
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "data")

GRAMMAR_PAGES = [
    "/learn/grammar/nouns",
    "/learn/grammar/adjectives",
    "/learn/grammar/pronouns",
    "/learn/grammar/numerals",
    "/learn/grammar/verbs",
    "/learn/grammar/prepositions",
    "/learn/grammar/conjunctions",
    "/learn/grammar/syntax",
    "/learn/grammar/phonology",
    "/learn/grammar/orthography",
]

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (compatible; InterslavicLearnBot/1.0; "
        "educational scraper)"
    ),
}


def fetch_page(url: str) -> BeautifulSoup | None:
    """Fetch a page and return parsed BeautifulSoup object."""
    try:
        resp = requests.get(url, headers=HEADERS, timeout=30)
        resp.raise_for_status()
        return BeautifulSoup(resp.text, "html.parser")
    except requests.RequestException as e:
        print(f"  [WARN] Failed to fetch {url}: {e}")
        return None


def extract_text_blocks(soup: BeautifulSoup) -> list[dict]:
    """Extract structured text blocks from a grammar page."""
    article = soup.select_one("article") or soup.select_one("main") or soup
    blocks: list[dict] = []
    current_section = ""

    for el in article.find_all(["h1", "h2", "h3", "h4", "p", "ul", "ol", "table"]):
        tag = el.name
        if tag in ("h1", "h2", "h3", "h4"):
            current_section = el.get_text(strip=True)
            blocks.append({
                "type": "heading",
                "level": int(tag[1]),
                "text": current_section,
            })
        elif tag == "p":
            text = el.get_text(strip=True)
            if text:
                blocks.append({
                    "type": "paragraph",
                    "section": current_section,
                    "text": text,
                })
        elif tag in ("ul", "ol"):
            items = [li.get_text(strip=True) for li in el.find_all("li")]
            if items:
                blocks.append({
                    "type": "list",
                    "section": current_section,
                    "ordered": tag == "ol",
                    "items": items,
                })
        elif tag == "table":
            rows: list[list[str]] = []
            for tr in el.find_all("tr"):
                cells = [
                    td.get_text(strip=True)
                    for td in tr.find_all(["th", "td"])
                ]
                if cells:
                    rows.append(cells)
            if rows:
                blocks.append({
                    "type": "table",
                    "section": current_section,
                    "rows": rows,
                })

    return blocks


def extract_audio_links(soup: BeautifulSoup, page_url: str) -> list[dict]:
    """Extract audio file links from the page."""
    audio_links: list[dict] = []
    for audio_tag in soup.find_all("audio"):
        for source in audio_tag.find_all("source"):
            src = source.get("src", "")
            if src:
                audio_links.append({
                    "url": urljoin(page_url, src),
                    "type": source.get("type", "audio/mpeg"),
                })
    # Also check for direct links to audio files
    for a_tag in soup.find_all("a", href=True):
        href = a_tag["href"]
        if any(href.endswith(ext) for ext in (".mp3", ".ogg", ".wav")):
            audio_links.append({
                "url": urljoin(page_url, href),
                "type": "audio/mpeg",
            })
    return audio_links


def scrape_grammar() -> list[dict]:
    """Scrape all grammar pages."""
    grammar_data: list[dict] = []

    for path in GRAMMAR_PAGES:
        url = BASE_URL + path
        topic = path.split("/")[-1].capitalize()
        print(f"  Scraping grammar: {topic} ({url})")

        soup = fetch_page(url)
        if not soup:
            continue

        blocks = extract_text_blocks(soup)
        audio = extract_audio_links(soup, url)

        grammar_data.append({
            "id": f"grammar_{path.split('/')[-1]}",
            "topic": topic,
            "url": url,
            "blocks": blocks,
            "audio_links": audio,
        })

        time.sleep(1)  # Be polite

    return grammar_data


def scrape_vocabulary() -> list[dict]:
    """Scrape vocabulary from the interslavic dictionary API."""
    print("  Fetching vocabulary from interslavic-dictionary API...")
    vocab_url = (
        "https://raw.githubusercontent.com/medzuslovjansky/"
        "database/main/data/words.json"
    )
    try:
        resp = requests.get(vocab_url, headers=HEADERS, timeout=60)
        resp.raise_for_status()
        raw_words = resp.json()
    except Exception as e:
        print(f"  [WARN] Could not fetch dictionary data: {e}")
        raw_words = []

    vocabulary: list[dict] = []
    for i, word in enumerate(raw_words[:2000]):  # Limit for MVP
        entry: dict = {
            "id": f"word_{i}",
        }
        if isinstance(word, dict):
            entry["isv_latin"] = word.get("isv", word.get("interslavic", ""))
            entry["isv_cyrillic"] = word.get("isv_cyrillic", "")
            entry["en"] = word.get("en", word.get("english", ""))
            entry["ru"] = word.get("ru", word.get("russian", ""))
            entry["part_of_speech"] = word.get(
                "partOfSpeech", word.get("pos", "")
            )
            entry["details"] = word.get("details", "")
        else:
            entry["isv_latin"] = str(word)
            entry["en"] = ""
            entry["ru"] = ""

        if entry.get("isv_latin"):
            vocabulary.append(entry)

    return vocabulary


def build_seed_data(
    grammar: list[dict], vocabulary: list[dict]
) -> dict:
    """Build the final structured seed data for the app."""

    # Organize vocabulary into thematic categories
    categories = [
        {
            "id": "cat_basics",
            "title_ru": "Основы",
            "title_en": "Basics",
            "title_isv_lat": "Osnovy",
            "title_isv_cyr": "Основы",
            "icon": "school",
            "order": 0,
        },
        {
            "id": "cat_greetings",
            "title_ru": "Приветствия",
            "title_en": "Greetings",
            "title_isv_lat": "Pozdravy",
            "title_isv_cyr": "Поздравы",
            "icon": "waving_hand",
            "order": 1,
        },
        {
            "id": "cat_food",
            "title_ru": "Еда и напитки",
            "title_en": "Food & Drinks",
            "title_isv_lat": "Jedlo i napitky",
            "title_isv_cyr": "Једло и напиткы",
            "icon": "restaurant",
            "order": 2,
        },
        {
            "id": "cat_family",
            "title_ru": "Семья",
            "title_en": "Family",
            "title_isv_lat": "Rodina",
            "title_isv_cyr": "Родина",
            "icon": "family_restroom",
            "order": 3,
        },
        {
            "id": "cat_numbers",
            "title_ru": "Числа",
            "title_en": "Numbers",
            "title_isv_lat": "Čisla",
            "title_isv_cyr": "Числа",
            "icon": "pin",
            "order": 4,
        },
        {
            "id": "cat_colors",
            "title_ru": "Цвета",
            "title_en": "Colors",
            "title_isv_lat": "Barvy",
            "title_isv_cyr": "Барвы",
            "icon": "palette",
            "order": 5,
        },
        {
            "id": "cat_travel",
            "title_ru": "Путешествия",
            "title_en": "Travel",
            "title_isv_lat": "Putovanje",
            "title_isv_cyr": "Путовање",
            "icon": "flight",
            "order": 6,
        },
        {
            "id": "cat_nouns",
            "title_ru": "Грамматика: Существительные",
            "title_en": "Grammar: Nouns",
            "title_isv_lat": "Gramatika: Imenniky",
            "title_isv_cyr": "Граматика: Именникы",
            "icon": "menu_book",
            "order": 7,
        },
        {
            "id": "cat_verbs",
            "title_ru": "Грамматика: Глаголы",
            "title_en": "Grammar: Verbs",
            "title_isv_lat": "Gramatika: Glagoly",
            "title_isv_cyr": "Граматика: Глаголы",
            "icon": "menu_book",
            "order": 8,
        },
        {
            "id": "cat_adjectives",
            "title_ru": "Грамматика: Прилагательные",
            "title_en": "Grammar: Adjectives",
            "title_isv_lat": "Gramatika: Prilagateljniky",
            "title_isv_cyr": "Граматика: Прилагатељникы",
            "icon": "menu_book",
            "order": 9,
        },
        {
            "id": "cat_pronouns",
            "title_ru": "Грамматика: Местоимения",
            "title_en": "Grammar: Pronouns",
            "title_isv_lat": "Gramatika: Zaimenniki",
            "title_isv_cyr": "Граматика: Заименникы",
            "icon": "menu_book",
            "order": 10,
        },
        {
            "id": "cat_prepositions",
            "title_ru": "Грамматика: Предлоги",
            "title_en": "Grammar: Prepositions",
            "title_isv_lat": "Gramatika: Predlogy",
            "title_isv_cyr": "Граматика: Предлогы",
            "icon": "menu_book",
            "order": 11,
        },
    ]

    # Build lessons with theory and exercises for each category
    lessons = _build_lessons(categories, grammar, vocabulary)

    return {
        "version": "1.0.0",
        "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "categories": categories,
        "lessons": lessons,
        "grammar": grammar,
        "vocabulary": vocabulary[:500],  # Include top 500 for seed
    }


def _build_lessons(
    categories: list[dict],
    grammar: list[dict],
    vocabulary: list[dict],
) -> list[dict]:
    """Build lesson structures with theory and exercises."""
    lessons: list[dict] = []

    # Basic greetings lesson
    lessons.append({
        "id": "lesson_greetings_1",
        "category_id": "cat_greetings",
        "title_ru": "Приветствия и знакомство",
        "title_en": "Greetings & Introductions",
        "order": 0,
        "theory": {
            "title_ru": "Приветствия в межславянском",
            "title_en": "Greetings in Interslavic",
            "blocks": [
                {
                    "type": "text",
                    "content_ru": "В межславянском языке приветствия очень похожи на те, что используются в других славянских языках. Это делает их легко узнаваемыми.",
                    "content_en": "In Interslavic, greetings are very similar to those used in other Slavic languages. This makes them easily recognizable.",
                },
                {
                    "type": "vocabulary_table",
                    "items": [
                        {"isv_lat": "Zdrav budi!", "isv_cyr": "Здрав буди!", "ru": "Здравствуй!", "en": "Hello!"},
                        {"isv_lat": "Dobry denj!", "isv_cyr": "Добры день!", "ru": "Добрый день!", "en": "Good day!"},
                        {"isv_lat": "Dobro jutro!", "isv_cyr": "Добро јутро!", "ru": "Доброе утро!", "en": "Good morning!"},
                        {"isv_lat": "Dobry večer!", "isv_cyr": "Добры вечер!", "ru": "Добрый вечер!", "en": "Good evening!"},
                        {"isv_lat": "Do viděnja!", "isv_cyr": "До видєња!", "ru": "До свидания!", "en": "Goodbye!"},
                        {"isv_lat": "Prosim", "isv_cyr": "Просим", "ru": "Пожалуйста", "en": "Please"},
                        {"isv_lat": "Hvala", "isv_cyr": "Хвала", "ru": "Спасибо", "en": "Thank you"},
                        {"isv_lat": "Da", "isv_cyr": "Да", "ru": "Да", "en": "Yes"},
                        {"isv_lat": "Ne", "isv_cyr": "Не", "ru": "Нет", "en": "No"},
                    ],
                },
                {
                    "type": "tip",
                    "content_ru": "Обратите внимание: многие слова похожи на русские! Корни слов общие для славянских языков.",
                    "content_en": "Notice: many words look similar to Russian! Word roots are shared across Slavic languages.",
                },
            ],
        },
        "exercises": [
            {
                "type": "word_match",
                "instruction_ru": "Соедините слова с их переводом",
                "instruction_en": "Match words with their translation",
                "pairs": [
                    {"isv_lat": "Zdrav budi!", "isv_cyr": "Здрав буди!", "ru": "Здравствуй!", "en": "Hello!"},
                    {"isv_lat": "Hvala", "isv_cyr": "Хвала", "ru": "Спасибо", "en": "Thank you"},
                    {"isv_lat": "Prosim", "isv_cyr": "Просим", "ru": "Пожалуйста", "en": "Please"},
                    {"isv_lat": "Do viděnja!", "isv_cyr": "До видєња!", "ru": "До свидания!", "en": "Goodbye!"},
                ],
                "hint_ru": "Подумайте о похожих словах в русском языке",
                "hint_en": "Think about similar words in Russian",
                "xp": 10,
            },
            {
                "type": "multiple_choice",
                "instruction_ru": "Переведите фразу",
                "instruction_en": "Translate the phrase",
                "question_isv_lat": "Dobry denj!",
                "question_isv_cyr": "Добры день!",
                "options_ru": ["Добрый день!", "Доброе утро!", "Добрый вечер!", "До свидания!"],
                "options_en": ["Good day!", "Good morning!", "Good evening!", "Goodbye!"],
                "correct_index": 0,
                "hint_ru": "Слово 'denj' похоже на русское 'день'",
                "hint_en": "The word 'denj' is similar to the Russian 'den' (day)",
                "xp": 10,
            },
            {
                "type": "fill_blank",
                "instruction_ru": "Заполните пропуск",
                "instruction_en": "Fill in the blank",
                "sentence_isv_lat": "Dobro ___!",
                "sentence_isv_cyr": "Добро ___!",
                "answer_isv_lat": "jutro",
                "answer_isv_cyr": "јутро",
                "translation_ru": "Доброе утро!",
                "translation_en": "Good morning!",
                "hint_ru": "Это слово означает 'утро' и похоже на русское слово",
                "hint_en": "This word means 'morning' and sounds similar to the Russian word",
                "xp": 15,
            },
            {
                "type": "text_input",
                "instruction_ru": "Напишите перевод на межславянском",
                "instruction_en": "Write the translation in Interslavic",
                "prompt_ru": "Спасибо",
                "prompt_en": "Thank you",
                "answer_isv_lat": "Hvala",
                "answer_isv_cyr": "Хвала",
                "hint_ru": "Это слово начинается на 'Hv...' и используется во многих славянских языках",
                "hint_en": "This word starts with 'Hv...' and is used in many Slavic languages",
                "xp": 20,
            },
        ],
    })

    # Basics lesson
    lessons.append({
        "id": "lesson_basics_1",
        "category_id": "cat_basics",
        "title_ru": "Основные слова и фразы",
        "title_en": "Basic Words & Phrases",
        "order": 0,
        "theory": {
            "title_ru": "Введение в межславянский",
            "title_en": "Introduction to Interslavic",
            "blocks": [
                {
                    "type": "text",
                    "content_ru": "Межславянский (Medžuslovjansky) — это конструированный язык, предназначенный для общения между носителями разных славянских языков. Он основан на общих корнях и грамматических формах славянских языков.",
                    "content_en": "Interslavic (Medžuslovjansky) is a constructed language designed for communication between speakers of different Slavic languages. It is based on common roots and grammatical forms of Slavic languages.",
                },
                {
                    "type": "text",
                    "content_ru": "Межславянский можно писать как латиницей, так и кириллицей. В этом приложении вы можете переключаться между ними в любой момент.",
                    "content_en": "Interslavic can be written in both Latin and Cyrillic scripts. In this app, you can switch between them at any time.",
                },
                {
                    "type": "vocabulary_table",
                    "items": [
                        {"isv_lat": "ja", "isv_cyr": "ја", "ru": "я", "en": "I"},
                        {"isv_lat": "ty", "isv_cyr": "ты", "ru": "ты", "en": "you (sg.)"},
                        {"isv_lat": "on/ona/ono", "isv_cyr": "он/она/оно", "ru": "он/она/оно", "en": "he/she/it"},
                        {"isv_lat": "my", "isv_cyr": "мы", "ru": "мы", "en": "we"},
                        {"isv_lat": "vy", "isv_cyr": "вы", "ru": "вы", "en": "you (pl.)"},
                        {"isv_lat": "oni", "isv_cyr": "они", "ru": "они", "en": "they"},
                        {"isv_lat": "jest", "isv_cyr": "јест", "ru": "есть (быть)", "en": "is"},
                        {"isv_lat": "imati", "isv_cyr": "имати", "ru": "иметь", "en": "to have"},
                        {"isv_lat": "htěti", "isv_cyr": "хтєти", "ru": "хотеть", "en": "to want"},
                        {"isv_lat": "mogti", "isv_cyr": "могти", "ru": "мочь", "en": "can"},
                    ],
                },
                {
                    "type": "tip",
                    "content_ru": "Межславянский — не один конкретный славянский язык. Он объединяет элементы из разных славянских языков, поэтому носители русского, польского, чешского и других языков легко его понимают.",
                    "content_en": "Interslavic is not one specific Slavic language. It combines elements from different Slavic languages, making it easily understood by speakers of Russian, Polish, Czech, and other languages.",
                },
            ],
        },
        "exercises": [
            {
                "type": "word_match",
                "instruction_ru": "Соедините местоимения с переводом",
                "instruction_en": "Match pronouns with their translation",
                "pairs": [
                    {"isv_lat": "ja", "isv_cyr": "ја", "ru": "я", "en": "I"},
                    {"isv_lat": "ty", "isv_cyr": "ты", "ru": "ты", "en": "you"},
                    {"isv_lat": "my", "isv_cyr": "мы", "ru": "мы", "en": "we"},
                    {"isv_lat": "oni", "isv_cyr": "они", "ru": "они", "en": "they"},
                ],
                "hint_ru": "Эти местоимения очень похожи на русские",
                "hint_en": "These pronouns are very similar to Russian",
                "xp": 10,
            },
            {
                "type": "multiple_choice",
                "instruction_ru": "Что означает 'imati'?",
                "instruction_en": "What does 'imati' mean?",
                "question_isv_lat": "imati",
                "question_isv_cyr": "имати",
                "options_ru": ["иметь", "хотеть", "мочь", "быть"],
                "options_en": ["to have", "to want", "can", "to be"],
                "correct_index": 0,
                "hint_ru": "Подумайте о русском слове 'иметь'",
                "hint_en": "Think about the word 'иметь' (to have) in Russian",
                "xp": 10,
            },
            {
                "type": "fill_blank",
                "instruction_ru": "Заполните пропуск",
                "instruction_en": "Fill in the blank",
                "sentence_isv_lat": "___ jest student.",
                "sentence_isv_cyr": "___ јест студент.",
                "answer_isv_lat": "On",
                "answer_isv_cyr": "Он",
                "translation_ru": "Он — студент.",
                "translation_en": "He is a student.",
                "hint_ru": "Местоимение 'он' в межславянском похоже на русское",
                "hint_en": "The pronoun 'he' in Interslavic is similar to Russian",
                "xp": 15,
            },
            {
                "type": "text_input",
                "instruction_ru": "Напишите местоимение 'мы' на межславянском",
                "instruction_en": "Write the pronoun 'we' in Interslavic",
                "prompt_ru": "мы",
                "prompt_en": "we",
                "answer_isv_lat": "my",
                "answer_isv_cyr": "мы",
                "hint_ru": "Это слово идентично русскому",
                "hint_en": "This word is identical to Russian",
                "xp": 20,
            },
        ],
    })

    # Food lesson
    lessons.append({
        "id": "lesson_food_1",
        "category_id": "cat_food",
        "title_ru": "Еда и напитки",
        "title_en": "Food & Drinks",
        "order": 0,
        "theory": {
            "title_ru": "Еда и напитки в межславянском",
            "title_en": "Food & Drinks in Interslavic",
            "blocks": [
                {
                    "type": "text",
                    "content_ru": "Названия многих продуктов питания в межславянском языке очень похожи на слова в других славянских языках. Это одна из самых простых тем для изучения!",
                    "content_en": "Many food names in Interslavic are very similar to words in other Slavic languages. This is one of the easiest topics to learn!",
                },
                {
                    "type": "vocabulary_table",
                    "items": [
                        {"isv_lat": "hléb", "isv_cyr": "хлєб", "ru": "хлеб", "en": "bread"},
                        {"isv_lat": "voda", "isv_cyr": "вода", "ru": "вода", "en": "water"},
                        {"isv_lat": "mléko", "isv_cyr": "млєко", "ru": "молоко", "en": "milk"},
                        {"isv_lat": "meso", "isv_cyr": "месо", "ru": "мясо", "en": "meat"},
                        {"isv_lat": "ryba", "isv_cyr": "рыба", "ru": "рыба", "en": "fish"},
                        {"isv_lat": "jablko", "isv_cyr": "јаблко", "ru": "яблоко", "en": "apple"},
                        {"isv_lat": "čaj", "isv_cyr": "чај", "ru": "чай", "en": "tea"},
                        {"isv_lat": "kava", "isv_cyr": "кава", "ru": "кофе", "en": "coffee"},
                        {"isv_lat": "sol", "isv_cyr": "сол", "ru": "соль", "en": "salt"},
                        {"isv_lat": "sahar", "isv_cyr": "сахар", "ru": "сахар", "en": "sugar"},
                    ],
                },
            ],
        },
        "exercises": [
            {
                "type": "word_match",
                "instruction_ru": "Соедините продукты с переводом",
                "instruction_en": "Match food items with their translation",
                "pairs": [
                    {"isv_lat": "hléb", "isv_cyr": "хлєб", "ru": "хлеб", "en": "bread"},
                    {"isv_lat": "voda", "isv_cyr": "вода", "ru": "вода", "en": "water"},
                    {"isv_lat": "mléko", "isv_cyr": "млєко", "ru": "молоко", "en": "milk"},
                    {"isv_lat": "ryba", "isv_cyr": "рыба", "ru": "рыба", "en": "fish"},
                ],
                "hint_ru": "Все эти слова похожи на русские",
                "hint_en": "All these words are similar to Russian",
                "xp": 10,
            },
            {
                "type": "multiple_choice",
                "instruction_ru": "Переведите слово",
                "instruction_en": "Translate the word",
                "question_isv_lat": "čaj",
                "question_isv_cyr": "чај",
                "options_ru": ["чай", "кофе", "вода", "молоко"],
                "options_en": ["tea", "coffee", "water", "milk"],
                "correct_index": 0,
                "hint_ru": "Это горячий напиток, который пьют из чашки",
                "hint_en": "This is a hot drink served in a cup",
                "xp": 10,
            },
            {
                "type": "fill_blank",
                "instruction_ru": "Заполните пропуск",
                "instruction_en": "Fill in the blank",
                "sentence_isv_lat": "Ja pijem ___.",
                "sentence_isv_cyr": "Ја пијем ___.",
                "answer_isv_lat": "vodu",
                "answer_isv_cyr": "воду",
                "translation_ru": "Я пью воду.",
                "translation_en": "I drink water.",
                "hint_ru": "Слово 'вода' в винительном падеже",
                "hint_en": "The word 'water' in accusative case",
                "xp": 15,
            },
            {
                "type": "text_input",
                "instruction_ru": "Напишите 'хлеб' на межславянском",
                "instruction_en": "Write 'bread' in Interslavic",
                "prompt_ru": "хлеб",
                "prompt_en": "bread",
                "answer_isv_lat": "hléb",
                "answer_isv_cyr": "хлєб",
                "hint_ru": "Очень похоже на русское слово, но пишется немного иначе",
                "hint_en": "Very similar to the Russian word, but spelled slightly differently",
                "xp": 20,
            },
        ],
    })

    # Family lesson
    lessons.append({
        "id": "lesson_family_1",
        "category_id": "cat_family",
        "title_ru": "Семья",
        "title_en": "Family",
        "order": 0,
        "theory": {
            "title_ru": "Семья в межславянском",
            "title_en": "Family in Interslavic",
            "blocks": [
                {
                    "type": "text",
                    "content_ru": "Слова, связанные с семьёй, являются одними из самых древних и общих для всех славянских языков. Межславянские слова очень близки к их русским эквивалентам.",
                    "content_en": "Family-related words are among the oldest and most common across all Slavic languages. Interslavic words are very close to their Russian equivalents.",
                },
                {
                    "type": "vocabulary_table",
                    "items": [
                        {"isv_lat": "otec", "isv_cyr": "отец", "ru": "отец", "en": "father"},
                        {"isv_lat": "mati", "isv_cyr": "мати", "ru": "мать", "en": "mother"},
                        {"isv_lat": "syn", "isv_cyr": "сын", "ru": "сын", "en": "son"},
                        {"isv_lat": "dčer", "isv_cyr": "дчер", "ru": "дочь", "en": "daughter"},
                        {"isv_lat": "brat", "isv_cyr": "брат", "ru": "брат", "en": "brother"},
                        {"isv_lat": "sestra", "isv_cyr": "сестра", "ru": "сестра", "en": "sister"},
                        {"isv_lat": "ded", "isv_cyr": "дед", "ru": "дедушка", "en": "grandfather"},
                        {"isv_lat": "baba", "isv_cyr": "баба", "ru": "бабушка", "en": "grandmother"},
                        {"isv_lat": "muž", "isv_cyr": "муж", "ru": "муж", "en": "husband"},
                        {"isv_lat": "žena", "isv_cyr": "жена", "ru": "жена", "en": "wife"},
                    ],
                },
            ],
        },
        "exercises": [
            {
                "type": "word_match",
                "instruction_ru": "Соедините слова с переводом",
                "instruction_en": "Match words with their translation",
                "pairs": [
                    {"isv_lat": "otec", "isv_cyr": "отец", "ru": "отец", "en": "father"},
                    {"isv_lat": "mati", "isv_cyr": "мати", "ru": "мать", "en": "mother"},
                    {"isv_lat": "brat", "isv_cyr": "брат", "ru": "брат", "en": "brother"},
                    {"isv_lat": "sestra", "isv_cyr": "сестра", "ru": "сестра", "en": "sister"},
                ],
                "hint_ru": "Семейные слова почти одинаковы в русском и межславянском",
                "hint_en": "Family words are almost identical in Russian and Interslavic",
                "xp": 10,
            },
            {
                "type": "multiple_choice",
                "instruction_ru": "Кто такой 'syn'?",
                "instruction_en": "Who is 'syn'?",
                "question_isv_lat": "syn",
                "question_isv_cyr": "сын",
                "options_ru": ["сын", "дочь", "брат", "муж"],
                "options_en": ["son", "daughter", "brother", "husband"],
                "correct_index": 0,
                "hint_ru": "Это слово идентично русскому",
                "hint_en": "This word is identical to Russian",
                "xp": 10,
            },
            {
                "type": "fill_blank",
                "instruction_ru": "Заполните пропуск",
                "instruction_en": "Fill in the blank",
                "sentence_isv_lat": "Moja ___ jest učiteljka.",
                "sentence_isv_cyr": "Моја ___ јест учитељка.",
                "answer_isv_lat": "sestra",
                "answer_isv_cyr": "сестра",
                "translation_ru": "Моя сестра — учительница.",
                "translation_en": "My sister is a teacher.",
                "hint_ru": "Женский родственник, дочь тех же родителей",
                "hint_en": "A female relative, a daughter of the same parents",
                "xp": 15,
            },
            {
                "type": "text_input",
                "instruction_ru": "Напишите 'брат' на межславянском",
                "instruction_en": "Write 'brother' in Interslavic",
                "prompt_ru": "брат",
                "prompt_en": "brother",
                "answer_isv_lat": "brat",
                "answer_isv_cyr": "брат",
                "hint_ru": "Слово идентично русскому",
                "hint_en": "The word is identical to Russian",
                "xp": 20,
            },
        ],
    })

    # Numbers lesson
    lessons.append({
        "id": "lesson_numbers_1",
        "category_id": "cat_numbers",
        "title_ru": "Числа 1-10",
        "title_en": "Numbers 1-10",
        "order": 0,
        "theory": {
            "title_ru": "Числительные в межславянском",
            "title_en": "Numerals in Interslavic",
            "blocks": [
                {
                    "type": "text",
                    "content_ru": "Числа в межславянском языке основаны на общеславянских корнях. Если вы знаете числа на любом славянском языке, вы быстро запомните их на межславянском.",
                    "content_en": "Numbers in Interslavic are based on common Slavic roots. If you know numbers in any Slavic language, you'll quickly memorize them in Interslavic.",
                },
                {
                    "type": "vocabulary_table",
                    "items": [
                        {"isv_lat": "jedin", "isv_cyr": "једин", "ru": "один", "en": "one"},
                        {"isv_lat": "dva", "isv_cyr": "два", "ru": "два", "en": "two"},
                        {"isv_lat": "tri", "isv_cyr": "три", "ru": "три", "en": "three"},
                        {"isv_lat": "četyri", "isv_cyr": "четыри", "ru": "четыре", "en": "four"},
                        {"isv_lat": "pet", "isv_cyr": "пет", "ru": "пять", "en": "five"},
                        {"isv_lat": "šest", "isv_cyr": "шест", "ru": "шесть", "en": "six"},
                        {"isv_lat": "sedm", "isv_cyr": "седм", "ru": "семь", "en": "seven"},
                        {"isv_lat": "osm", "isv_cyr": "осм", "ru": "восемь", "en": "eight"},
                        {"isv_lat": "devet", "isv_cyr": "девет", "ru": "девять", "en": "nine"},
                        {"isv_lat": "deset", "isv_cyr": "десет", "ru": "десять", "en": "ten"},
                    ],
                },
            ],
        },
        "exercises": [
            {
                "type": "word_match",
                "instruction_ru": "Соедините числа с переводом",
                "instruction_en": "Match numbers with their translation",
                "pairs": [
                    {"isv_lat": "jedin", "isv_cyr": "једин", "ru": "один", "en": "one"},
                    {"isv_lat": "tri", "isv_cyr": "три", "ru": "три", "en": "three"},
                    {"isv_lat": "pet", "isv_cyr": "пет", "ru": "пять", "en": "five"},
                    {"isv_lat": "deset", "isv_cyr": "десет", "ru": "десять", "en": "ten"},
                ],
                "hint_ru": "Сравните с русскими числительными",
                "hint_en": "Compare with Russian numerals",
                "xp": 10,
            },
            {
                "type": "multiple_choice",
                "instruction_ru": "Какое это число?",
                "instruction_en": "What number is this?",
                "question_isv_lat": "sedm",
                "question_isv_cyr": "седм",
                "options_ru": ["семь", "шесть", "восемь", "девять"],
                "options_en": ["seven", "six", "eight", "nine"],
                "correct_index": 0,
                "hint_ru": "Сравните с русским 'семь'",
                "hint_en": "Compare with Russian 'sem' (seven)",
                "xp": 10,
            },
            {
                "type": "fill_blank",
                "instruction_ru": "Заполните пропуск",
                "instruction_en": "Fill in the blank",
                "sentence_isv_lat": "Ja imam ___ bratov.",
                "sentence_isv_cyr": "Ја имам ___ братов.",
                "answer_isv_lat": "dva",
                "answer_isv_cyr": "два",
                "translation_ru": "У меня два брата.",
                "translation_en": "I have two brothers.",
                "hint_ru": "Число 2 — одинаково почти во всех славянских языках",
                "hint_en": "Number 2 — almost the same in all Slavic languages",
                "xp": 15,
            },
            {
                "type": "text_input",
                "instruction_ru": "Напишите число 'четыре' на межславянском",
                "instruction_en": "Write the number 'four' in Interslavic",
                "prompt_ru": "четыре",
                "prompt_en": "four",
                "answer_isv_lat": "četyri",
                "answer_isv_cyr": "четыри",
                "hint_ru": "Очень похоже на русское 'четыре'",
                "hint_en": "Very similar to Russian 'chetyre'",
                "xp": 20,
            },
        ],
    })

    # Colors lesson
    lessons.append({
        "id": "lesson_colors_1",
        "category_id": "cat_colors",
        "title_ru": "Цвета",
        "title_en": "Colors",
        "order": 0,
        "theory": {
            "title_ru": "Цвета в межславянском",
            "title_en": "Colors in Interslavic",
            "blocks": [
                {
                    "type": "text",
                    "content_ru": "Цвета — важная часть базового словарного запаса. Многие названия цветов в межславянском языке имеют общеславянские корни.",
                    "content_en": "Colors are an important part of basic vocabulary. Many color names in Interslavic have common Slavic roots.",
                },
                {
                    "type": "vocabulary_table",
                    "items": [
                        {"isv_lat": "črveny", "isv_cyr": "чрвены", "ru": "красный", "en": "red"},
                        {"isv_lat": "siny", "isv_cyr": "сины", "ru": "синий", "en": "blue"},
                        {"isv_lat": "zeleny", "isv_cyr": "зелены", "ru": "зелёный", "en": "green"},
                        {"isv_lat": "žŭlty", "isv_cyr": "жŭлты", "ru": "жёлтый", "en": "yellow"},
                        {"isv_lat": "běly", "isv_cyr": "бєлы", "ru": "белый", "en": "white"},
                        {"isv_lat": "čŕny", "isv_cyr": "чрны", "ru": "чёрный", "en": "black"},
                    ],
                },
            ],
        },
        "exercises": [
            {
                "type": "word_match",
                "instruction_ru": "Соедините цвета с переводом",
                "instruction_en": "Match colors with their translation",
                "pairs": [
                    {"isv_lat": "črveny", "isv_cyr": "чрвены", "ru": "красный", "en": "red"},
                    {"isv_lat": "siny", "isv_cyr": "сины", "ru": "синий", "en": "blue"},
                    {"isv_lat": "zeleny", "isv_cyr": "зелены", "ru": "зелёный", "en": "green"},
                    {"isv_lat": "běly", "isv_cyr": "бєлы", "ru": "белый", "en": "white"},
                ],
                "hint_ru": "Корни этих слов общие для многих славянских языков",
                "hint_en": "The roots of these words are common to many Slavic languages",
                "xp": 10,
            },
            {
                "type": "multiple_choice",
                "instruction_ru": "Какой это цвет?",
                "instruction_en": "What color is this?",
                "question_isv_lat": "zeleny",
                "question_isv_cyr": "зелены",
                "options_ru": ["зелёный", "синий", "красный", "жёлтый"],
                "options_en": ["green", "blue", "red", "yellow"],
                "correct_index": 0,
                "hint_ru": "Сравните с русским 'зелёный'",
                "hint_en": "Compare with Russian 'zelyony'",
                "xp": 10,
            },
            {
                "type": "fill_blank",
                "instruction_ru": "Заполните пропуск",
                "instruction_en": "Fill in the blank",
                "sentence_isv_lat": "___ kot spi na divanu.",
                "sentence_isv_cyr": "___ кот спи на дивану.",
                "answer_isv_lat": "Čŕny",
                "answer_isv_cyr": "Чрны",
                "translation_ru": "Чёрный кот спит на диване.",
                "translation_en": "A black cat sleeps on the sofa.",
                "hint_ru": "Этот цвет ассоциируется с ночью и тьмой",
                "hint_en": "This color is associated with night and darkness",
                "xp": 15,
            },
            {
                "type": "text_input",
                "instruction_ru": "Напишите 'белый' на межславянском",
                "instruction_en": "Write 'white' in Interslavic",
                "prompt_ru": "белый",
                "prompt_en": "white",
                "answer_isv_lat": "běly",
                "answer_isv_cyr": "бєлы",
                "hint_ru": "Похоже на русское 'белый', но с другой гласной",
                "hint_en": "Similar to Russian 'bely', but with a different vowel",
                "xp": 20,
            },
        ],
    })

    # Travel lesson
    lessons.append({
        "id": "lesson_travel_1",
        "category_id": "cat_travel",
        "title_ru": "Путешествия",
        "title_en": "Travel",
        "order": 0,
        "theory": {
            "title_ru": "Путешествия и транспорт",
            "title_en": "Travel & Transport",
            "blocks": [
                {
                    "type": "text",
                    "content_ru": "Путешествуя по славянским странам, знание межславянского языка может быть очень полезным. Вот основные слова и фразы для путешествий.",
                    "content_en": "When traveling through Slavic countries, knowledge of Interslavic can be very useful. Here are basic travel words and phrases.",
                },
                {
                    "type": "vocabulary_table",
                    "items": [
                        {"isv_lat": "vlak", "isv_cyr": "влак", "ru": "поезд", "en": "train"},
                        {"isv_lat": "avtobus", "isv_cyr": "автобус", "ru": "автобус", "en": "bus"},
                        {"isv_lat": "letišče", "isv_cyr": "летишче", "ru": "аэропорт", "en": "airport"},
                        {"isv_lat": "hotel", "isv_cyr": "хотел", "ru": "гостиница", "en": "hotel"},
                        {"isv_lat": "bilet", "isv_cyr": "билет", "ru": "билет", "en": "ticket"},
                        {"isv_lat": "mapa", "isv_cyr": "мапа", "ru": "карта", "en": "map"},
                        {"isv_lat": "ulica", "isv_cyr": "улица", "ru": "улица", "en": "street"},
                        {"isv_lat": "město", "isv_cyr": "мєсто", "ru": "город", "en": "city"},
                    ],
                },
            ],
        },
        "exercises": [
            {
                "type": "word_match",
                "instruction_ru": "Соедините слова с переводом",
                "instruction_en": "Match words with their translation",
                "pairs": [
                    {"isv_lat": "vlak", "isv_cyr": "влак", "ru": "поезд", "en": "train"},
                    {"isv_lat": "bilet", "isv_cyr": "билет", "ru": "билет", "en": "ticket"},
                    {"isv_lat": "ulica", "isv_cyr": "улица", "ru": "улица", "en": "street"},
                    {"isv_lat": "město", "isv_cyr": "мєсто", "ru": "город", "en": "city"},
                ],
                "hint_ru": "Некоторые из этих слов совпадают с русскими",
                "hint_en": "Some of these words are identical to Russian",
                "xp": 10,
            },
            {
                "type": "multiple_choice",
                "instruction_ru": "Что означает 'letišče'?",
                "instruction_en": "What does 'letišče' mean?",
                "question_isv_lat": "letišče",
                "question_isv_cyr": "летишче",
                "options_ru": ["аэропорт", "вокзал", "гостиница", "ресторан"],
                "options_en": ["airport", "station", "hotel", "restaurant"],
                "correct_index": 0,
                "hint_ru": "Корень слова связан с 'летать'",
                "hint_en": "The root of the word is related to 'flying'",
                "xp": 10,
            },
            {
                "type": "fill_blank",
                "instruction_ru": "Заполните пропуск",
                "instruction_en": "Fill in the blank",
                "sentence_isv_lat": "Gdě jest ___?",
                "sentence_isv_cyr": "Гдє јест ___?",
                "answer_isv_lat": "hotel",
                "answer_isv_cyr": "хотел",
                "translation_ru": "Где находится гостиница?",
                "translation_en": "Where is the hotel?",
                "hint_ru": "Место, где останавливаются путешественники",
                "hint_en": "A place where travelers stay",
                "xp": 15,
            },
            {
                "type": "text_input",
                "instruction_ru": "Напишите 'билет' на межславянском",
                "instruction_en": "Write 'ticket' in Interslavic",
                "prompt_ru": "билет",
                "prompt_en": "ticket",
                "answer_isv_lat": "bilet",
                "answer_isv_cyr": "билет",
                "hint_ru": "Слово идентично русскому",
                "hint_en": "The word is identical to Russian",
                "xp": 20,
            },
        ],
    })

    # Grammar: Nouns lesson
    nouns_grammar = next(
        (g for g in grammar if g["id"] == "grammar_nouns"), None
    )
    grammar_theory_blocks = []
    if nouns_grammar and nouns_grammar.get("blocks"):
        for block in nouns_grammar["blocks"][:8]:
            if block["type"] == "paragraph":
                grammar_theory_blocks.append({
                    "type": "text",
                    "content_ru": block["text"],
                    "content_en": block["text"],
                })
            elif block["type"] == "table":
                grammar_theory_blocks.append({
                    "type": "grammar_table",
                    "rows": block["rows"],
                })

    if not grammar_theory_blocks:
        grammar_theory_blocks = [
            {
                "type": "text",
                "content_ru": "В межславянском языке существительные имеют три рода (мужской, женский, средний), два числа (единственное, множественное) и семь падежей.",
                "content_en": "In Interslavic, nouns have three genders (masculine, feminine, neuter), two numbers (singular, plural) and seven cases.",
            },
            {
                "type": "text",
                "content_ru": "Первое склонение включает все мужские существительные, оканчивающиеся на согласный, а также средние существительные на -o или -e. Второе склонение — женские существительные на -a. Третье — женские на согласный.",
                "content_en": "The first declension includes all masculine nouns ending in a consonant, as well as neuter nouns ending in -o or -e. The second declension includes feminine nouns ending in -a. The third — feminine nouns ending in a consonant.",
            },
        ]

    lessons.append({
        "id": "lesson_nouns_1",
        "category_id": "cat_nouns",
        "title_ru": "Существительные: Основы",
        "title_en": "Nouns: Basics",
        "order": 0,
        "theory": {
            "title_ru": "Существительные в межславянском",
            "title_en": "Nouns in Interslavic",
            "blocks": grammar_theory_blocks,
        },
        "exercises": [
            {
                "type": "multiple_choice",
                "instruction_ru": "Сколько грамматических родов в межславянском?",
                "instruction_en": "How many grammatical genders are in Interslavic?",
                "question_isv_lat": "Koliko gramtičnyh rodov?",
                "question_isv_cyr": "Колико грамтичных родов?",
                "options_ru": ["3 (мужской, женский, средний)", "2 (мужской, женский)", "4", "1"],
                "options_en": ["3 (masculine, feminine, neuter)", "2 (masculine, feminine)", "4", "1"],
                "correct_index": 0,
                "hint_ru": "Как в русском языке",
                "hint_en": "Same as in Russian",
                "xp": 10,
            },
            {
                "type": "word_match",
                "instruction_ru": "Соедините существительные с их родом",
                "instruction_en": "Match nouns with their gender",
                "pairs": [
                    {"isv_lat": "dom (m.)", "isv_cyr": "дом (м.)", "ru": "мужской род", "en": "masculine"},
                    {"isv_lat": "žena (f.)", "isv_cyr": "жена (ж.)", "ru": "женский род", "en": "feminine"},
                    {"isv_lat": "selo (n.)", "isv_cyr": "село (с.)", "ru": "средний род", "en": "neuter"},
                    {"isv_lat": "kosť (f.)", "isv_cyr": "кость (ж.)", "ru": "женский род (3 скл.)", "en": "feminine (3rd decl.)"},
                ],
                "hint_ru": "Обратите внимание на окончания: согласный = м.р., -a = ж.р., -o/-e = с.р.",
                "hint_en": "Note the endings: consonant = masc., -a = fem., -o/-e = neut.",
                "xp": 15,
            },
            {
                "type": "fill_blank",
                "instruction_ru": "Заполните пропуск правильным окончанием",
                "instruction_en": "Fill in the correct ending",
                "sentence_isv_lat": "Ja vidžu dom___.",
                "sentence_isv_cyr": "Ја виджу дом___.",
                "answer_isv_lat": "",
                "answer_isv_cyr": "",
                "translation_ru": "Я вижу дом. (Винительный падеж неодушевл. = именительный)",
                "translation_en": "I see a house. (Accusative inanimate = nominative)",
                "hint_ru": "Для неодушевлённых мужского рода винительный = именительный",
                "hint_en": "For inanimate masculine nouns, accusative = nominative",
                "xp": 15,
            },
            {
                "type": "text_input",
                "instruction_ru": "Напишите множественное число слова 'brat'",
                "instruction_en": "Write the plural of 'brat'",
                "prompt_ru": "брат (мн.ч.)",
                "prompt_en": "brother (plural)",
                "answer_isv_lat": "brati",
                "answer_isv_cyr": "брати",
                "hint_ru": "Одушевлённые мужского рода во мн.ч. имеют окончание -i",
                "hint_en": "Animate masculine nouns in plural have the ending -i",
                "xp": 20,
            },
        ],
    })

    # Grammar: Verbs lesson
    lessons.append({
        "id": "lesson_verbs_1",
        "category_id": "cat_verbs",
        "title_ru": "Глаголы: Основы",
        "title_en": "Verbs: Basics",
        "order": 0,
        "theory": {
            "title_ru": "Глаголы в межславянском",
            "title_en": "Verbs in Interslavic",
            "blocks": [
                {
                    "type": "text",
                    "content_ru": "Глаголы в межславянском языке спрягаются по лицам и числам. Система спряжения упрощена по сравнению с отдельными славянскими языками, но сохраняет все важные формы.",
                    "content_en": "Verbs in Interslavic are conjugated by person and number. The conjugation system is simplified compared to individual Slavic languages, but retains all important forms.",
                },
                {
                    "type": "vocabulary_table",
                    "items": [
                        {"isv_lat": "ja dělam", "isv_cyr": "ја дєлам", "ru": "я делаю", "en": "I do"},
                        {"isv_lat": "ty dělaš", "isv_cyr": "ты дєлаш", "ru": "ты делаешь", "en": "you do"},
                        {"isv_lat": "on děla", "isv_cyr": "он дєла", "ru": "он делает", "en": "he does"},
                        {"isv_lat": "my dělamo", "isv_cyr": "мы дєламо", "ru": "мы делаем", "en": "we do"},
                        {"isv_lat": "vy dělate", "isv_cyr": "вы дєлате", "ru": "вы делаете", "en": "you do (pl.)"},
                        {"isv_lat": "oni dělajut", "isv_cyr": "они дєлајут", "ru": "они делают", "en": "they do"},
                    ],
                },
                {
                    "type": "tip",
                    "content_ru": "Окончания глаголов: -m (я), -š (ты), -Ø (он/она), -mo (мы), -te (вы), -jut (они). Эти окончания используются для большинства глаголов.",
                    "content_en": "Verb endings: -m (I), -š (you), -Ø (he/she), -mo (we), -te (you pl.), -jut (they). These endings are used for most verbs.",
                },
            ],
        },
        "exercises": [
            {
                "type": "word_match",
                "instruction_ru": "Соедините формы глагола с местоимениями",
                "instruction_en": "Match verb forms with pronouns",
                "pairs": [
                    {"isv_lat": "dělam", "isv_cyr": "дєлам", "ru": "я (делаю)", "en": "I (do)"},
                    {"isv_lat": "dělaš", "isv_cyr": "дєлаш", "ru": "ты (делаешь)", "en": "you (do)"},
                    {"isv_lat": "dělamo", "isv_cyr": "дєламо", "ru": "мы (делаем)", "en": "we (do)"},
                    {"isv_lat": "dělajut", "isv_cyr": "дєлајут", "ru": "они (делают)", "en": "they (do)"},
                ],
                "hint_ru": "Обратите внимание на окончания: -m, -š, -mo, -jut",
                "hint_en": "Pay attention to endings: -m, -š, -mo, -jut",
                "xp": 10,
            },
            {
                "type": "multiple_choice",
                "instruction_ru": "Выберите правильную форму",
                "instruction_en": "Choose the correct form",
                "question_isv_lat": "My ___ (dělati)",
                "question_isv_cyr": "Мы ___ (дєлати)",
                "options_ru": ["dělamo", "dělam", "dělaš", "dělajut"],
                "options_en": ["dělamo", "dělam", "dělaš", "dělajut"],
                "correct_index": 0,
                "hint_ru": "Для 'мы' используется окончание -mo",
                "hint_en": "For 'we', the ending -mo is used",
                "xp": 10,
            },
            {
                "type": "fill_blank",
                "instruction_ru": "Заполните пропуск",
                "instruction_en": "Fill in the blank",
                "sentence_isv_lat": "Oni ___ v školu.",
                "sentence_isv_cyr": "Они ___ в школу.",
                "answer_isv_lat": "idut",
                "answer_isv_cyr": "идут",
                "translation_ru": "Они идут в школу.",
                "translation_en": "They go to school.",
                "hint_ru": "Глагол 'идти' в 3-м лице мн.ч.",
                "hint_en": "The verb 'to go' in 3rd person plural",
                "xp": 15,
            },
            {
                "type": "text_input",
                "instruction_ru": "Проспрягайте 'znati' для 'ja'",
                "instruction_en": "Conjugate 'znati' for 'ja'",
                "prompt_ru": "я знаю",
                "prompt_en": "I know",
                "answer_isv_lat": "znam",
                "answer_isv_cyr": "знам",
                "hint_ru": "Окончание первого лица единственного числа: -m",
                "hint_en": "First person singular ending: -m",
                "xp": 20,
            },
        ],
    })

    # Grammar: Adjectives lesson
    lessons.append({
        "id": "lesson_adjectives_1",
        "category_id": "cat_adjectives",
        "title_ru": "Прилагательные: Основы",
        "title_en": "Adjectives: Basics",
        "order": 0,
        "theory": {
            "title_ru": "Прилагательные в межславянском",
            "title_en": "Adjectives in Interslavic",
            "blocks": [
                {
                    "type": "text",
                    "content_ru": "Прилагательные в межславянском языке согласуются с существительными в роде, числе и падеже. Основные окончания: мужской род -y, женский род -a, средний род -o.",
                    "content_en": "Adjectives in Interslavic agree with nouns in gender, number, and case. Basic endings: masculine -y, feminine -a, neuter -o.",
                },
                {
                    "type": "vocabulary_table",
                    "items": [
                        {"isv_lat": "dobry / dobra / dobro", "isv_cyr": "добры / добра / добро", "ru": "хороший/ая/ее", "en": "good (m/f/n)"},
                        {"isv_lat": "veliky / velika / veliko", "isv_cyr": "великы / велика / велико", "ru": "большой/ая/ое", "en": "big (m/f/n)"},
                        {"isv_lat": "maly / mala / malo", "isv_cyr": "малы / мала / мало", "ru": "маленький/ая/ое", "en": "small (m/f/n)"},
                        {"isv_lat": "novy / nova / novo", "isv_cyr": "новы / нова / ново", "ru": "новый/ая/ое", "en": "new (m/f/n)"},
                        {"isv_lat": "stary / stara / staro", "isv_cyr": "стары / стара / старо", "ru": "старый/ая/ое", "en": "old (m/f/n)"},
                    ],
                },
            ],
        },
        "exercises": [
            {
                "type": "word_match",
                "instruction_ru": "Соедините прилагательные с переводом",
                "instruction_en": "Match adjectives with their translation",
                "pairs": [
                    {"isv_lat": "dobry", "isv_cyr": "добры", "ru": "хороший", "en": "good"},
                    {"isv_lat": "veliky", "isv_cyr": "великы", "ru": "большой", "en": "big"},
                    {"isv_lat": "maly", "isv_cyr": "малы", "ru": "маленький", "en": "small"},
                    {"isv_lat": "novy", "isv_cyr": "новы", "ru": "новый", "en": "new"},
                ],
                "hint_ru": "Все слова имеют общеславянские корни",
                "hint_en": "All words have common Slavic roots",
                "xp": 10,
            },
            {
                "type": "multiple_choice",
                "instruction_ru": "Выберите правильную форму",
                "instruction_en": "Choose the correct form",
                "question_isv_lat": "___  žena (dobry)",
                "question_isv_cyr": "___  жена (добры)",
                "options_ru": ["dobra", "dobry", "dobro", "dobre"],
                "options_en": ["dobra", "dobry", "dobro", "dobre"],
                "correct_index": 0,
                "hint_ru": "'žena' — женский род, значит окончание -a",
                "hint_en": "'žena' is feminine, so the ending is -a",
                "xp": 10,
            },
            {
                "type": "fill_blank",
                "instruction_ru": "Заполните пропуск",
                "instruction_en": "Fill in the blank",
                "sentence_isv_lat": "___ město jest krasno.",
                "sentence_isv_cyr": "___ мєсто јест красно.",
                "answer_isv_lat": "Novo",
                "answer_isv_cyr": "Ново",
                "translation_ru": "Новый город красив.",
                "translation_en": "The new city is beautiful.",
                "hint_ru": "'město' — средний род, окончание прилагательного -o",
                "hint_en": "'město' is neuter, adjective ending is -o",
                "xp": 15,
            },
            {
                "type": "text_input",
                "instruction_ru": "Напишите 'старый' в женском роде на межславянском",
                "instruction_en": "Write 'old' in feminine form in Interslavic",
                "prompt_ru": "старая",
                "prompt_en": "old (feminine)",
                "answer_isv_lat": "stara",
                "answer_isv_cyr": "стара",
                "hint_ru": "Мужской род 'stary', для женского замените -y на -a",
                "hint_en": "Masculine is 'stary', for feminine replace -y with -a",
                "xp": 20,
            },
        ],
    })

    # Grammar: Pronouns lesson
    lessons.append({
        "id": "lesson_pronouns_1",
        "category_id": "cat_pronouns",
        "title_ru": "Местоимения",
        "title_en": "Pronouns",
        "order": 0,
        "theory": {
            "title_ru": "Местоимения в межславянском",
            "title_en": "Pronouns in Interslavic",
            "blocks": [
                {
                    "type": "text",
                    "content_ru": "Личные местоимения в межславянском языке очень похожи на русские. Они склоняются по падежам.",
                    "content_en": "Personal pronouns in Interslavic are very similar to Russian. They decline by case.",
                },
                {
                    "type": "vocabulary_table",
                    "items": [
                        {"isv_lat": "ja / mene / mně", "isv_cyr": "ја / мене / мнє", "ru": "я / меня / мне", "en": "I / me / to me"},
                        {"isv_lat": "ty / tebe / tobě", "isv_cyr": "ты / тебе / тобє", "ru": "ты / тебя / тебе", "en": "you / you / to you"},
                        {"isv_lat": "on / jego / jemu", "isv_cyr": "он / јего / јему", "ru": "он / его / ему", "en": "he / him / to him"},
                        {"isv_lat": "ona / jej / jej", "isv_cyr": "она / јеј / јеј", "ru": "она / её / ей", "en": "she / her / to her"},
                        {"isv_lat": "my / nas / nam", "isv_cyr": "мы / нас / нам", "ru": "мы / нас / нам", "en": "we / us / to us"},
                        {"isv_lat": "vy / vas / vam", "isv_cyr": "вы / вас / вам", "ru": "вы / вас / вам", "en": "you / you / to you"},
                    ],
                },
            ],
        },
        "exercises": [
            {
                "type": "word_match",
                "instruction_ru": "Соедините местоимения",
                "instruction_en": "Match pronouns",
                "pairs": [
                    {"isv_lat": "mene", "isv_cyr": "мене", "ru": "меня", "en": "me"},
                    {"isv_lat": "tebe", "isv_cyr": "тебе", "ru": "тебя", "en": "you (acc.)"},
                    {"isv_lat": "nas", "isv_cyr": "нас", "ru": "нас", "en": "us"},
                    {"isv_lat": "vas", "isv_cyr": "вас", "ru": "вас", "en": "you (pl. acc.)"},
                ],
                "hint_ru": "Формы очень близки к русским",
                "hint_en": "Forms are very close to Russian",
                "xp": 10,
            },
            {
                "type": "multiple_choice",
                "instruction_ru": "Выберите правильный перевод",
                "instruction_en": "Choose the correct translation",
                "question_isv_lat": "jego",
                "question_isv_cyr": "јего",
                "options_ru": ["его", "её", "их", "нас"],
                "options_en": ["his/him", "her", "their", "us"],
                "correct_index": 0,
                "hint_ru": "Это родительный/винительный падеж местоимения 'on'",
                "hint_en": "This is the genitive/accusative of the pronoun 'on'",
                "xp": 10,
            },
            {
                "type": "fill_blank",
                "instruction_ru": "Заполните пропуск",
                "instruction_en": "Fill in the blank",
                "sentence_isv_lat": "Ja vidžu ___.",
                "sentence_isv_cyr": "Ја виджу ___.",
                "answer_isv_lat": "tebe",
                "answer_isv_cyr": "тебе",
                "translation_ru": "Я вижу тебя.",
                "translation_en": "I see you.",
                "hint_ru": "Винительный падеж от 'ty'",
                "hint_en": "Accusative case of 'ty'",
                "xp": 15,
            },
            {
                "type": "text_input",
                "instruction_ru": "Напишите дательный падеж от 'my'",
                "instruction_en": "Write the dative case of 'my'",
                "prompt_ru": "нам",
                "prompt_en": "to us",
                "answer_isv_lat": "nam",
                "answer_isv_cyr": "нам",
                "hint_ru": "Идентично русскому",
                "hint_en": "Identical to Russian",
                "xp": 20,
            },
        ],
    })

    # Grammar: Prepositions lesson
    lessons.append({
        "id": "lesson_prepositions_1",
        "category_id": "cat_prepositions",
        "title_ru": "Предлоги",
        "title_en": "Prepositions",
        "order": 0,
        "theory": {
            "title_ru": "Предлоги в межславянском",
            "title_en": "Prepositions in Interslavic",
            "blocks": [
                {
                    "type": "text",
                    "content_ru": "Предлоги в межславянском языке управляют определёнными падежами, как и в других славянских языках. Многие предлоги идентичны русским.",
                    "content_en": "Prepositions in Interslavic govern specific cases, as in other Slavic languages. Many prepositions are identical to Russian.",
                },
                {
                    "type": "vocabulary_table",
                    "items": [
                        {"isv_lat": "v / vo", "isv_cyr": "в / во", "ru": "в", "en": "in"},
                        {"isv_lat": "na", "isv_cyr": "на", "ru": "на", "en": "on"},
                        {"isv_lat": "iz", "isv_cyr": "из", "ru": "из", "en": "from"},
                        {"isv_lat": "do", "isv_cyr": "до", "ru": "до", "en": "to/until"},
                        {"isv_lat": "s / so", "isv_cyr": "с / со", "ru": "с", "en": "with"},
                        {"isv_lat": "bez", "isv_cyr": "без", "ru": "без", "en": "without"},
                        {"isv_lat": "za", "isv_cyr": "за", "ru": "за", "en": "behind/for"},
                        {"isv_lat": "pri", "isv_cyr": "при", "ru": "при", "en": "at/by"},
                    ],
                },
            ],
        },
        "exercises": [
            {
                "type": "word_match",
                "instruction_ru": "Соедините предлоги с переводом",
                "instruction_en": "Match prepositions with their translation",
                "pairs": [
                    {"isv_lat": "v", "isv_cyr": "в", "ru": "в", "en": "in"},
                    {"isv_lat": "na", "isv_cyr": "на", "ru": "на", "en": "on"},
                    {"isv_lat": "iz", "isv_cyr": "из", "ru": "из", "en": "from"},
                    {"isv_lat": "bez", "isv_cyr": "без", "ru": "без", "en": "without"},
                ],
                "hint_ru": "Предлоги почти идентичны русским",
                "hint_en": "Prepositions are almost identical to Russian",
                "xp": 10,
            },
            {
                "type": "multiple_choice",
                "instruction_ru": "Что означает 'bez'?",
                "instruction_en": "What does 'bez' mean?",
                "question_isv_lat": "bez",
                "question_isv_cyr": "без",
                "options_ru": ["без", "с", "за", "на"],
                "options_en": ["without", "with", "behind", "on"],
                "correct_index": 0,
                "hint_ru": "Идентично русскому предлогу",
                "hint_en": "Identical to the Russian preposition",
                "xp": 10,
            },
            {
                "type": "fill_blank",
                "instruction_ru": "Заполните пропуск",
                "instruction_en": "Fill in the blank",
                "sentence_isv_lat": "Ja idem ___ školu.",
                "sentence_isv_cyr": "Ја идем ___ школу.",
                "answer_isv_lat": "v",
                "answer_isv_cyr": "в",
                "translation_ru": "Я иду в школу.",
                "translation_en": "I go to school.",
                "hint_ru": "Предлог направления, такой же как в русском",
                "hint_en": "Directional preposition, same as in Russian",
                "xp": 15,
            },
            {
                "type": "text_input",
                "instruction_ru": "Напишите предлог 'с' (совместность) на межславянском",
                "instruction_en": "Write the preposition 'with' in Interslavic",
                "prompt_ru": "с (совместность)",
                "prompt_en": "with",
                "answer_isv_lat": "s",
                "answer_isv_cyr": "с",
                "hint_ru": "Один символ, идентичный русскому",
                "hint_en": "One character, identical to Russian",
                "xp": 20,
            },
        ],
    })

    return lessons


def main() -> None:
    """Main scraping and data generation pipeline."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print("=== Interslavic Learn — Data Scraper ===\n")

    print("[1/3] Scraping grammar from interslavic.fun ...")
    grammar = scrape_grammar()
    grammar_path = os.path.join(OUTPUT_DIR, "grammar_raw.json")
    with open(grammar_path, "w", encoding="utf-8") as f:
        json.dump(grammar, f, ensure_ascii=False, indent=2)
    print(f"  → Saved {len(grammar)} grammar topics to {grammar_path}\n")

    print("[2/3] Fetching vocabulary ...")
    vocabulary = scrape_vocabulary()
    vocab_path = os.path.join(OUTPUT_DIR, "vocabulary_raw.json")
    with open(vocab_path, "w", encoding="utf-8") as f:
        json.dump(vocabulary, f, ensure_ascii=False, indent=2)
    print(f"  → Saved {len(vocabulary)} vocabulary entries to {vocab_path}\n")

    print("[3/3] Building seed data ...")
    seed = build_seed_data(grammar, vocabulary)
    seed_path = os.path.join(OUTPUT_DIR, "seed_data.json")
    with open(seed_path, "w", encoding="utf-8") as f:
        json.dump(seed, f, ensure_ascii=False, indent=2)
    print(f"  → Saved seed data to {seed_path}")
    print(f"     Categories: {len(seed['categories'])}")
    print(f"     Lessons: {len(seed['lessons'])}")
    print(f"     Grammar topics: {len(seed['grammar'])}")
    print(f"     Vocabulary entries: {len(seed['vocabulary'])}")

    print("\n=== Done! ===")


if __name__ == "__main__":
    main()
