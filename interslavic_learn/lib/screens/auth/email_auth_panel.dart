import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../errors/app_error_codes.dart';
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
    this.initialRegister = false,
  });

  final VoidCallback onSuccess;
  final VoidCallback? onCancel;
  final bool showCancel;

  /// На Welcome завершаем онбординг; из профиля при привязке email — нет.
  final bool completeOnboarding;

  /// С экрана приветствия: `true` — сначала форма регистрации, `false` — вход.
  final bool initialRegister;

  @override
  ConsumerState<EmailAuthPanel> createState() => _EmailAuthPanelState();
}

class _EmailAuthPanelState extends ConsumerState<EmailAuthPanel> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  late bool _register;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _register = widget.initialRegister;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showError(
    BuildContext context, {
    required bool isRu,
    required int code,
    required String headlineRu,
    required String headlineEn,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          formatUserError(
            isRu: isRu,
            code: code,
            headlineRu: headlineRu,
            headlineEn: headlineEn,
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final locale = ref.read(localeProvider);
    final isRu = locale == 'ru';
    final client = supabaseOrNull;

    if (client == null) {
      if (!mounted) return;
      _showError(
        context,
        isRu: isRu,
        code: AppErrorCodes.authSupabaseNotConfigured,
        headlineRu: 'Supabase не подключён в этой сборке.',
        headlineEn: 'Supabase is not configured in this build.',
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final email = _email.text.trim();
      final password = _password.text;
      if (email.isEmpty || password.length < 6) {
        if (!mounted) return;
        _showError(
          context,
          isRu: isRu,
          code: AppErrorCodes.authInvalidEmailOrPassword,
          headlineRu: 'Введите email и пароль не короче 6 символов.',
          headlineEn: 'Enter email and password (min 6 characters).',
        );
        return;
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
          return;
        }
      } else {
        await client.auth.signInWithPassword(email: email, password: password);
      }

      await ref.read(preferencesServiceProvider).setSessionModeRaw('cloud');
      ref.read(sessionModeProvider.notifier).state = SessionMode.cloud;

      final sync = SyncService(ref.read(progressServiceProvider));
      try {
        await sync.mergeOnLogin();
      } catch (_) {
        if (!mounted) return;
        _showError(
          context,
          isRu: isRu,
          code: AppErrorCodes.syncAfterLoginFailed,
          headlineRu: 'Не удалось синхронизировать прогресс с облаком.',
          headlineEn: 'Could not sync progress with the cloud.',
        );
      }

      ref.read(userProgressProvider.notifier).refresh();

      if (widget.completeOnboarding) {
        await ref.read(preferencesServiceProvider).setOnboardingComplete(true);
        ref.read(onboardingCompleteProvider.notifier).state = true;
      }

      widget.onSuccess();
    } on AuthException catch (e) {
      if (!mounted) return;
      final m = mapAuthException(e, isRegister: _register);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatUserError(
              isRu: isRu,
              code: m.$1,
              headlineRu: m.$2,
              headlineEn: m.$3,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final m = mapAuthFlowThrowable(e, isRegister: _register);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatUserError(
              isRu: isRu,
              code: m.$1,
              headlineRu: m.$2,
              headlineEn: m.$3,
            ),
          ),
        ),
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
          onTapOutside: (_) {},
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
          onTapOutside: (_) {},
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
