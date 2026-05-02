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

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isRu = locale == 'ru';

    if (_emailMode) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: AppChromeBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: EmailAuthPanel(
                showCancel: true,
                onCancel: () => setState(() => _emailMode = false),
                onSuccess: () {},
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppChromeBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Center(child: LearningOrb(size: 120)),
                const SizedBox(height: 28),
                Text(
                  isRu ? 'Меджусловјанскы' : 'Medžuslovjansky',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                    height: 1.1,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isRu
                      ? 'Учите язык, понятный славянам'
                      : 'Learn the language Slavs understand',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                    height: 1.35,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBounce(
                  onTap: () async {
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
                    ref.read(onboardingCompleteProvider.notifier).state = true;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: DuoColors.primaryGreenDeep,
                      boxShadow: AppVisual.primaryButtonShadow(context),
                    ),
                    child: Text(
                      isRu ? 'Продолжить как гость' : 'Continue as guest',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () => setState(() => _emailMode = true),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    side: BorderSide(
                      color: DuoColors.skyDeep.withValues(alpha: 0.75),
                      width: 2,
                    ),
                    foregroundColor: DuoColors.skyDeep,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    isRu ? 'Войти по email' : 'Sign in with email',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  isRu
                      ? 'Гость: прогресс только на устройстве. После удаления приложения данные исчезнут.'
                      : 'Guest: progress stays on this device only. Uninstall erases data.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.4,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.58),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
