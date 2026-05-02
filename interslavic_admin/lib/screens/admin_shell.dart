import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'categories_page.dart';
import 'users_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Курсы · админка'),
        actions: [
          IconButton(
            tooltip: 'Выйти',
            onPressed: () => Supabase.instance.client.auth.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Пользователи'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: Text('Курсы'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _index == 0 ? const UsersPage() : const CategoriesPage(),
          ),
        ],
      ),
    );
  }
}
