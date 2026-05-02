import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_providers.dart';
import '../../services/sync_service.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';

/// Форма входа / регистрации по email (можно встроить в Welcome или открыть с профиля).
class EmailAuthPanel extends ConsumerStatefulWidget {
  const EmailAuthPanel({
    super.key,
    required this.onSuccess,
    this.onCancel,
    this.showCancel = false,
    this.completeOnboarding = true,
  });

  final VoidCallback onSuccess;
  final VoidCallback? onCancel;
  final bool showCancel;

  /// На Welcome завершаем онбординг; из профиля при привязке email — нет.
  final bool completeOnboarding;

  @override
  ConsumerState<EmailAuthPanel> createState() => _EmailAuthPanelState();
}

class _EmailAuthPanelState extends ConsumerState<EmailAuthPanel> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final locale = ref.read(localeProvider);
    final isRu = locale == 'ru';
    final client = supabaseOrNull;

    if (client == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRu
                ? 'Укажите SUPABASE_URL и SUPABASE_ANON_KEY при сборке (dart-define).'
                : 'Set SUPABASE_URL and SUPABASE_ANON_KEY when building (dart-define).',
          ),
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final email = _email.text.trim();
      final password = _password.text;
      if (email.isEmpty || password.length < 6) {
        throw Exception(isRu
            ? 'Введите email и пароль (мин. 6 символов).'
            : 'Enter email and password (min 6 characters).');
      }

      if (_register) {
        final res = await client.auth.signUp(email: email, password: password);
        if (res.session == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRu
                    ? 'Проверьте почту и подтвердите email.'
                    : 'Check your inbox to confirm your email.',
              ),
            ),
          );
          setState(() => _busy = false);
          return;
        }
      } else {
        await client.auth.signInWithPassword(email: email, password: password);
      }

      await ref.read(preferencesServiceProvider).setSessionModeRaw('cloud');
      ref.read(sessionModeProvider.notifier).state = SessionMode.cloud;

      final sync = SyncService(ref.read(progressServiceProvider));
      await sync.mergeOnLogin();
      ref.read(userProgressProvider.notifier).refresh();

      if (widget.completeOnboarding) {
        await ref.read(preferencesServiceProvider).setOnboardingComplete(true);
        ref.read(onboardingCompleteProvider.notifier).state = true;
      }

      widget.onSuccess();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isRu = locale == 'ru';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showCancel && widget.onCancel != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.arrow_back),
              label: Text(isRu ? 'Назад' : 'Back'),
            ),
          ),
        Text(
          _register
              ? (isRu ? 'Создать аккаунт' : 'Create account')
              : (isRu ? 'Вход по email' : 'Sign in with email'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: DuoColors.darkGreen,
              ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(
            labelText: isRu ? 'Пароль' : 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  _register
                      ? (isRu ? 'Зарегистрироваться' : 'Register')
                      : (isRu ? 'Войти' : 'Sign in'),
                ),
        ),
        TextButton(
          onPressed: _busy ? null : () => setState(() => _register = !_register),
          child: Text(
            _register
                ? (isRu ? 'Уже есть аккаунт? Войти' : 'Have an account? Sign in')
                : (isRu ? 'Нет аккаунта? Регистрация' : 'No account? Register'),
          ),
        ),
      ],
    );
  }
}
