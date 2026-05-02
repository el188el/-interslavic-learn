import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_visual.dart';

/// Основная кнопка действия — градиент и мягкая тень как на концепт‑мокапе.
class GradientCtaButton extends StatelessWidget {
  const GradientCtaButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon = Icons.play_arrow_rounded,
    this.minimumHeight = 54,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final double minimumHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: double.infinity, minHeight: minimumHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppVisual.primaryCtaGradient(context),
        boxShadow: AppVisual.primaryButtonShadow(context),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 26),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      color: Colors.white,
                    ),
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
