import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  Map<String, dynamic>? report;
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
    final res = await ApiService.getAdminDailyReport(token);
    if (res['success'] == true) report = res['report'];
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Report')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : report == null
                ? const Center(child: Text('No report'))
                : ListView(
                    children: [
                      Card(
                        child: ListTile(
                          title: const Text('Total Appointments'),
                          trailing: Text('${report?['totalAppointments'] ?? '-'}'),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: const Text('Completed'),
                          trailing: Text('${report?['completed'] ?? '-'}'),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: const Text('Cancelled'),
                          trailing: Text('${report?['cancelled'] ?? '-'}'),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
