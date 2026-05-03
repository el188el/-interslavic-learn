"""
Полная дорожная карта курса: все категории задаются здесь (латиница в title_isv_lat — основной ярлык ISV).
Уроки дописываются в curriculum.py / curriculum_extend.py; категории без уроков остаются «скоро» в приложении.
Пояснения для ученика — только ru/en (см. COURSE_PLAN.txt).
"""
from __future__ import annotations

from typing import Any


def _c(
    order: int,
    cid: str,
    title_ru: str,
    title_en: str,
    isv_lat: str,
    isv_cyr: str,
    icon: str,
) -> dict[str, Any]:
    return {
        "id": cid,
        "order": order,
        "title_ru": title_ru,
        "title_en": title_en,
        "title_isv_lat": isv_lat,
        "title_isv_cyr": isv_cyr,
        "icon": icon,
    }


# Единый порядок: от A0 к продвинутому уровню и «сообщество / граница».
FULL_SYLLABUS: list[dict[str, Any]] = [
    _c(0, "cat_fc_intro", "Введение: зачем межславянский", "Introduction: why Interslavic", "Medžuslovjansky — začto?", "Меджусловјанскы — зачто?", "school"),
    _c(1, "cat_fc_alphabet", "Алфавит и правила чтения", "Alphabet & spelling", "Alfabet i pravila čitanja", "Алфабет и правила читанија", "menu_book"),
    _c(2, "cat_fc_pronunciation", "Произношение и ударение", "Pronunciation & stress", "Izgovor i udaranje", "Изговор и ударение", "record_voice_over"),
    _c(3, "cat_fc_greetings", "Приветствия и бытовой минимум", "Greetings & survival phrases", "Pozdravy i najnužnije frazy", "Поздравы и најнужније фразы", "waving_hand"),
    _c(4, "cat_fc_numbers", "Числа и счёт", "Numbers & counting", "Čisla i rěčanje", "Числа и рєчанје", "pin"),
    _c(5, "cat_fc_time", "Время суток и часы", "Time of day & clock", "Čas dnja i časy", "Час дња и часы", "schedule"),
    _c(6, "cat_fc_calendar", "Дни недели и месяцы", "Weekdays & months", "Tydne i měsęcy", "Тидне и мєсяцы", "calendar_month"),
    _c(7, "cat_fc_colors", "Цвета и описание", "Colours & description", "Barvy i opisanje", "Барвы и описање", "palette"),
    _c(8, "cat_fc_family", "Семья и люди", "Family & people", "Semja i ljudije", "Семја и лјудије", "family_restroom"),
    _c(9, "cat_fc_home", "Дом и быт", "Home & daily life", "Dom i byt", "Дом и быт", "home"),
    _c(10, "cat_fc_food", "Еда и стол", "Food & table", "Jedlo i stol", "Једло и стол", "restaurant"),
    _c(11, "cat_fc_restaurant", "В кафе и ресторане", "At café & restaurant", "V kafe i restoraně", "В кафе и ресторанє", "local_cafe"),
    _c(12, "cat_fc_travel", "Путешествия и транспорт", "Travel & transport", "Putovanje i transport", "Путовање и транспорт", "flight"),
    _c(13, "cat_fc_directions", "Пути и ориентиры", "Directions & landmarks", "Puti i orientiry", "Пути и ориентиры", "navigation"),
    _c(14, "cat_fc_accommodation", "Отель и ночлег", "Lodging & hotel", "Hotel i nočlěg", "Хотел и ночлєг", "hotel"),
    _c(15, "cat_fc_shopping", "Покупки и деньги", "Shopping & money", "Kupovanje i groši", "Куповање и гроши", "shopping_cart"),
    _c(16, "cat_fc_health", "Здоровье и аптека", "Health & pharmacy", "Zdravje i lěkarnja", "Здравје и лєкарња", "local_pharmacy"),
    _c(17, "cat_fc_emergency", "Экстренные ситуации", "Emergency situations", "Nagly slučaje", "Нағыслучаје", "emergency"),
    _c(18, "cat_fc_city", "Город и службы", "City & services", "Grad i služby", "Град и службы", "location_city"),
    _c(19, "cat_fc_work", "Работа и учёба", "Work & study", "Praca i učenje", "Праца и ученје", "work"),
    _c(20, "cat_fc_hobbies", "Свободное время", "Free time & hobbies", "Svobodno vrěme", "Свободно врєме", "sports_esports"),
    _c(21, "cat_fc_nature", "Природа и погода", "Nature & weather", "Priroda i pogoda", "Природа и погода", "park"),
    _c(22, "cat_fc_verbs", "Глаголы: настоящее время", "Verbs: present tense", "Glagoly: nynešnje vrěme", "Глаголы: нынєшнје врєме", "menu_book"),
    _c(23, "cat_fc_verbs_motion", "Глаголы движения", "Verbs of motion", "Glagoly dvženja", "Глаголы двженја", "directions_run"),
    _c(24, "cat_fc_aspect", "Вид глагола (сов./несов.)", "Verb aspect", "Vid glagola", "Вид глагола", "swap_horiz"),
    _c(25, "cat_fc_cases", "Падежи: именитель и винительный", "Cases: nominative & accusative", "Padeži: nominativ i akuzativ", "Падєжи: номинатив и акузатив", "menu_book"),
    _c(26, "cat_fc_cases_gen_dat", "Родительный и дательный", "Genitive & dative", "Genitiv i dativ", "Генитив и датив", "menu_book"),
    _c(27, "cat_fc_cases_ins_prep", "Творительный и предложный", "Instrumental & prepositional", "Instrumental i lokativ", "Инструментал и локатив", "menu_book"),
    _c(28, "cat_fc_prep", "Предлоги и место", "Prepositions & place", "Predlogy i město", "Предлогы и мєсто", "pin"),
    _c(29, "cat_fc_adjectives", "Прилагательные и степени", "Adjectives & comparison", "Prilagateljniki i stupenji", "Прилагатељники и ступени", "format_color_fill"),
    _c(30, "cat_fc_pronouns", "Местоимения и указание", "Pronouns & pointing", "Zaimenniki i ukazanje", "Заименники и указање", "touch_app"),
    _c(31, "cat_fc_questions", "Вопросы и ответы", "Questions & answers", "Voprosy i odgovory", "Вопросы и одговоры", "help_outline"),
    _c(32, "cat_fc_past", "Прошедшее время", "Past tense", "Prošlo vrěme", "Прошло врєме", "history"),
    _c(33, "cat_fc_future", "Будущее и намерение", "Future & intention", "Buduće i naměrjenje", "Будуче и намєрјење", "update"),
    _c(34, "cat_fc_imperative", "Повелительное наклонение", "Imperative mood", "Imperativ", "Императив", "campaign"),
    _c(35, "cat_fc_complex_sentence", "Сложное предложение", "Complex sentences", "Složenne predloženje", "Сложенне предложенје", "account_tree"),
    _c(36, "cat_fc_word_order", "Порядок слов и акцент", "Word order & focus", "Porědok slov i akcent", "Порєдок слов и акцент", "format_align_center"),
    _c(37, "cat_fc_style", "Стиль и нюансы", "Style & nuance", "Stil i njuansy", "Стиль и нюансы", "palette"),
    _c(38, "cat_fc_border_talk", "На границе и в дороге", "At the border & on the road", "Na granici i na drodze", "На граници и на дродзе", "badge"),
    _c(39, "cat_fc_slavic_bridges", "Понимание соседних славянских", "Understanding neighbouring Slavic langs", "Razumlěvanje sosednih jezikov", "Разумлєвање сосєдних језиков", "device_hub"),
    _c(40, "cat_fc_community", "Сообщество и мероприятия", "Community & events", "Obščina i dogodky", "Община и догодкы", "groups"),
    _c(41, "cat_fc_online", "Онлайн: чаты, форумы, вики", "Online: chats, forums, wiki", "Onlajn: čaty, forumy, wiki", "Онлајн: чаты, форумы, вики", "forum"),
    _c(42, "cat_fc_native", "Уровень рядом с носителем", "Near-native finesse", "Ravjen okolo nositelja", "Равень около носитеља", "school"),
]


def merge_with_full_syllabus(built_categories: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Объединяет категории из генератора уроков с полным учебным планом."""
    by_id = {c["id"]: c for c in built_categories}
    out: list[dict[str, Any]] = []
    syllabus_ids = {row["id"] for row in FULL_SYLLABUS}
    for row in FULL_SYLLABUS:
        cid = row["id"]
        merged = dict(row)
        if cid in by_id:
            merged.update(by_id[cid])
            merged["order"] = row["order"]
        out.append(merged)
    for c in built_categories:
        if c["id"] not in syllabus_ids:
            out.append(c)
    out.sort(key=lambda x: x.get("order", 999))
    return out
