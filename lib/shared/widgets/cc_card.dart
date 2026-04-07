import 'package:flutter/material.dart';

import '../../theme/tokens/components.dart';
import '../../theme/tokens/spacing.dart';

class CcCard extends StatelessWidget {
  const CcCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: ComponentColors.feedCardBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: ComponentColors.feedCardBorder),
      ),
      child: child,
    );
  }
}
