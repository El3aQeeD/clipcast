import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/tokens/semantic.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SemanticColors.backgroundSecondary,
      body: Center(
        child: Image.asset(
          'assets/images/splash_logo.png',
          width: 230,
        ),
      ),
    );
  }
}
