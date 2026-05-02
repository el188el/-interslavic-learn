import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_shell.dart';
import 'login_page.dart';

/// Ждёт сессию Supabase, проверяет profiles.is_admin.
class AdminGate extends StatefulWidget {
  const AdminGate({super.key});

  @override
  State<AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<AdminGate> {
  bool _loading = true;
  bool? _isAdmin;

  @override
  void initState() {
    super.initState();
    _refresh();
    Supabase.instance.client.auth.onAuthStateChange.listen((_) => _refresh());
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _isAdmin = null;
        });
      }
      return;
    }

    final row = await Supabase.instance.client
        .from('profiles')
        .select('is_admin')
        .eq('id', user.id)
        .maybeSingle();

    if (!mounted) return;
    setState(() {
      _loading = false;
      _isAdmin = row != null && row['is_admin'] == true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const LoginPage();
    }

    if (_isAdmin != true) {
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'У аккаунта нет прав администратора.\n'
                  'Выполните в SQL: UPDATE profiles SET is_admin = true WHERE id = \'…\';',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                  },
                  child: const Text('Выйти'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const AdminShell();
  }
}
