import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/feedback_service.dart';
import '../services/supabase_service.dart';

Future<void> showAppFeedbackSheet(
  BuildContext context,
  WidgetRef ref, {
  required FeedbackScreenKind screen,
  String? lessonId,
  String? categoryId,
}) async {
  if (!isSupabaseConfigured) {
    final locale = ref.read(localeProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            locale == 'ru'
                ? 'Облако не настроено — сообщение отправить нельзя.'
                : 'Cloud is not configured — cannot send feedback.',
          ),
        ),
      );
    }
    return;
  }

  final locale = ref.read(localeProvider);
  final ru = locale == 'ru';
  final progress = ref.read(userProgressProvider);
  final session = ref.read(sessionModeProvider);
  final isGuest = session == SessionMode.guest;

  final messageCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var sending = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 8,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setModal) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;
              setModal(() => sending = true);
              try {
                final ver = await FeedbackService.appVersionString();
                final uid = supabaseOrNull?.auth.currentUser?.id;
                if (isGuest) {
                  await FeedbackService.submit(
                    FeedbackPayload(
                      screen: screen,
                      message: messageCtrl.text,
                      displayName: progress.displayName,
                      lessonId: lessonId,
                      categoryId: categoryId,
                      guestEmail: emailCtrl.text.trim(),
                      appVersion: ver,
                    ),
                  );
                } else {
                  await FeedbackService.submit(
                    FeedbackPayload(
                      screen: screen,
                      message: messageCtrl.text,
                      displayName: progress.displayName,
                      lessonId: lessonId,
                      categoryId: categoryId,
                      userId: uid,
                      appVersion: ver,
                    ),
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ru ? 'Спасибо! Мы прочитаем сообщение.' : 'Thanks! We will read your message.',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ru ? 'Не удалось отправить: $e' : 'Could not send: $e',
                      ),
                    ),
                  );
                }
              } finally {
                if (ctx.mounted) setModal(() => sending = false);
              }
            }

            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ru ? 'Обратная связь' : 'Feedback',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ru
                          ? 'Опишите ошибку в тексте урока или своё предложение. Для гостя укажите email — чтобы мы могли ответить.'
                          : 'Describe a mistake in the lesson text or your idea. As a guest, add your email so we can reply.',
                      style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (isGuest) ...[
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          labelText: ru ? 'Ваш email' : 'Your email',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.length < 5 || !t.contains('@')) {
                            return ru
                                ? 'Нужен корректный email'
                                : 'Valid email required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: messageCtrl,
                      minLines: 4,
                      maxLines: 10,
                      decoration: InputDecoration(
                        labelText: ru ? 'Сообщение' : 'Message',
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.length < 8) {
                          return ru
                              ? 'Минимум 8 символов'
                              : 'At least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: sending ? null : submit,
                      child: sending
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(ru ? 'Отправить' : 'Send'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );

  messageCtrl.dispose();
  emailCtrl.dispose();
}
