import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/core/presentation/hikou_theme.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class LectureProgress extends StatelessWidget {
  const LectureProgress(
    this.progress,
    this.total, {
    super.key,
  });

  final int progress;
  final int total;

  @override
  Widget build(BuildContext context) {
    final linearPercentIndicatorExt =
        context.themeExtension<LinearPercentIndicatorColors>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
      child: LinearPercentIndicator(
        key: K.progressIndicator,
        animation: true,
        animateFromLastPercent: true,
        lineHeight: 20,
        animationDuration: 1250,
        percent: (progress + 1) / total,
        center: Text(
          key: K.progressIndicatorLabel,
          '${progress + 1} / $total',
          style: context.textTheme.labelLarge?.copyWith(
            color: linearPercentIndicatorExt.progressLabelTextColor,
          ),
        ),
        progressColor: linearPercentIndicatorExt.progressColor,
        backgroundColor: linearPercentIndicatorExt.backgroundColor,
        barRadius: const Radius.circular(4),
      ),
    );
  }
}
