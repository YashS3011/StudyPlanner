import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://uemuvgmiyithsjkdcgnb.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVlbXV2Z21peWl0aHNqa2RjZ25iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxMzc1MTIsImV4cCI6MjA5MzcxMzUxMn0.2QQqFOjOAT_AisZM_J0F0vqOBM2YekgSFKRTlg0xz2I';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
