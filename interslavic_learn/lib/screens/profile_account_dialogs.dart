import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_error_codes.dart';
import '../providers/app_providers.dart';
import '../services/supabase_service.dart';
import '../services/sync_service.dart';

Future<void> showDisplayNameEditor(BuildContext context, WidgetRef ref) async {
  final locale = ref.read(localeProvider);
  final isRu = locale == 'ru';
  final initial = ref.read(userProgressProvider).displayName;

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => _DisplayNameDialogContent(
      initial: initial,
      isRu: isRu,
      onSave: (name) async {
        await ref.read(userProgressProvider.notifier).setDisplayName(name);
        if (ref.read(sessionModeProvider) == SessionMode.cloud &&
            isSupabaseConfigured) {
          await SyncService(ref.read(progressServiceProvider))
              .pushLocalProgressToCloud();
        }
      },
    ),
  );
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isRu ? 'Имя сохранено' : 'Name saved'),
      ),
    );
  }
}

class _DisplayNameDialogContent extends StatefulWidget {
  const _DisplayNameDialogContent({
    required this.initial,
    required this.isRu,
    required this.onSave,
  });

  final String initial;
  final bool isRu;
  final Future<void> Function(String name) onSave;

  @override
  State<_DisplayNameDialogContent> createState() =>
      _DisplayNameDialogContentState();
}

class _DisplayNameDialogContentState extends State<_DisplayNameDialogContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isRu ? 'Имя в приложении' : 'Display name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 48,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: widget.isRu ? 'Как к вам обращаться' : 'How to address you',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(widget.isRu ? 'Отмена' : 'Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final t = _controller.text.trim();
            if (t.isEmpty) return;
            await widget.onSave(t);
            if (!context.mounted) return;
            Navigator.pop(context, true);
          },
          child: Text(widget.isRu ? 'Сохранить' : 'Save'),
        ),
      ],
    );
  }
}

Future<void> showChangePasswordDialog(BuildContext context, WidgetRef ref) async {
  final locale = ref.read(localeProvider);
  final isRu = locale == 'ru';

  await showDialog<void>(
    context: context,
    builder: (ctx) => _ChangePasswordDialog(isRu: isRu),
  );
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog({required this.isRu});

  final bool isRu;

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final client = supabaseOrNull;
    if (client == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatUserError(
              isRu: widget.isRu,
              code: AppErrorCodes.passwordSupabaseNotConfigured,
              headlineRu: 'Supabase не настроен.',
              headlineEn: 'Supabase is not configured.',
            ),
          ),
        ),
      );
      return;
    }

    final p1 = _new.text;
    final p2 = _confirm.text;
    if (p1.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatUserError(
              isRu: widget.isRu,
              code: AppErrorCodes.passwordTooShort,
              headlineRu: 'Пароль не короче 6 символов.',
              headlineEn: 'Password at least 6 characters.',
            ),
          ),
        ),
      );
      return;
    }
    if (p1 != p2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatUserError(
              isRu: widget.isRu,
              code: AppErrorCodes.passwordMismatch,
              headlineRu: 'Пароли не совпадают.',
              headlineEn: 'Passwords do not match.',
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await client.auth.updateUser(UserAttributes(password: p1));
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isRu ? 'Пароль обновлён' : 'Password updated',
          ),
        ),
      );
    } on AuthException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatUserError(
              isRu: widget.isRu,
              code: AppErrorCodes.passwordUpdateFailed,
              headlineRu: 'Не удалось сменить пароль.',
              headlineEn: 'Could not update password.',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final m = mapPasswordChangeError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatUserError(
              isRu: widget.isRu,
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
    final r = widget.isRu;
    return AlertDialog(
      title: Text(r ? 'Новый пароль' : 'New password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _new,
              obscureText: _obscure1,
              decoration: InputDecoration(
                labelText: r ? 'Новый пароль' : 'New password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure1 ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscure1 = !_obscure1),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirm,
              obscureText: _obscure2,
              decoration: InputDecoration(
                labelText: r ? 'Повторите пароль' : 'Confirm password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure2 ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscure2 = !_obscure2),
                ),
              ),
              onSubmitted: (_) => _busy ? null : _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(r ? 'Отмена' : 'Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(r ? 'Сохранить' : 'Save'),
        ),
      ],
    );
  }
}
