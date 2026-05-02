import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Данные из RPC admin_list_users().
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final raw =
        await Supabase.instance.client.rpc('admin_list_users') as List<dynamic>? ??
            [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Пользователи',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Обновить',
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Email виден только здесь (RPC с правами definer). Для доступа к редактированию курсов пользователю нужен profiles.is_admin.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: SelectableText(
                      'Ошибка: ${snap.error}\n\n'
                      'Убедитесь, что выполнена миграция 002_admin_courses.sql и у вас is_admin = true.',
                    ),
                  );
                }
                final rows = snap.data ?? [];
                if (rows.isEmpty) {
                  return const Center(child: Text('Нет записей'));
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Имя')),
                        DataColumn(label: Text('XP'), numeric: true),
                        DataColumn(label: Text('Серия'), numeric: true),
                        DataColumn(label: Text('Админ')),
                        DataColumn(label: Text('Регистрация')),
                      ],
                      rows: rows.map((r) {
                        final ca = r['created_at'];
                        String created = '';
                        if (ca != null) {
                          created = ca.toString();
                          if (created.length > 16) {
                            created = created.substring(0, 16);
                          }
                        }
                        return DataRow(
                          cells: [
                            DataCell(Text('${r['email'] ?? ''}')),
                            DataCell(Text('${r['display_name'] ?? ''}')),
                            DataCell(Text('${r['total_xp'] ?? 0}')),
                            DataCell(Text('${r['current_streak'] ?? 0}')),
                            DataCell(Text(r['is_admin'] == true ? 'да' : '')),
                            DataCell(Text(created)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
