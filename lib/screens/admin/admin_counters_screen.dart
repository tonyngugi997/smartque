import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AdminCountersScreen extends StatefulWidget {
  const AdminCountersScreen({Key? key}) : super(key: key);

  @override
  State<AdminCountersScreen> createState() => _AdminCountersScreenState();
}

class _AdminCountersScreenState extends State<AdminCountersScreen> {
  List counters = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final token = await AuthService().getToken();
    if (token == null) return setState(() => loading = false);
    final res = await ApiService.getAdminCounters(token);
    if (res['success'] == true) counters = res['counters'] ?? [];
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counters')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: counters.length,
                itemBuilder: (ctx, i) {
                  final c = counters[i];
                  return ListTile(
                    title: Text(c['name'] ?? ''),
                    subtitle: Text('Dept: ${c['departmentId'] ?? '-'} • Active: ${c['isActive'] == 1 || c['isActive'] == true ? 'Yes' : 'No'}'),
                  );
                },
              ),
      ),
    );
  }
}
