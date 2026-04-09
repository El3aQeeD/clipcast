import 'package:flutter/material.dart';

import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/typography.dart';
import 'auth_icons.dart';

/// Reusable header for sign-up pages — back button + centered ClipCast logo,
/// with optional title text below the logo row.
class SignUpHeader extends StatelessWidget {
  const SignUpHeader({
    super.key,
    required this.onBack,
    this.title,
  });

  final VoidCallback onBack;

  /// If provided, rendered as a centered title (e.g. "Sign Up").
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: onBack,
            child: const SizedBox(
              width: 42,
              height: 39,
              child: Center(
                child: Icon(
                  AuthIcons.backIcon,
                  size: 18,
                  color: SemanticColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        if (title != null)
          Text(
            title!,
            style: AppTypography.bodyMedium.copyWith(
              color: SemanticColors.textPrimary,
              letterSpacing: -0.5,
            ),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.asset(
                  'assets/images/clipcast_icon.png',
                  width: 35,
                  height: 34,
                ),
              ),
              Image.asset(
                'assets/images/clipcast_text.png',
                width: 69,
                height: 20,
                errorBuilder: (_, _, _) => Text(
                  'ClipCast',
                  style: AppTypography.titleLarge.copyWith(
                    color: SemanticColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
