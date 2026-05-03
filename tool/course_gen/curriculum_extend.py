"""
Продолжение программы: A2–B2+ (время, лексика, грамматика, стиль).
Расширяйте этот файл новыми add_cat / lesson по мере роста курса.
"""
from __future__ import annotations

from typing import Any, Callable

from .helpers import (
    block_grammar,
    block_text,
    block_tip,
    block_vocab,
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
    q_lat, q_cyr, ins_ru, ins_en, oru, oen, ci, hr, he = mc
    sl, sc, al, ac, tru, tre, firu, fien, hfru, hfen = fb
    pru, pen, tal, tac, tiru, tien, htiru, htien = ti
    return [
        ex_word_match(pairs_wm, "Соедините пары", "Match pairs", xp=12),
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


def extend_course(
    add_cat: Callable[..., None],
    les: list[dict[str, Any]],
) -> None:
    """Добавляет категории и уроки к уже собранному списку."""

    add_cat(
        "cat_fc_time",
        "Время суток и часы",
        "Time of day & clock",
        "Čas",
        "Час",
        "schedule",
    )
    les.append(
        lesson(
            "fc_time_01",
            "cat_fc_time",
            0,
            "Утро, день, ночь",
            "Morning, day, night",
            theory(
                "Как говорить о времени",
                "Talking about time",
                [
                    block_text(
                        "Для базового общения достаточно суточных ритмов и часов.",
                        "For basic interaction daily rhythms and hours are enough.",
                    ),
                    block_vocab(
                        [
                            vocab_row("jutro", "јутро", "утро", "morning"),
                            vocab_row("denj", "день", "день", "day"),
                            vocab_row("večer", "вечер", "вечер", "evening"),
                            vocab_row("noč", "ночь", "ночь", "night"),
                            vocab_row("čas", "час", "час", "hour"),
                            vocab_row("minuta", "минута", "минута", "minute"),
                        ],
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("ranje", "ранје", "рано", "early"),
                    vocab_row("pozdně", "позднє", "поздно", "late"),
                    vocab_row("sedym časov", "седым часов", "семь часов", "seven o'clock"),
                    vocab_row("večer", "вечер", "вечером", "in the evening"),
                ],
                (
                    "Kotory čas jest?",
                    "Которы час єст?",
                    "О чём спрашивают?",
                    "What is asked?",
                    ["Который час?", "Какой день?", "Где время?", "Кто час?"],
                    ["What time?", "What day?", "Where is time?", "Who is the hour?"],
                    0,
                    "Kotory čas — типичный вопрос о времени.",
                    "Kotory čas asks the time.",
                ),
                (
                    "V ___ jest světlo.",
                    "В ___ єст свєтло.",
                    "denju",
                    "деню",
                    "Днём есть свет (учебная фраза).",
                    "By day there is light (teaching line).",
                    "Локатив «днём» (упрощённо).",
                    "Locative «in the day» (simplified).",
                    "Корень den-.",
                    "Root den-.",
                ),
                (
                    "минута",
                    "minute",
                    "minuta",
                    "минута",
                    "Как будет «минута»?",
                    "How do you say «minute»?",
                    "Как в русском.",
                    "Like Russian.",
                ),
            ),
        ),
    )

    add_cat(
        "cat_fc_colors",
        "Цвета и описание",
        "Colours & description",
        "Barvy",
        "Барвы",
        "palette",
    )
    les.append(
        lesson(
            "fc_col_01",
            "cat_fc_colors",
            0,
            "Основные цвета",
            "Basic colours",
            theory(
                "Прилагательные цвета",
                "Colour adjectives",
                [
                    block_text(
                        "Цвета согласуются с существительным в роде и числе — как в русском, но окончания проще запоминать блоками.",
                        "Colours agree with nouns in gender and number — like Russian, learn endings in blocks.",
                    ),
                    block_vocab(
                        [
                            vocab_row("běly", "бєлы", "белый", "white"),
                            vocab_row("črny", "чрны", "чёрный", "black"),
                            vocab_row("krasny", "красны", "красный", "red"),
                            vocab_row("zeleny", "зелены", "зелёный", "green"),
                            vocab_row("synji", "сынji", "синий", "blue"),
                            vocab_row("žuty", "жуты", "жёлтый", "yellow"),
                        ],
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("krasny dom", "красны дом", "красный дом", "red house"),
                    vocab_row("zelena trava", "зелена трава", "зелёная трава", "green grass"),
                    vocab_row("běly oblak", "бєлы облак", "белое облако", "white cloud"),
                    vocab_row("črna noč", "чрна ночь", "чёрная ночь", "black night"),
                ],
                (
                    "To jest žuty koš.",
                    "То єст жуты кош.",
                    "Какой цвет?",
                    "Which colour?",
                    ["Жёлтая корзина.", "Красная корзина.", "Синяя корзина.", "Чёрная корзина."],
                    ["Yellow basket.", "Red basket.", "Blue basket.", "Black basket."],
                    0,
                    "Žuty — жёлтый.",
                    "Žuty means yellow.",
                ),
                (
                    "Nebo jest ___ .",
                    "Небо єст ___ .",
                    "synje",
                    "сынје",
                    "Небо синее.",
                    "The sky is blue.",
                    "Краткая форма среднего рода.",
                    "Neuter short form.",
                    "Оканчивается на -je.",
                    "Ends with -je.",
                ),
                (
                    "зелёный",
                    "green",
                    "zeleny",
                    "зелены",
                    "Мужской род, именительный.",
                    "Masculine nominative.",
                    "Один из самых частых цветов.",
                    "One of the most frequent colours.",
                ),
            ),
        ),
    )

    add_cat(
        "cat_fc_family",
        "Семья и люди",
        "Family & people",
        "Semja",
        "Семья",
        "family_restroom",
    )
    les.append(
        lesson(
            "fc_fam_01",
            "cat_fc_family",
            0,
            "Родственники",
            "Relatives",
            theory(
                "Словарь семьи",
                "Family vocabulary",
                [
                    block_vocab(
                        [
                            vocab_row("mati", "мати", "мать", "mother"),
                            vocab_row("otьc", "отьць", "отец", "father"),
                            vocab_row("brat", "брат", "брат", "brother"),
                            vocab_row("sestra", "сестра", "сестра", "sister"),
                            vocab_row("syn", "сын", "сын", "son"),
                            vocab_row("dočь", "дочь", "дочь", "daughter"),
                            vocab_row("muž", "муж", "муж", "husband"),
                            vocab_row("žena", "жена", "жена", "wife"),
                        ],
                    ),
                    block_tip(
                        "Слова «матерь/отец» часто в формах mati / otьc — запоминайте парами родитель-дитё.",
                        "Words for parents often mati / otьc — memorize parent-child pairs.",
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("starši", "старши", "родители", "parents"),
                    vocab_row("děti", "дєти", "дети", "children"),
                    vocab_row("vnuk", "внук", "внук", "grandson"),
                    vocab_row("babica", "бабица", "бабушка", "grandmother"),
                ],
                (
                    "Moja mati jest v domu.",
                    "Моя мати єст в дому.",
                    "Кто дома?",
                    "Who is at home?",
                    ["Моя мама дома.", "Мой отец дома.", "Моя сестра дома.", "Я дома."],
                    ["My mother is home.", "My father is home.", "My sister is home.", "I am home."],
                    0,
                    "Moja — женский род.",
                    "Moja marks feminine.",
                ),
                (
                    "Moj ___ pracuje.",
                    "Мой ___ працује.",
                    "otьc",
                    "отьць",
                    "Мой отец работает.",
                    "My father works.",
                    "Родитель мужского рода.",
                    "Masculine parent.",
                    "Две буквы на конце церковнославянская традиция.",
                    "Otьc spelling tradition.",
                ),
                (
                    "сестра",
                    "sister",
                    "sestra",
                    "сестра",
                    "Напишите слово.",
                    "Write the word.",
                    "Как в русском.",
                    "Like Russian.",
                ),
            ),
        ),
    )

    add_cat(
        "cat_fc_food",
        "Еда и стол",
        "Food & table",
        "Jedlo",
        "Једло",
        "restaurant",
    )
    les.append(
        lesson(
            "fc_food_01",
            "cat_fc_food",
            0,
            "Хлеб, вода, еда",
            "Bread, water, food",
            theory(
                "На кухне и в гостях",
                "In the kitchen and as a guest",
                [
                    block_text(
                        "Еда — богатая тема: начните с базовых существительных и глаголов «есть / пить».",
                        "Food is a rich topic: start with basic nouns and verbs «to eat / drink».",
                    ),
                    block_vocab(
                        [
                            vocab_row("hlěb", "хлєб", "хлеб", "bread"),
                            vocab_row("voda", "вода", "вода", "water"),
                            vocab_row("mlěko", "млєко", "молоко", "milk"),
                            vocab_row("meso", "месо", "мясо", "meat"),
                            vocab_row("ovočje", "овочје", "овощи / фрукты", "fruit/veg"),
                            vocab_row("jesti", "јести", "есть", "to eat"),
                            vocab_row("piti", "пити", "пить", "to drink"),
                        ],
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("sol", "соль", "соль", "salt"),
                    vocab_row("cukor", "цукор", "сахар", "sugar"),
                    vocab_row("hlěb", "хлєб", "хлеб", "bread"),
                    vocab_row("meso", "месо", "мясо", "meat"),
                ],
                (
                    "Čto ty hočeš jesti?",
                    "Што ты хочешь јести?",
                    "Вопрос",
                    "Question",
                    ["Что ты хочешь есть?", "Когда ты ешь?", "Где хлеб?", "Кто ест?"],
                    ["What do you want to eat?", "When do you eat?", "Where is bread?", "Who eats?"],
                    0,
                    "Hočeš — от htěti.",
                    "Hočeš comes from htěti.",
                ),
                (
                    "Ja pijem ___ .",
                    "Ја пијем ___ .",
                    "vodu",
                    "воду",
                    "Я пью воду.",
                    "I drink water.",
                    "Винительный падеж «воду».",
                    "Accusative «water».",
                    "Женский род в форме -u.",
                    "Feminine form in -u.",
                ),
                (
                    "хлеб",
                    "bread",
                    "hlěb",
                    "хлєб",
                    "Напишите «хлеб».",
                    "Write «bread».",
                    "Буква hl- как в «хлеб».",
                    "hl- cluster.",
                ),
            ),
        ),
    )

    add_cat(
        "cat_fc_verbs",
        "Глаголы: настоящее время",
        "Verbs: present tense",
        "Glagoly",
        "Глаголы",
        "menu_book",
    )
    les.append(
        lesson(
            "fc_vb_01",
            "cat_fc_verbs",
            0,
            "Спряжение по образцу",
            "Conjugation patterns",
            theory(
                "Три тематических класса",
                "Three thematic classes",
                [
                    block_text(
                        "Глаголы на -ati, -ěti, -iti имеют разные настоящие окончания; начните с самых частых -am/-aš/-a.",
                        "Verbs in -ati, -ěti, -iti have different present endings; start with frequent -am/-aš/-a.",
                    ),
                    block_grammar(
                        [
                            ["Лицо", "dělati (делать)"],
                            ["ja", "dělam"],
                            ["ty", "dělaš"],
                            ["on", "děla"],
                        ],
                    ),
                    block_tip(
                        "Глагол «быть» неправильный: jest, esmo, jeste… учите отдельно.",
                        "Verb «to be» is irregular: learn jest, esmo, jeste… separately.",
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("dělam", "дєлам", "я делаю", "I do"),
                    vocab_row("dělaš", "дєлаш", "ты делаешь", "you do"),
                    vocab_row("govoriti", "говорити", "говорить", "to speak"),
                    vocab_row("govorju", "говорју", "я говорю", "I speak"),
                ],
                (
                    "Ty govoriš po-anglijsky?",
                    "Ты говоришь по-англијски?",
                    "О чём речь?",
                    "About what?",
                    ["Ты говоришь по-английски?", "Ты поёшь?", "Ты спишь?", "Ты читаешь?"],
                    ["Do you speak English?", "Do you sing?", "Do you sleep?", "Do you read?"],
                    0,
                    "Govoriti — говорить.",
                    "Govoriti means to speak.",
                ),
                (
                    "My ___ dom.",
                    "Мы ___ дом.",
                    "idemo",
                    "идемо",
                    "Мы идём домой.",
                    "We go home.",
                    "Глагол «идти» — формы на -emo для мы.",
                    "Verb «go» — we-form -emo.",
                    "Корень id- как в русском «ид-».",
                    "Root id- like Russian «id-».",
                ),
                (
                    "я делаю",
                    "I do",
                    "dělam",
                    "дєлам",
                    "Напишите форму «я делаю».",
                    "Write «I do».",
                    "Глагол dělati.",
                    "Verb dělati.",
                ),
            ),
        ),
    )

    add_cat(
        "cat_fc_cases",
        "Падежи: именитель и винительный",
        "Cases: nominative & accusative",
        "Padeži",
        "Падєжи",
        "menu_book",
    )
    les.append(
        lesson(
            "fc_case_01",
            "cat_fc_cases",
            0,
            "Кто что делает — прямой объект",
            "Who does what — direct object",
            theory(
                "Винительный падеж",
                "Accusative case",
                [
                    block_text(
                        "Мужской неодушевлённый предмет часто совпадает с именительным; одушевлённый получает -a.",
                        "Inanimate masculine often equals nominative; animate masculine takes -a.",
                    ),
                    block_grammar(
                        [
                            ["Пример", "Форма"],
                            ["вижу брата", "brata"],
                            ["вижу дом", "dom"],
                            ["вижу ženu", "ženu"],
                        ],
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("kniga", "книга", "книга", "book"),
                    vocab_row("knigu", "книгу", "книгу (вин.)", "book (acc.)"),
                    vocab_row("brat", "брат", "брат", "brother"),
                    vocab_row("brata", "брата", "брата (вин.)", "brother (acc.)"),
                ],
                (
                    "Ja vižu brata.",
                    "Ја віжу брата.",
                    "Что я вижу?",
                    "What do I see?",
                    ["Брата.", "Дом.", "Небо.", "Себя."],
                    ["My brother.", "A house.", "The sky.", "Myself."],
                    0,
                    "Vižu от viděti.",
                    "Vižu from viděti.",
                ),
                (
                    "Čitajem ___ .",
                    "Читајем ___ .",
                    "knigu",
                    "книгу",
                    "Читаю книгу.",
                    "I read a book.",
                    "Женский род вин. -u.",
                    "Feminine acc. -u.",
                    "Как русская «книгу».",
                    "Like Russian «knigu».",
                ),
                (
                    "брата (винительный)",
                    "brother (acc.)",
                    "brata",
                    "брата",
                    "Напишите форму.",
                    "Write the form.",
                    "Для одушевлённого мужского.",
                    "For animate masculine.",
                ),
            ),
        ),
    )

    add_cat(
        "cat_fc_past",
        "Прошедшее время",
        "Past tense",
        "Prošlost",
        "Прошлость",
        "menu_book",
    )
    les.append(
        lesson(
            "fc_past_01",
            "cat_fc_past",
            0,
            "Что уже случилось",
            "What already happened",
            theory(
                "Прошедшее по образцу l-form",
                "Past tense via l-participles",
                [
                    block_text(
                        "Для большинства глаголов прошедшее строится через суффикс -l -la -lo -li и вспомогательное byti при необходимости.",
                        "For most verbs past uses -l -la -lo -li and auxiliary byti when needed.",
                    ),
                    block_grammar(
                        [
                            ["Пример", "Значение"],
                            ["ja čital jesm", "я читал"],
                            ["ona pisala jest", "она писала"],
                            ["oni šli sut", "они шли"],
                        ],
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("čital", "читал", "читал", "read (m.)"),
                    vocab_row("čitala", "читала", "читала", "read (f.)"),
                    vocab_row("hodil", "ходил", "ходил", "walked"),
                    vocab_row("govoril", "говорил", "говорил", "spoke"),
                ],
                (
                    "Ona pisala pismo.",
                    "Она писала письмо.",
                    "Что она делала?",
                    "What did she do?",
                    ["Писала письмо.", "Читала книгу.", "Спала.", "Ела мясо."],
                    ["Wrote a letter.", "Read a book.", "Slept.", "Ate meat."],
                    0,
                    "Pisati — писать.",
                    "Pisati means to write.",
                ),
                (
                    "My ___ včera tam.",
                    "Мы ___ вчера там.",
                    "byli",
                    "были",
                    "Мы были там вчера.",
                    "We were there yesterday.",
                    "Множественное число прошедшего.",
                    "Plural past.",
                    "Форма как русское «были».",
                    "Like Russian «byli».",
                ),
                (
                    "он читал",
                    "he read",
                    "čital",
                    "читал",
                    "Напишите краткое причастие муж. рода.",
                    "Write masculine short participle.",
                    "Глагол čitati.",
                    "Verb čitati.",
                ),
            ),
        ),
    )

    add_cat(
        "cat_fc_future",
        "Будущее и намерение",
        "Future & intention",
        "Budnost",
        "Будность",
        "flight",
    )
    les.append(
        lesson(
            "fc_fut_01",
            "cat_fc_future",
            0,
            "Что будет дальше",
            "What happens next",
            theory(
                "Будущее время",
                "Future tense",
                [
                    block_text(
                        "Частая модель: budu / budeš / budet + инфинитив или perfektивная форма по контексту.",
                        "Common pattern: budu / budeš / budet + infinitive or perfective form depending on context.",
                    ),
                    block_tip(
                        "Для краткости курс использует будущее через budu + infinitiv там, где это понятно всем славянам.",
                        "For brevity this course uses budu + infinitive where all Slavs understand.",
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("budu", "буду", "буду", "I will"),
                    vocab_row("budeš", "будешь", "будешь", "you will"),
                    vocab_row("budemo", "будемо", "будем", "we will"),
                    vocab_row("hoču", "хочу", "хочу", "I want"),
                ],
                (
                    "Ja budu učiti.",
                    "Ја буду учити.",
                    "Что означает?",
                    "Meaning?",
                    ["Я буду учиться.", "Я учусь.", "Я учился.", "Я не учусь."],
                    ["I will study.", "I study.", "I studied.", "I don't study."],
                    0,
                    "Budu + infinitive.",
                    "Budu + infinitive.",
                ),
                (
                    "On ___ prihoditi sutra.",
                    "Он ___ приходити сутра.",
                    "bude",
                    "буде",
                    "Он будет приходить завтра.",
                    "He will come tomorrow.",
                    "Третье лицо будущего.",
                    "Third person future.",
                    "Sutra — завтра.",
                    "Sutra means tomorrow.",
                ),
                (
                    "мы будем",
                    "we will",
                    "budemo",
                    "будемо",
                    "Напишите форму для «мы будем».",
                    "Write «we will».",
                    "Окончание -emo.",
                    "Ending -emo.",
                ),
            ),
        ),
    )

    add_cat(
        "cat_fc_prep",
        "Предлоги и место",
        "Prepositions & place",
        "Predlogy",
        "Предлогы",
        "pin",
    )
    les.append(
        lesson(
            "fc_prep_01",
            "cat_fc_prep",
            0,
            "Где и куда",
            "Where & whither",
            theory(
                "Основные предлоги",
                "Core prepositions",
                [
                    block_vocab(
                        [
                            vocab_row("v", "в", "в / во", "in"),
                            vocab_row("na", "на", "на", "on"),
                            vocab_row("pod", "под", "под", "under"),
                            vocab_row("nad", "над", "над", "above"),
                            vocab_row("pri", "при", "у / при", "at/near"),
                            vocab_row("do", "до", "до", "to/until"),
                            vocab_row("od", "од", "от", "from"),
                        ],
                    ),
                    block_text(
                        "Вопрос «где?» часто с v + lokativ (формы как в родительном для многих слов на первом этапе).",
                        "«Where?» often uses v + locative (forms may align with genitive early on).",
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("v domu", "в дому", "в доме", "in the house"),
                    vocab_row("na stole", "на столе", "на столе", "on the table"),
                    vocab_row("od domu", "од дому", "от дома", "from the house"),
                    vocab_row("do grada", "до града", "до города", "to the city"),
                ],
                (
                    "Gdě jest kniga?",
                    "Гдє єст книга?",
                    "Что спрашивают?",
                    "What is asked?",
                    ["Где книга?", "Чья книга?", "Когда книга?", "Зачем книга?"],
                    ["Where is the book?", "Whose book?", "When book?", "Why book?"],
                    0,
                    "Gdě — где.",
                    "Gdě means where.",
                ),
                (
                    "Kniga jest ___ stole.",
                    "Книга єст ___ столе.",
                    "na",
                    "на",
                    "Книга на столе.",
                    "The book is on the table.",
                    "Предлог «на».",
                    "Preposition «on».",
                    "Локатив формы на -e.",
                    "Locative ending -e.",
                ),
                (
                    "от дома",
                    "from home",
                    "od doma",
                    "од дома",
                    "Напишите «от дома» двумя словами.",
                    "Write «from home» in two words.",
                    "Родительный после od.",
                    "Genitive after od.",
                ),
            ),
        ),
    )

    add_cat(
        "cat_fc_style",
        "Стиль и нюансы",
        "Style & nuance",
        "Stil",
        "Стиль",
        "palette",
    )
    les.append(
        lesson(
            "fc_style_01",
            "cat_fc_style",
            0,
            "Вежливость и прямота",
            "Politeness vs directness",
            theory(
                "Регистры общения",
                "Registers",
                [
                    block_text(
                        "Межславянский позволяет и очень прямую речь (как у соседей за столом), и мягкие формы "
                        "с prosim / izvinite / može li… как в современном межнациональном этикете.",
                        "Interslavic allows both very direct speech (like neighbours at a table) and soft forms "
                        "with prosim / izvinite / može li… like modern cross-border etiquette.",
                    ),
                    block_vocab(
                        [
                            vocab_row("može li…?", "може ли…?", "можно ли…?", "could one…?"),
                            vocab_row("budьte laskavy", "будьте ласкавы", "будьте любезны", "please/be kind"),
                            vocab_row("bez obzira", "без обзира", "несмотря ни на что", "regardless"),
                        ],
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("prosim", "просим", "пожалуйста", "please"),
                    vocab_row("izvinite", "извините", "извините", "excuse me"),
                    vocab_row("ne žaluj", "не жалуй", "не беспокойся", "don't worry"),
                    vocab_row("s udovoljstvijem", "с удовольствием", "с удовольствием", "with pleasure"),
                ],
                (
                    "Može li pomoći?",
                    "Може ли помогти?",
                    "Какой смысл?",
                    "Meaning?",
                    ["Можно помочь?", "Нужно помочь?", "Я не помогу?", "Помоги сейчас!"],
                    ["May I help?", "Must I help?", "I won't help?", "Help now!"],
                    0,
                    "Može li — уступка мягкости.",
                    "Može li softens a request.",
                ),
                (
                    "Izvinite, ja ___ razuměju slabo.",
                    "Извините, ја ___ разумєю слабо.",
                    "ne",
                    "не",
                    "Извините, я плохо понимаю.",
                    "Sorry, I understand poorly.",
                    "Отрицание с ne.",
                    "Negation with ne.",
                    "Частая фраза для учебника.",
                    "Common learner phrase.",
                ),
                (
                    "пожалуйста",
                    "please",
                    "Prosim",
                    "Просим",
                    "Вежливая просьба одним словом.",
                    "Polite request one word.",
                    "С заглавной при начале предложения.",
                    "Capitalize at sentence start.",
                ),
            ),
        ),
    )

    add_cat(
        "cat_fc_native",
        "Уровень «рядом с носителем»",
        "Near-native finesse",
        "Native-like",
        "Носитель",
        "school",
    )
    les.append(
        lesson(
            "fc_nat_01",
            "cat_fc_native",
            0,
            "Идиомы и образные выражения",
            "Idioms & imagery",
            theory(
                "Живой слой языка",
                "Living layer of the language",
                [
                    block_text(
                        "Образные выражения не всегди одинаковы во всех славянских языках — здесь собраны формы, "
                        "понятные большинству без перевода на английский.",
                        "Idioms are not identical across Slavic languages — here we pick forms most Slavs grasp "
                        "without English.",
                    ),
                    block_vocab(
                        [
                            vocab_row("truditi glavu", "трудити главу", "ломать голову", "to puzzle over"),
                            vocab_row("držati jazyk za zubami", "держати језык за зубами", "держать язык за зубами", "hold one's tongue"),
                            vocab_row("biti v oblakah", "быти в облаках", "быть в облаках", "be in the clouds"),
                        ],
                    ),
                    block_tip(
                        "На уровне «носитель-подобный» важно не только правило, но и выбор образа: не смешивайте две метафоры в одном предложении.",
                        "At near-native level choosing one clear image matters: don't mix two metaphors in one sentence.",
                    ),
                ],
            ),
            _std_quartet(
                [
                    vocab_row("glava bolit", "глава болит", "голова болит", "head hurts"),
                    vocab_row("srce raduje", "срце радује", "сердце радуется", "heart rejoices"),
                    vocab_row("oko za oko", "око за око", "око за око", "eye for eye"),
                    vocab_row("čas pokazyvaje pravdu", "час показываје правду", "время показывает правду", "time shows truth"),
                ],
                (
                    "On jest v oblakah.",
                    "Он єст в облаках.",
                    "Идиоматический смысл?",
                    "Idiomatic sense?",
                    ["Он мечтает / не вникает в детали.", "Он в самолёте.", "Он мокрый.", "Он спит."],
                    ["He daydreams / is not grounded.", "He is on a plane.", "He is wet.", "He sleeps."],
                    0,
                    "Быть в облаках — оторванность.",
                    "Being in clouds — absent-minded.",
                ),
                (
                    "Ne mogų ___ glavu nad problemoj.",
                    "Не могу ___ главу над проблемой.",
                    "slomiti",
                    "сломити",
                    "Не могу сломить голову над проблемой (учебная калька).",
                    "I cannot break my head over the problem (teaching calque).",
                    "Инфинитив трудить/сломить в образном выражении.",
                    "Infinitive in idiomatic frame.",
                    "В речи чаще «truditi glavu».",
                    "Often «truditi glavu» in real speech.",
                ),
                (
                    "небо и земля",
                    "heaven and earth",
                    "nebo i zemlja",
                    "небо и земља",
                    "Напишите парный образ «небо и земля».",
                    "Write the pair «heaven and earth».",
                    "Классический контраст.",
                    "Classic contrast.",
                ),
            ),
        ),
    )
