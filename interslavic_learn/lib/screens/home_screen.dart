import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/data_service.dart';
import '../models/category.dart';
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

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _CoursesTab(locale: locale),
          const LeaderboardScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
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
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataService = ref.watch(dataServiceProvider);
    final progress = ref.watch(userProgressProvider);
    final categories = dataService.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale == 'ru' ? 'Меджусловјанскы' : 'Medžuslovjansky',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
      body: categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return _CategoryCard(
                  category: cat,
                  locale: locale,
                  dataService: dataService,
                  completedLessons: progress.completedLessons,
                );
              },
            ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final String locale;
  final DataService dataService;
  final List<String> completedLessons;

  const _CategoryCard({
    required this.category,
    required this.locale,
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

    final iconData =
        _CoursesTab._iconMap[category.icon] ?? Icons.book;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryLessonsScreen(category: category),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, size: 36, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                category.title(locale),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (total > 0)
                LinearProgressIndicator(
                  value: progress,
                  borderRadius: BorderRadius.circular(4),
                ),
              if (total > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '$completed / $total',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _XpBadge extends StatelessWidget {
  final int xp;
  const _XpBadge({required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 18),
          const SizedBox(width: 4),
          Text('$xp', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department,
              color: streak > 0 ? Colors.deepOrange : Colors.grey, size: 18),
          const SizedBox(width: 4),
          Text('$streak', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
