import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the singleton Supabase client.
/// Initialise in main() via [initSupabase].
class SupabaseClientProvider {
  SupabaseClientProvider._();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}
