import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'email_auth_panel.dart';

/// Полноэкранная форма для привязки email из профиля.
class EmailAuthScreen extends ConsumerWidget {
  const EmailAuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: EmailAuthPanel(
            completeOnboarding: false,
            onSuccess: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
