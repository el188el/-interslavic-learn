import 'package:flutter/material.dart';

import 'settings_launch.dart';

class SettingsResourceItem {
  const SettingsResourceItem({
    required this.url,
    required this.titleRu,
    required this.titleEn,
    required this.subtitleRu,
    required this.subtitleEn,
  });

  final String url;
  final String titleRu;
  final String titleEn;
  final String subtitleRu;
  final String subtitleEn;
}

const List<SettingsResourceItem> kSettingsResourceItems = [
  SettingsResourceItem(
    url: 'https://interslavic.fun',
    titleRu: 'Interslavic.fun',
    titleEn: 'Interslavic.fun',
    subtitleRu: 'Сайт и учебные материалы',
    subtitleEn: 'Site and learning materials',
  ),
  SettingsResourceItem(
    url: 'https://interslavic-dictionary.com',
    titleRu: 'Словарь (онлайн)',
    titleEn: 'Online dictionary',
    subtitleRu: 'interslavic-dictionary.com',
    subtitleEn: 'interslavic-dictionary.com',
  ),
  SettingsResourceItem(
    url: 'https://isv.miraheze.org',
    titleRu: 'Вики',
    titleEn: 'Wiki',
    subtitleRu: 'Справочник на Miraheze',
    subtitleEn: 'Miraheze wiki',
  ),
  SettingsResourceItem(
    url: 'https://steen.free.fr/interslavic',
    titleRu: 'Курс Jan van Steenbergen',
    titleEn: "Jan van Steenbergen's course",
    subtitleRu: 'steen.free.fr/interslavic',
    subtitleEn: 'steen.free.fr/interslavic',
  ),
  SettingsResourceItem(
    url: 'https://github.com/medzuslovjansky',
    titleRu: 'Проект Medžuslovjansky (GitHub)',
    titleEn: 'Medžuslovjansky project (GitHub)',
    subtitleRu: 'Грамматика, словари, инструменты',
    subtitleEn: 'Grammar, lexicons, tooling',
  ),
  SettingsResourceItem(
    url: 'https://github.com/sonic16x/interslavic',
    titleRu: 'Словарь Sonic16x (GitHub)',
    titleEn: 'Sonic16x interslavic (GitHub)',
    subtitleRu: 'Исходный код веб-словаря',
    subtitleEn: 'Web dictionary source',
  ),
  SettingsResourceItem(
    url: 'https://interslavic-language.org',
    titleRu: 'Межславянский язык',
    titleEn: 'Interslavic language',
    subtitleRu: 'interslavic-language.org',
    subtitleEn: 'interslavic-language.org',
  ),
  SettingsResourceItem(
    url: 'http://tyflonet.com/siciliano/klaviatury',
    titleRu: 'Раскладки клавиатуры (Tyflonet)',
    titleEn: 'Keyboard layouts (Tyflonet)',
    subtitleRu: 'Специальные MSKLC / раскладки для славянских языков',
    subtitleEn: 'MSKLC-style layouts for Slavic typing',
  ),
  SettingsResourceItem(
    url: 'http://usachov.eu/g',
    titleRu: 'Клавиатуры и ввод (usachov.eu)',
    titleEn: 'Keyboards & input (usachov.eu)',
    subtitleRu: 'Дополнительные материалы по вводу',
    subtitleEn: 'More typing resources',
  ),
  SettingsResourceItem(
    url: 'https://www.sostav.ru/blogs/288561/82696',
    titleRu: 'Статья о раскладках (Sostav.ru)',
    titleEn: 'Article on keyboard layouts (Sostav.ru)',
    subtitleRu: 'Блог про клавиатуры для славянских языков',
    subtitleEn: 'Blog post about Slavic keyboard layouts',
  ),
];

List<Widget> buildSettingsResourceTiles(BuildContext context, String locale) {
  final isRu = locale == 'ru';
  return kSettingsResourceItems
      .map(
        (e) => ListTile(
          leading: const Icon(Icons.open_in_new),
          title: Text(isRu ? e.titleRu : e.titleEn),
          subtitle: Text(isRu ? e.subtitleRu : e.subtitleEn),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => openSettingsExternalUrl(context, e.url, locale),
        ),
      )
      .toList();
}
