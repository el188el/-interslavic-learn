import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase URL and anon key via `--dart-define=SUPABASE_URL=...` and `SUPABASE_ANON_KEY=...`.
bool get isSupabaseConfigured {
  const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  return url.isNotEmpty;
}

Future<void> initSupabaseIfConfigured() async {
  const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  if (url.isEmpty || anonKey.isEmpty) return;
  await Supabase.initialize(url: url, anonKey: anonKey);
}

SupabaseClient? get supabaseOrNull {
  if (!isSupabaseConfigured) return null;
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}
