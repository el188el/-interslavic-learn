import 'supabase_service.dart';

/// Счётчик `course_catalog_meta.revision` (увеличивается триггерами при правках курсов).
Future<int?> fetchCourseCatalogRevision() async {
  final c = supabaseOrNull;
  if (c == null) return null;
  try {
    final row = await c
        .from('course_catalog_meta')
        .select('revision')
        .eq('id', 1)
        .maybeSingle();
    final n = row?['revision'];
    if (n is int) return n;
    if (n is num) return n.toInt();
    return null;
  } catch (_) {
    return null;
  }
}
