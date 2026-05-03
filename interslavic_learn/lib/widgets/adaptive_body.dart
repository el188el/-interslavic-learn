import 'package:flutter/material.dart';

import '../layout/app_breakpoints.dart';

/// Центрирует контент и ограничивает ширину на больших экранах (монитор, широкое окно веба).
class AdaptiveBody extends StatelessWidget {
  const AdaptiveBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: AppBreakpoints.bodyWidth(w),
        child: child,
      ),
    );
  }
}
