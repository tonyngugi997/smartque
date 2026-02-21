import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({Key? key}) : super(key: key);

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  List services = [];
  bool loading = true;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final token = await AuthService().getToken();
    if (token == null) return setState(() => loading = false);
    final response = await ApiService.getAdminServices(token);
    if (response['success'] == true) {
      services = response['services'] ?? [];
    }
    setState(() => loading = false);
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (name.isEmpty) return;
    final token = await AuthService().getToken();
    if (token == null) return;
    final res = await ApiService.createAdminService(name, desc, token);
    if (res['success'] == true) {
      _nameCtrl.clear();
      _descCtrl.clear();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Service name')),
                    const SizedBox(height: 8),
                    TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _create, child: const Text('Create Service')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (ctx, i) {
                        final s = services[i];
                        return ListTile(
                          title: Text(s['name'] ?? ''),
                          subtitle: Text(s['description'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final token = await AuthService().getToken();
                              if (token == null) return;
                              final res = await ApiService.deleteAdminService(s['id'].toString(), token);
                              if (res['success'] == true) _load();
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
