import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../layout/app_breakpoints.dart';
import '../providers/app_providers.dart';
import '../services/data_service.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import '../theme/app_visual.dart';
import '../widgets/adaptive_body.dart';
import '../widgets/app_chrome_background.dart';
import '../widgets/ad_banner_slot.dart';
import '../widgets/animated_bounce.dart';
import '../widgets/interslavic_language_icon.dart';
import 'category_lessons_screen.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final windowW = MediaQuery.sizeOf(context).width;
    final comfortable = windowW >= AppBreakpoints.medium;

    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarTheme.of(context).copyWith(
          height: comfortable ? 64 : 72,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppChromeBackground(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _CoursesTab(locale: locale),
              const LeaderboardScreen(),
              const ProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AdBannerSlot(),
              NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (i) =>
                    setState(() => _currentIndex = i),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.school),
                    label: locale == 'ru' ? 'Курсы' : 'Courses',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.leaderboard),
                    label: locale == 'ru' ? 'Рейтинг' : 'Leaderboard',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person),
                    label: locale == 'ru' ? 'Профиль' : 'Profile',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoursesTab extends ConsumerWidget {
  final String locale;
  const _CoursesTab({required this.locale});

  static const _iconMap = <String, IconData>{
    'school': Icons.school,
    'waving_hand': Icons.waving_hand,
    'restaurant': Icons.restaurant,
    'family_restroom': Icons.family_restroom,
    'pin': Icons.pin,
    'palette': Icons.palette,
    'flight': Icons.flight,
    'menu_book': Icons.menu_book,
    'record_voice_over': Icons.record_voice_over,
    'calendar_month': Icons.calendar_month,
    'schedule': Icons.schedule,
    'home': Icons.home,
    'local_cafe': Icons.local_cafe,
    'navigation': Icons.navigation,
    'hotel': Icons.hotel,
    'shopping_cart': Icons.shopping_cart,
    'local_pharmacy': Icons.local_pharmacy,
    'emergency': Icons.emergency,
    'location_city': Icons.location_city,
    'work': Icons.work,
    'sports_esports': Icons.sports_esports,
    'park': Icons.park,
    'directions_run': Icons.directions_run,
    'swap_horiz': Icons.swap_horiz,
    'format_color_fill': Icons.format_color_fill,
    'touch_app': Icons.touch_app,
    'help_outline': Icons.help_outline,
    'history': Icons.history,
    'update': Icons.update,
    'campaign': Icons.campaign,
    'account_tree': Icons.account_tree,
    'format_align_center': Icons.format_align_center,
    'badge': Icons.badge,
    'device_hub': Icons.device_hub,
    'groups': Icons.groups,
    'forum': Icons.forum,
  };

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
          _XpBadge(xp: progress.totalXp),
          _StreakBadge(streak: progress.currentStreak),
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
                        child: _CategoryCard(
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

class _CategoryCard extends StatelessWidget {
  final Category category;
  final String locale;
  final double layoutWidth;
  final DataService dataService;
  final List<String> completedLessons;

  const _CategoryCard({
    required this.category,
    required this.locale,
    required this.layoutWidth,
    required this.dataService,
    required this.completedLessons,
  });

  @override
  Widget build(BuildContext context) {
    final lessons = dataService.lessonsForCategory(category.id);
    final completed =
        lessons.where((l) => completedLessons.contains(l.id)).length;
    final total = lessons.length;
    final progress = total > 0 ? completed / total : 0.0;
    final hasLessons = total > 0;

    final iconData =
        _CoursesTab._iconMap[category.icon] ?? Icons.book;

    const radius = 22.0;
    final narrowPhone = layoutWidth < AppBreakpoints.compact;
    final baseIconSz = AppBreakpoints.categoryIconSize(layoutWidth);
    final iconDisplaySize =
        (baseIconSz * (narrowPhone ? 0.84 : 0.90)).clamp(26.0, 34.0);
    final titleSize = layoutWidth >= AppBreakpoints.medium
        ? 13.0
        : (narrowPhone ? 12.5 : 14.0);
    final cardPadH = layoutWidth >= AppBreakpoints.medium ? 15.0 : 16.0;
    final cardPadV = layoutWidth >= AppBreakpoints.medium ? 10.0 : 11.0;

    final shadows = Theme.of(context).brightness == Brightness.dark
        ? AppVisual.cardShadowDark(context)
        : AppVisual.cardShadowLight(context);

    final cs = Theme.of(context).colorScheme;

    if (!hasLessons) {
      return SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: shadows,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      border: Border.all(
                        color: cs.outline.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.52
                            : 0.38,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    cardPadH,
                    cardPadV,
                    cardPadH + 78,
                    cardPadV,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        iconData,
                        size: iconDisplaySize,
                        color: cs.onSurface.withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text(
                                category.title(locale),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                locale:
                                    Locale(locale == 'ru' ? 'ru' : 'en'),
                                strutStyle: StrutStyle(
                                  fontSize: titleSize,
                                  height: 1.3,
                                  forceStrutHeight: true,
                                  leadingDistribution:
                                      TextLeadingDistribution.even,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: titleSize,
                                      height: 1.3,
                                      color: cs.onSurface
                                          .withValues(alpha: 0.68),
                                    ),
                              ),
                              if (category.titleIsvLat.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  category.titleIsvLat,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  locale:
                                      Locale(locale == 'ru' ? 'ru' : 'en'),
                                  strutStyle: StrutStyle(
                                    fontSize: 12,
                                    height: 1.28,
                                    forceStrutHeight: true,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        height: 1.28,
                                        color: cs.onSurfaceVariant
                                            .withValues(alpha: 0.55),
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                              ],
                            ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: cs.outline.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        locale == 'ru' ? 'Скоро' : 'Soon',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.15,
                              color: cs.onPrimaryContainer,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final cardFace = SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: shadows,
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: cardPadH,
              vertical: cardPadV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      iconData,
                      size: iconDisplaySize,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.title(locale),
                            textAlign: TextAlign.start,
                            locale:
                                Locale(locale == 'ru' ? 'ru' : 'en'),
                            strutStyle: StrutStyle(
                              fontSize: titleSize,
                              height: 1.28,
                              forceStrutHeight: true,
                              leadingDistribution:
                                  TextLeadingDistribution.even,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: titleSize,
                              height: 1.28,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (category.titleIsvLat.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              category.titleIsvLat,
                              textAlign: TextAlign.start,
                              locale:
                                  Locale(locale == 'ru' ? 'ru' : 'en'),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              strutStyle: StrutStyle(
                                fontSize: 12,
                                height: 1.25,
                                forceStrutHeight: true,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    height: 1.25,
                                    color: cs.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (total > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 5,
                            width: double.infinity,
                            child: LinearProgressIndicator(
                              value: progress,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '$completed / $total',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    final clippedActive = SizedBox.expand(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: cardFace,
      ),
    );

    return AnimatedBounce(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryLessonsScreen(category: category),
          ),
        );
      },
      child: clippedActive,
    );
  }
}

class _XpBadge extends StatelessWidget {
  final int xp;
  const _XpBadge({required this.xp});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.sizeOf(context).width;
    final compact = w >= AppBreakpoints.medium;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: compact ? 3 : 4),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded,
              color: cs.primary, size: compact ? 16 : 18),
          const SizedBox(width: 4),
          Text(
            '$xp',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: cs.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  /// Контраст к лиловому/фиолетовому контейнеру — не использовать `tertiary` (сливается с фоном).
  static const _fireActive = Color(0xFFFF7A45);
  static const _fireMuted = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.sizeOf(context).width;
    final compact = w >= AppBreakpoints.medium;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: compact ? 3 : 4),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: streak > 0 ? _fireActive : _fireMuted,
            size: compact ? 16 : 18,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: cs.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
