import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_providers.dart';
import '../../services/guest_session.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_visual.dart';
import '../../widgets/app_chrome_background.dart';
import '../../widgets/animated_bounce.dart';
import '../../widgets/learning_orb.dart';
import 'email_auth_panel.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _emailMode = false;
  bool _emailInitialRegister = true;

  void _openEmailMode({required bool register}) {
    setState(() {
      _emailMode = true;
      _emailInitialRegister = register;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isRu = locale == 'ru';

    if (_emailMode) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: AppChromeBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                    child: Center(
                      child: EmailAuthPanel(
                        key: ValueKey(_emailInitialRegister),
                        showCancel: true,
                        initialRegister: _emailInitialRegister,
                        onCancel: () => setState(() => _emailMode = false),
                        onSuccess: () {},
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppChromeBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LearningOrb(size: 100),
                      const SizedBox(height: 24),
                      Text(
                        isRu ? 'Меджусловјанскы' : 'Medžuslovjansky',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.1,
                          height: 1.1,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isRu
                            ? 'Учите язык, понятный славянам'
                            : 'Learn the language Slavs understand',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                          height: 1.35,
                          color: cs.onSurface.withValues(alpha: 0.78),
                        ),
                      ),
                      const SizedBox(height: 36),
                      AnimatedBounce(
                        onTap: () => _openEmailMode(register: true),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 17),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: DuoColors.primaryGreenDeep,
                            boxShadow: AppVisual.primaryButtonShadow(context),
                          ),
                          child: Text(
                            isRu ? 'Создать аккаунт' : 'Create account',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 0.12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => _openEmailMode(register: false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: BorderSide(
                            color: DuoColors.skyDeep.withValues(alpha: 0.65),
                            width: 2,
                          ),
                          foregroundColor: DuoColors.skyDeep,
                          backgroundColor:
                              cs.surface.withValues(alpha: 0.45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          isRu ? 'Уже есть аккаунт — войти' : 'Have an account — sign in',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextButton(
                        onPressed: () async {
                          final progress = ref.read(progressServiceProvider);
                          await GuestSession.ensure(progress);
                          await ref
                              .read(preferencesServiceProvider)
                              .setSessionModeRaw('guest');
                          ref.read(sessionModeProvider.notifier).state =
                              SessionMode.guest;
                          await ref
                              .read(preferencesServiceProvider)
                              .setOnboardingComplete(true);
                          ref.read(onboardingCompleteProvider.notifier).state =
                              true;
                        },
                        style: TextButton.styleFrom(
                          foregroundColor:
                              cs.onSurface.withValues(alpha: 0.55),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: Text(
                          isRu ? 'Продолжить как гость' : 'Continue as guest',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isRu
                            ? 'Гость: прогресс только на устройстве. После удаления приложения данные исчезнут.'
                            : 'Guest: progress stays on this device only. Uninstall erases data.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          height: 1.45,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
