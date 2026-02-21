import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AdminAppointmentsScreen> createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  List appointments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => loading = true);
    final token = await AuthService().getToken();
    if (token == null) return setState(() => loading = false);
    final res = await ApiService.getAdminAppointments(token: token);
    setState(() {
      appointments = res['appointments'] ?? [];
      loading = false;
    });
  }

  Future<void> _updateStatus(int appointmentId, String status) async {
    final token = await AuthService().getToken();
    if (token == null) return;
    final res = await ApiService.updateAppointmentStatus(appointmentId: appointmentId.toString(), status: status, token: token);
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment updated')));
      _loadAppointments();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['error'] ?? 'Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Appointments')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAppointments,
              child: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final a = appointments[index];
                  return ListTile(
                    title: Text('${a['doctorName']} - ${a['departmentName']}'),
                    subtitle: Text('User: ${a['userId']} • ${a['dateTime']}'),
                    trailing: DropdownButton<String>(
                      value: a['status'] ?? 'upcoming',
                      items: const [
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'approved', child: Text('Approved')),
                        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                        DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                        DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
                        DropdownMenuItem(value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (val) {
                        if (val != null) _updateStatus(a['id'], val);
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
