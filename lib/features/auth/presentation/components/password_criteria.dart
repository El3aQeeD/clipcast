import 'package:flutter/material.dart';

import '../../../../theme/tokens/components.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';

/// A single check-row for password rules — shown with an
/// animated icon (checkmark when [isMet], circle-dot when not).
class PasswordCriteria extends StatelessWidget {
  const PasswordCriteria({
    super.key,
    required this.label,
    required this.isMet,
    this.isActive = false,
  });

  final String label;
  final bool isMet;

  /// Whether the user has started typing — controls visibility/color.
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    final IconData icon;

    if (!isActive) {
      iconColor = ComponentColors.criteriaInactiveIcon;
      icon = Icons.circle_outlined;
    } else if (isMet) {
      iconColor = ComponentColors.criteriaMetIcon;
      icon = Icons.check_circle;
    } else {
      iconColor = ComponentColors.criteriaUnmetIcon;
      icon = Icons.cancel;
    }

    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            icon,
            key: ValueKey('$isMet-$isActive'),
            size: 18,
            color: iconColor,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: ComponentColors.criteriaMetText,
          ),
        ),
      ],
    );
  }
}
