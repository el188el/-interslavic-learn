"""
Полная программа курса Medžuslovjansky: от первых шагов до продвинутого уровня.
Источники смысла и орфографии: открытая грамматика Medžuslovjansky, общеславянские модели.

Структура расширяема: добавляйте категории и уроки в ALL_SPECS или отдельные фабрики.
"""
from __future__ import annotations

from typing import Any

from .helpers import (
    block_grammar,
    block_text,
    block_tip,
    block_vocab,
    category,
    ex_fill_blank,
    ex_multiple_choice,
    ex_text_input,
    ex_word_match,
    lesson,
    theory,
    vocab_row,
)


def _std_quartet(
    pairs_wm: list[dict[str, str]],
    mc: tuple[str, str, str, str, list[str], list[str], int, str, str],
    fb: tuple[str, str, str, str, str, str, str, str, str, str],
    ti: tuple[str, str, str, str, str, str, str, str],
) -> list[dict[str, Any]]:
    """Стандартный плотный блок: соответствие → выбор → пропуск → ввод."""
    q_lat, q_cyr, ins_ru, ins_en, oru, oen, ci, hr, he = mc
    sl, sc, al, ac, tru, tre, firu, fien, hfru, hfen = fb
    pru, pen, tal, tac, tiru, tien, htiru, htien = ti
    return [
        ex_word_match(
            pairs_wm,
            "Соедините пары",
            "Match the pairs",
            xp=12,
        ),
        ex_multiple_choice(
            q_lat,
            q_cyr,
            oru,
            oen,
            ci,
            ins_ru,
            ins_en,
            xp=12,
            hint_ru=hr,
            hint_en=he,
        ),
        ex_fill_blank(
            sl,
            sc,
            al,
            ac,
            tru,
            tre,
            firu,
            fien,
            xp=15,
            hint_ru=hfru,
            hint_en=hfen,
        ),
        ex_text_input(
            pru,
            pen,
            tal,
            tac,
            tiru,
            tien,
            xp=18,
            hint_ru=htiru,
            hint_en=htien,
        ),
    ]


def build_categories_and_lessons() -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    cats: list[dict[str, Any]] = []
    les: list[dict[str, Any]] = []
    co = 0

    def add_cat(
        cid: str,
        title_ru: str,
        title_en: str,
        isv_lat: str,
        isv_cyr: str,
        icon: str,
    ) -> None:
        nonlocal co
        cats.append(
            category(cid, co, title_ru, title_en, isv_lat, isv_cyr, icon),
        )
        co += 1

    # ---------- Уровень A0–A1: знакомство и алфавит ----------
    add_cat(
        "cat_fc_intro",
        "Введение: что такое межславянский",
        "Introduction: what is Interslavic",
        "Uvod",
        "Увод",
        "school",
    )
    les.append(
        lesson(
            "fc_intro_01",
            "cat_fc_intro",
            0,
            "Зачем учить межславянский",
            "Why learn Interslavic",
            theory(
                "Язык для всех славян",
                "A language for all Slavs",
                [
                    block_text(
                        "Межславянский (Medžuslovjansky) — вспомогательный зборный язык. "
                        "Он не заменяет русский, польский или сербский, но помогает понимать "
                        "соседей без английского посредника.",
                        "Interslavic is an auxiliary zonal language. It does not replace "
                        "Russian, Polish or Serbian, but helps neighbours understand each other.",
                    ),
                    block_text(
                        "В этом курсе вы будете чередовать теорию и практику: таблицы слов, "
                        "нюансы и упражнения — как в плотном учебнике, только короче уроками.",
                        "This course alternates theory and practice: vocabulary tables, nuances "
                        "and exercises — like a dense textbook in short lessons.",
                    ),
                    block_tip(
                        "Пишите вслух межславянские слова с первого дня — так память работает лучше.",
                        "Say Interslavic words aloud from day one — memory works better that way.",
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("jezyk", "језык", "язык", "language"),
                    vocab_row("slavjan", "славјан", "славянин", "Slav"),
                    vocab_row("razuměti", "разумєти", "понимать", "to understand"),
                    vocab_row("učiti", "учити", "учить / учиться", "to learn"),
                ],
                (
                    "Kto jest ty?",
                    "Кто єст ты?",
                    "Выберите верный смысл фразы",
                    "Pick the correct meaning",
                    ["Кто ты?", "Где ты?", "Куда ты?", "Когда ты?"],
                    ["Who are you?", "Where are you?", "Where to?", "When?"],
                    0,
                    "«Kto» — «кто», как в русском.",
                    "«Kto» means «who», like Russian.",
                ),
                (
                    "Ja ___ slavjan.",
                    "Ја ___ славјан.",
                    "jesm",
                    "єсм",
                    "Я — славянин (утверждение с jest).",
                    "I am a Slav.",
                    "Заполните форму «быть» в настоящем.",
                    "Fill the present form of «to be».",
                    "Глагол byti: jest / jesm в зависимости от лица.",
                    "Verb byti: jest / jesm depending on person.",
                ),
                (
                    "понимать (инфинитив)",
                    "to understand (infinitive)",
                    "razuměti",
                    "разумєти",
                    "Напишите инфинитив глагола «понимать».",
                    "Write the infinitive for «to understand».",
                    "Оканчивается на -ěti, как mnogo slov.",
                    "Ends in -ěti, like many verbs.",
                ),
            ),
        ),
    )

    add_cat(
        "cat_fc_alphabet",
        "Алфавит и правила чтения",
        "Alphabet & spelling",
        "Alfabet",
        "Алфабет",
        "menu_book",
    )
    les.append(
        lesson(
            "fc_alpha_01",
            "cat_fc_alphabet",
            0,
            "Латиница: č, š, ž",
            "Latin script: č, š, ž",
            theory(
                "Специальные буквы латиницы",
                "Special Latin letters",
                [
                    block_text(
                        "Буквы č, š, ž передают звуки «ч», «ш», «ж». Они общие для межславянской латиницы.",
                        "Letters č, š, ž stand for «ch», «sh», «zh» sounds. They are standard in Interslavic Latin.",
                    ),
                    block_vocab(
                        [
                            vocab_row("člověk", "чловєк", "человек", "human"),
                            vocab_row("što", "што", "что", "what"),
                            vocab_row("žena", "жена", "женщина", "woman"),
                        ],
                    ),
                    block_tip(
                        "Не путайте č с латинским c: č всегда мягкая «ч».",
                        "Do not confuse č with plain c: č is always «ch» as in church.",
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("čaj", "чај", "чай", "tea"),
                    vocab_row("muž", "муж", "мужчина / муж", "man"),
                    vocab_row("noč", "ночь", "ночь", "night"),
                    vocab_row("duša", "душа", "душа", "soul"),
                ],
                (
                    "Što to jest?",
                    "Што то єст?",
                    "Переведите вопрос",
                    "Translate the question",
                    ["Что это?", "Где это?", "Кто это?", "Когда это?"],
                    ["What is it?", "Where is it?", "Who is it?", "When?"],
                    0,
                    "Što = что.",
                    "Što = what.",
                ),
                (
                    "On jest dobry ___ .",
                    "Он єст добры ___ .",
                    "muž",
                    "муж",
                    "Он добрый человек (мужчина).",
                    "He is a good man.",
                    "Подставьте слово «мужчина».",
                    "Insert the word «man».",
                    "Форма именительного падежа.",
                    "Nominative singular.",
                ),
                (
                    "ночь (существительное)",
                    "night (noun)",
                    "noč",
                    "ночь",
                    "Напишите «ночь» межславянски.",
                    "Write «night» in Interslavic.",
                    "Краткое слово с č.",
                    "Short word with č.",
                ),
            ),
        ),
    )
    les.append(
        lesson(
            "fc_alpha_02",
            "cat_fc_alphabet",
            1,
            "Кириллица и соответствия",
            "Cyrillic correspondences",
            theory(
                "Две азбуки — один язык",
                "Two scripts — one language",
                [
                    block_text(
                        "Можно писать кириллицей: ј как й/j, є как э/е в зависимости от традиции; "
                        "главное — последовательность в одном тексте.",
                        "You can write in Cyrillic: ј as j, є as e — stay consistent within one text.",
                    ),
                    block_grammar(
                        [
                            ["Латиница", "Кириллица"],
                            ["ja", "ја"],
                            ["jest", "јест"],
                            ["učiti", "учити"],
                            ["ě / e", "є / е"],
                        ],
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("ja", "ја", "я", "I"),
                    vocab_row("ty", "ты", "ты", "you"),
                    vocab_row("jest", "јест", "есть", "is"),
                    vocab_row("nie", "не", "не / нет", "not / no"),
                ],
                (
                    "Ja učim.",
                    "Ја учим.",
                    "Что означает фраза?",
                    "What does the phrase mean?",
                    ["Я учу.", "Ты учишь.", "Мы учим.", "Они учат."],
                    ["I study.", "You study.", "We study.", "They study."],
                    0,
                    "Окончание -im для «я» в настоящем (типичная модель).",
                    "Ending -im marks «I» in present (common pattern).",
                ),
                (
                    "Ty ___ student.",
                    "Ты ___ студент.",
                    "jest",
                    "јест",
                    "Ты студент.",
                    "You are a student.",
                    "Форма «быть» для он/она/оно часто jest.",
                    "Third-person «to be» is often jest.",
                    "Если ответ «jest», в кириллице тоже «јест».",
                    "If answer «jest», Cyrillic «јест».",
                ),
                (
                    "нет (отрицание)",
                    "no (negation)",
                    "nie",
                    "не",
                    "Короткое слово отрицания.",
                    "Short negation word.",
                    "Как в польском «nie».",
                    "Like Polish «nie».",
                ),
            ),
        ),
    )

    add_cat(
        "cat_fc_greetings",
        "Приветствия и бытовой минимум",
        "Greetings & survival phrases",
        "Pozdravy",
        "Поздравы",
        "waving_hand",
    )
    les.append(
        lesson(
            "fc_gr_01",
            "cat_fc_greetings",
            0,
            "Здравствуйте и до свидания",
            "Hello and goodbye",
            theory(
                "Первые фразы в диалоге",
                "First phrases in dialogue",
                [
                    block_text(
                        "Формы вежливости близки всем славянам: день, вечер, до встречи.",
                        "Politeness forms are close for all Slavs: day, evening, until we meet again.",
                    ),
                    block_vocab(
                        [
                            vocab_row("Zdrav budi!", "Здрав буди!", "Будь здоров / привет!", "Hello!"),
                            vocab_row("Dobry denj!", "Добры день!", "Добрый день!", "Good afternoon!"),
                            vocab_row("Do viděnja!", "До видєња!", "До свидания!", "Goodbye!"),
                            vocab_row("Hvala", "Хвала", "Спасибо", "Thanks"),
                            vocab_row("Prosim", "Просим", "Пожалуйста", "Please"),
                        ],
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("Dobro jutro!", "Добро јутро!", "Доброе утро!", "Good morning!"),
                    vocab_row("Laku noč", "Лаку ноч!", "Спокойной ночи", "Good night"),
                    vocab_row("Izvinite", "Извините", "Извините", "Excuse me"),
                    vocab_row("Na zdravje!", "На здравје!", "За здоровье! (тост)", "Cheers!"),
                ],
                (
                    "Prosim, jednu kavu.",
                    "Просим, једну каву.",
                    "Выберите перевод",
                    "Choose translation",
                    [
                        "Пожалуйста, один кофе.",
                        "Спасибо за кофе.",
                        "Где кофе?",
                        "Я не хочу кофе.",
                    ],
                    [
                        "Please, one coffee.",
                        "Thanks for the coffee.",
                        "Where is the coffee?",
                        "I don't want coffee.",
                    ],
                    0,
                    "Prosim часто начинает просьбу.",
                    "Prosim often starts a request.",
                ),
                (
                    "Do ___!",
                    "До ___!",
                    "viděnja",
                    "видєња",
                    "До свидания!",
                    "Goodbye!",
                    "Устойчивое прощание.",
                    "Fixed farewell phrase.",
                    "Два слова: предлог + существительное.",
                    "Two words: preposition + noun.",
                ),
                (
                    "Спасибо",
                    "Thank you",
                    "Hvala",
                    "Хвала",
                    "Одно слово благодарности.",
                    "One word for thanks.",
                    "Очень распространено во всех славянских языках.",
                    "Very common across Slavic languages.",
                ),
            ),
        ),
    )

    # ---------- Числа (три плотных урока вместо десяти дробных) ----------
    add_cat(
        "cat_fc_numbers",
        "Числа и счёт",
        "Numbers & counting",
        "Čisla",
        "Числа",
        "pin",
    )
    les.append(
        lesson(
            "fc_num_01",
            "cat_fc_numbers",
            0,
            "От нуля до пяти",
            "From zero to five",
            theory(
                "Первые числительные",
                "First numerals",
                [
                    block_text(
                        "Запоминайте группами: 0–5 часто звучат знакомо русскому уху.",
                        "Learn in chunks: 0–5 often sound familiar to Russian ears.",
                    ),
                    block_vocab(
                        [
                            vocab_row("nula", "нула", "ноль", "zero"),
                            vocab_row("jedin", "једин", "один", "one"),
                            vocab_row("dva", "два", "два", "two"),
                            vocab_row("tri", "три", "три", "three"),
                            vocab_row("četyri", "четыри", "четыре", "four"),
                            vocab_row("pet", "пет", "пять", "five"),
                        ],
                    ),
                    block_tip(
                        "Число «два» совпадает с русским по форме — используйте как якорь памяти.",
                        "«Dva» matches Russian «dva» — use it as a memory anchor.",
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("tri", "три", "3", "3"),
                    vocab_row("pet", "пет", "5", "5"),
                    vocab_row("jedin", "једин", "1", "1"),
                    vocab_row("četyri", "четыри", "4", "4"),
                ],
                (
                    "Tri brata.",
                    "Три брата.",
                    "Что означает?",
                    "Meaning?",
                    ["Три брата.", "Три сестры.", "Четыре брата.", "Два брата."],
                    ["Three brothers.", "Three sisters.", "Four brothers.", "Two brothers."],
                    0,
                    "Brat = брат.",
                    "Brat = brother.",
                ),
                (
                    "Imam ___ knig (čislo 4).",
                    "Имам ___ книг (число 4).",
                    "četyri",
                    "четыри",
                    "У меня четыре книги.",
                    "I have four books.",
                    "Число «четыре».",
                    "The numeral «four».",
                    "Буква č как «ч».",
                    "Letter č as «ch».",
                ),
                (
                    "пять",
                    "five",
                    "pet",
                    "пет",
                    "Напишите слово «пять».",
                    "Write the word «five».",
                    "Короткое слово.",
                    "Short word.",
                ),
            ),
        ),
    )
    les.append(
        lesson(
            "fc_num_02",
            "cat_fc_numbers",
            1,
            "От шести до десяти",
            "From six to ten",
            theory(
                "Вторая пятёрка",
                "Second five",
                [
                    block_vocab(
                        [
                            vocab_row("šest", "шест", "шесть", "six"),
                            vocab_row("sedm", "седм", "семь", "seven"),
                            vocab_row("osm", "осм", "восемь", "eight"),
                            vocab_row("devęt", "девęт", "девять", "nine"),
                            vocab_row("desęt", "десęт", "десять", "ten"),
                        ],
                    ),
                    block_text(
                        "Дальше — составные числа: jedinnadsęt (11), dvanaedsęt (12) и т.п. в следующем уроке.",
                        "Next come compounds: jedinnadsęt (11), dvanaedsęt (12), etc. in the next lesson.",
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("sedm", "седм", "7", "7"),
                    vocab_row("desęt", "десęт", "10", "10"),
                    vocab_row("šest", "шест", "6", "6"),
                    vocab_row("devęt", "девęт", "9", "9"),
                ],
                (
                    "Koliko jest sedm?",
                    "Колико єст седм?",
                    "Что спрашивают?",
                    "What is being asked?",
                    ["Сколько будет семь?", "Где семь?", "Кто семь?", "Когда семь?"],
                    ["How much is seven?", "Where is seven?", "Who is seven?", "When seven?"],
                    0,
                    "Koliko / koliko — «сколько».",
                    "Koliko asks «how much/how many».",
                ),
                (
                    "___ oviec jest desęt.",
                    "___ овец єст десęт.",
                    "Devęt",
                    "Девęт",
                    "Девять овец (учебный пример).",
                    "Nine sheep (training line).",
                    "Число 9.",
                    "Number nine.",
                    "Запомните ę как «ен» в слоге.",
                    "Remember ę as nasal e.",
                ),
                (
                    "десять",
                    "ten",
                    "desęt",
                    "десęт",
                    "Напишите «десять».",
                    "Write «ten».",
                    "Оканчивается на -ęt.",
                    "Ends with -ęt.",
                ),
            ),
        ),
    )
    les.append(
        lesson(
            "fc_num_03",
            "cat_fc_numbers",
            2,
            "Числа 11–100 и порядок слов",
            "Numbers 11–100 & word order",
            theory(
                "Составление десятков",
                "Building tens",
                [
                    block_text(
                        "Десять + единица: dvadsęt jedin (21), tridesęt tri (33) — модель повторяется.",
                        "Ten + unit: dvadsęt jedin (21), tridesęt tri (33) — pattern repeats.",
                    ),
                    block_grammar(
                        [
                            ["Число", "Пример"],
                            ["11", "jedinnadsęt"],
                            ["12", "dvanaedsęt"],
                            ["20", "dvadsęt"],
                            ["100", "sto"],
                        ],
                    ),
                    block_tip(
                        "В живой речи межславянцы часто упрощают длинные формы — здесь учим стандарт учебника.",
                        "In live speech forms may shorten — here we teach the textbook standard.",
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("sto", "сто", "сто", "hundred"),
                    vocab_row("dvadsęt", "двадсęт", "двадцать", "twenty"),
                    vocab_row("tridesęt", "тридесęт", "тридцать", "thirty"),
                    vocab_row("sto jedin", "сто једин", "сто один", "one hundred one"),
                ],
                (
                    "Dvadsęt tri ljudij.",
                    "Двадсęт три лјудий.",
                    "Переведите",
                    "Translate",
                    ["Двадцать три человека.", "Тридцать два человека.", "Двадцать два человека.", "Три человека."],
                    ["Twenty-three people.", "Thirty-two people.", "Twenty-two people.", "Three people."],
                    0,
                    "Ljudije — люди.",
                    "Ljudije means people.",
                ),
                (
                    "Moje čislo jest ___ (латиницей: сто).",
                    "Моє число єст ___ (латиница: сто).",
                    "sto",
                    "сто",
                    "Моё число — сто.",
                    "My number is one hundred.",
                    "Три буквы.",
                    "Three letters.",
                    "Как русское «сто».",
                    "Like Russian sto.",
                ),
                (
                    "тридцать",
                    "thirty",
                    "tridesęt",
                    "тридесęт",
                    "Напишите «тридцать».",
                    "Write «thirty».",
                    "Приставка tri- + desęt.",
                    "Prefix tri- + desęt.",
                ),
            ),
        ),
    )

    from .curriculum_extend import extend_course

    extend_course(add_cat, les)

    return cats, les
