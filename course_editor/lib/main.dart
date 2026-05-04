import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const anon = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  if (url.isEmpty || anon.isEmpty) {
    runApp(const MissingConfigApp());
    return;
  }
  await Supabase.initialize(url: url, anonKey: anon);
  runApp(const CourseEditorApp());
}

class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.settings, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Задайте SUPABASE_URL и SUPABASE_ANON_KEY',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Запуск из корня:\n'
                    'cd course_editor\n'
                    'flutter run -d chrome '
                    '--dart-define=SUPABASE_URL=... '
                    '--dart-define=SUPABASE_ANON_KEY=...\n\n'
                    'См. dart_defines.example.json',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
