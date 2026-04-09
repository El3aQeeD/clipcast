import 'package:flutter/material.dart';

import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/typography.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SemanticColors.backgroundPrimary,
      body: Center(
        child: Text(
          'Welcome to ClipCast!',
          style: AppTypography.displayMedium.copyWith(
            color: SemanticColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
