import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/dashboard_page.dart';
import 'screens/login_page.dart';

class CourseEditorApp extends StatelessWidget {
  const CourseEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interslavic — редактор курса',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B21B6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const _AuthRouter(),
    );
  }
}

class _AuthRouter extends StatelessWidget {
  const _AuthRouter();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? Supabase.instance.client.auth.currentSession;
        if (session != null) {
          return const DashboardPage();
        }
        return const LoginPage();
      },
    );
  }
}
