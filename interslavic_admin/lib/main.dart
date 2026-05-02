import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/admin_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const anonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  if (url.isEmpty || anonKey.isEmpty) {
    runApp(const _MissingConfigApp());
    return;
  }

  await Supabase.initialize(url: url, anonKey: anonKey);
  runApp(const InterslavicAdminApp());
}

class InterslavicAdminApp extends StatelessWidget {
  const InterslavicAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interslavic Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF22C55E)),
        useMaterial3: true,
      ),
      home: const AdminGate(),
    );
  }
}

class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Задайте SUPABASE_URL и SUPABASE_ANON_KEY при сборке:\n'
                'flutter run -d chrome --dart-define-from-file=dart_defines.json',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
