import 'package:flutter/material.dart';

import '../../theme/tokens/semantic.dart';

class CcLoadingIndicator extends StatelessWidget {
  const CcLoadingIndicator({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2.5,
          color: SemanticColors.interactivePrimary,
        ),
      ),
    );
  }
}
