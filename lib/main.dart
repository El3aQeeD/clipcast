import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  await Supabase.initialize(
    url: 'https://whmdnwsttwnwxuumacwp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndobWRud3N0dHdud3h1dW1hY3dwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5NDgzNTQsImV4cCI6MjA5MDUyNDM1NH0.FnNCbobtVotbMEZApom9wDfYGrGL8DQDvs-z5geHuj4',
  );

  await initDependencies();

  // ── OneSignal ────────────────────────────────────────────────
  OneSignal.initialize('568a30ec-0a69-4a24-9e75-65db60f4ac33');

  runApp(const ClipCastApp());
}
