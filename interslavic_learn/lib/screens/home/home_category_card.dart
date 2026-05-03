import 'package:flutter/material.dart';

import '../../layout/app_breakpoints.dart';
import '../../models/category.dart';
import '../../services/data_service.dart';
import '../../theme/app_visual.dart';
import '../../widgets/animated_bounce.dart';
import 'category_material_icon_map.dart';
import '../category_lessons_screen.dart';

class HomeCategoryCard extends StatelessWidget {
  const HomeCategoryCard({
    super.key,
    required this.category,
    required this.locale,
    required this.layoutWidth,
    required this.dataService,
    required this.completedLessons,
  });

  final Category category;
  final String locale;
  final double layoutWidth;
  final DataService dataService;
  final List<String> completedLessons;

  @override
  Widget build(BuildContext context) {
    final lessons = dataService.lessonsForCategory(category.id);
    final completed =
        lessons.where((l) => completedLessons.contains(l.id)).length;
    final total = lessons.length;
    final progress = total > 0 ? completed / total : 0.0;
    final hasLessons = total > 0;

    final iconData = categoryMaterialIcon(category.icon);

    const radius = 22.0;
    final narrowPhone = layoutWidth < AppBreakpoints.compact;
    final baseIconSz = AppBreakpoints.categoryIconSize(layoutWidth);
    final iconDisplaySize =
        (baseIconSz * (narrowPhone ? 0.84 : 0.90)).clamp(26.0, 34.0);
    final titleSize = layoutWidth >= AppBreakpoints.medium
        ? 13.0
        : (narrowPhone ? 12.5 : 14.0);
    final cardPadH = layoutWidth >= AppBreakpoints.medium ? 15.0 : 16.0;
    final cardPadV = layoutWidth >= AppBreakpoints.medium ? 10.0 : 11.0;

    final shadows = Theme.of(context).brightness == Brightness.dark
        ? AppVisual.cardShadowDark(context)
        : AppVisual.cardShadowLight(context);

    final cs = Theme.of(context).colorScheme;

    if (!hasLessons) {
      return SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: shadows,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      border: Border.all(
                        color: cs.outline.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.52
                            : 0.38,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    cardPadH,
                    cardPadV,
                    cardPadH + 78,
                    cardPadV,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        iconData,
                        size: iconDisplaySize,
                        color: cs.onSurface.withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.title(locale),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              locale:
                                  Locale(locale == 'ru' ? 'ru' : 'en'),
                              strutStyle: StrutStyle(
                                fontSize: titleSize,
                                height: 1.3,
                                forceStrutHeight: true,
                                leadingDistribution:
                                    TextLeadingDistribution.even,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: titleSize,
                                    height: 1.3,
                                    color: cs.onSurface
                                        .withValues(alpha: 0.68),
                                  ),
                            ),
                            if (category.titleIsvLat.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                category.titleIsvLat,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                locale:
                                    Locale(locale == 'ru' ? 'ru' : 'en'),
                                strutStyle: StrutStyle(
                                  fontSize: 12,
                                  height: 1.28,
                                  forceStrutHeight: true,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      height: 1.28,
                                      color: cs.onSurfaceVariant
                                          .withValues(alpha: 0.55),
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: cs.outline.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        locale == 'ru' ? 'Скоро' : 'Soon',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.15,
                              color: cs.onPrimaryContainer,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final cardFace = SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: shadows,
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: cardPadH,
              vertical: cardPadV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      iconData,
                      size: iconDisplaySize,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.title(locale),
                            textAlign: TextAlign.start,
                            locale:
                                Locale(locale == 'ru' ? 'ru' : 'en'),
                            strutStyle: StrutStyle(
                              fontSize: titleSize,
                              height: 1.28,
                              forceStrutHeight: true,
                              leadingDistribution:
                                  TextLeadingDistribution.even,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: titleSize,
                              height: 1.28,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (category.titleIsvLat.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              category.titleIsvLat,
                              textAlign: TextAlign.start,
                              locale:
                                  Locale(locale == 'ru' ? 'ru' : 'en'),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              strutStyle: StrutStyle(
                                fontSize: 12,
                                height: 1.25,
                                forceStrutHeight: true,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    height: 1.25,
                                    color: cs.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (total > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 5,
                            width: double.infinity,
                            child: LinearProgressIndicator(
                              value: progress,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '$completed / $total',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    final clippedActive = SizedBox.expand(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: cardFace,
      ),
    );

    return AnimatedBounce(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryLessonsScreen(category: category),
          ),
        );
      },
      child: clippedActive,
    );
  }
}
