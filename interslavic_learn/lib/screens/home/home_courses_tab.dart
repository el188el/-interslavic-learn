import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../layout/app_breakpoints.dart';
import '../../models/category.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/adaptive_body.dart';
import '../../widgets/interslavic_language_icon.dart';
import '../settings_screen.dart';
import 'home_category_card.dart';
import 'home_progress_badges.dart';

/// Вкладка «Курсы»: сетка категорий и баннер гостя.
class HomeCoursesTab extends ConsumerWidget {
  const HomeCoursesTab({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataService = ref.watch(dataServiceProvider);
    final progress = ref.watch(userProgressProvider);
    final categories = dataService.categories;
    final sortedCategories = List<Category>.from(categories)
      ..sort((a, b) {
        final na = dataService.lessonsForCategory(a.id).length;
        final nb = dataService.lessonsForCategory(b.id).length;
        final aEmpty = na == 0;
        final bEmpty = nb == 0;
        if (aEmpty != bEmpty) {
          return aEmpty ? 1 : -1;
        }
        return a.order.compareTo(b.order);
      });
    final guest = ref.watch(sessionModeProvider) == SessionMode.guest;
    final guestBannerDismissed = ref.watch(guestBannerDismissedProvider);
    final windowW = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: windowW >= AppBreakpoints.medium ? 72 : 68,
        title: Row(
          children: [
            const InterslavicLanguageIcon(size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                locale == 'ru' ? 'Меджусловјанскы' : 'Medžuslovjansky',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppBreakpoints.appBarTitleFontSize(windowW),
                ),
              ),
            ),
          ],
        ),
        actions: [
          HomeXpBadge(xp: progress.totalXp),
          HomeStreakBadge(streak: progress.currentStreak),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (guest && !guestBannerDismissed)
            Container(
              padding: const EdgeInsets.only(left: 12, right: 4, top: 12, bottom: 12),
              color: DuoColors.warning.withValues(alpha: 0.22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.warning_amber_rounded, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      locale == 'ru'
                          ? 'Гость: прогресс только на этом устройстве. Удаление приложения сотрёт все данные.'
                          : 'Guest: progress is only on this device. Uninstall removes all data.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    tooltip:
                        locale == 'ru' ? 'Скрыть уведомление' : 'Dismiss',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    onPressed: () async {
                      await ref
                          .read(preferencesServiceProvider)
                          .setGuestBannerDismissed(true);
                      ref.read(guestBannerDismissedProvider.notifier).state =
                          true;
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: sortedCategories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : AdaptiveBody(
                    child: GridView.builder(
                      cacheExtent: 280,
                      padding: AppBreakpoints.contentPadding(windowW),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            AppBreakpoints.categoryGridColumns(windowW),
                        childAspectRatio:
                            AppBreakpoints.categoryGridAspectRatio(windowW),
                        crossAxisSpacing:
                            AppBreakpoints.gridSpacing(windowW),
                        mainAxisSpacing:
                            AppBreakpoints.gridSpacing(windowW),
                      ),
                      itemCount: sortedCategories.length,
                      itemBuilder: (context, index) {
                        final cat = sortedCategories[index];
                        return RepaintBoundary(
                          child: HomeCategoryCard(
                            category: cat,
                            locale: locale,
                            layoutWidth: windowW,
                            dataService: dataService,
                            completedLessons: progress.completedLessons,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
