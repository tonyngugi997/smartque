import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => loading = true);
    final token = await AuthService().getToken();
    if (token == null) return setState(() => loading = false);
    final res = await ApiService.getAdminUsers(token);
    setState(() {
      users = res['users'] ?? [];
      loading = false;
    });
  }

  Future<void> _changeRole(int userId, String role) async {
    final token = await AuthService().getToken();
    if (token == null) return;
    final res = await ApiService.updateUserRole(userId: userId.toString(), role: role, token: token);
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role updated')));
      _loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['error'] ?? 'Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final u = users[index];
                  return ListTile(
                    title: Text(u['name'] ?? u['email'] ?? 'Unknown'),
                    subtitle: Text(u['email'] ?? ''),
                    trailing: DropdownButton<String>(
                      value: u['role'] ?? 'user',
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text('User')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'business', child: Text('Business')),
                      ],
                      onChanged: (val) {
                        if (val != null) _changeRole(u['id'], val);
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
