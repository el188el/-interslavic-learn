import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../layout/app_breakpoints.dart';
import '../../providers/app_providers.dart';
import '../../widgets/ad_banner_slot.dart';
import '../../widgets/app_chrome_background.dart';
import '../leaderboard_screen.dart';
import '../profile_screen.dart';
import 'home_courses_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  int _navBarSelectedIndex(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 0;
      case 1:
        return 2;
      case 2:
        return 3;
      default:
        return 0;
    }
  }

  void _onDestinationSelected(BuildContext context, String locale, int navIndex) {
    if (navIndex == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            locale == 'ru' ? 'Карточки скоро появятся.' : 'Flashcards coming soon.',
          ),
        ),
      );
      return;
    }
    setState(() {
      if (navIndex == 0) {
        _currentIndex = 0;
      } else if (navIndex == 2) {
        _currentIndex = 1;
      } else if (navIndex == 3) {
        _currentIndex = 2;
      }
    });
  }

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
              HomeCoursesTab(locale: locale),
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
                selectedIndex: _navBarSelectedIndex(_currentIndex),
                onDestinationSelected: (i) =>
                    _onDestinationSelected(context, locale, i),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.school),
                    label: locale == 'ru' ? 'Курсы' : 'Courses',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.style_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.45),
                    ),
                    label: locale == 'ru' ? 'Карточки' : 'Cards',
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
