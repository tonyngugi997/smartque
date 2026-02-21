import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:advanced_login_app/providers/auth_provider.dart';
import 'package:advanced_login_app/providers/appointment_provider.dart';
import 'package:advanced_login_app/screens/settings_screen.dart';
import 'package:advanced_login_app/screens/edit_profile_screen.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  String _initials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.split(' ');
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final user = auth.user ?? {};

    final name = user['name'] ?? user['fullName'] ?? 'User';
    final email = user['email'] ?? '';
    final phone = user['phone'] ?? 'Not provided';
    final dob = user['dob'] ?? '—';
    final gender = user['gender'] ?? '—';
    final insurance = user['insurance'] ?? 'Not set';

    final total = appointmentProvider.userAppointments.length;
    final upcoming = appointmentProvider.userAppointments
        .where((a) => a.status == 'upcoming')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                        ),
                      ],
                      image: user['avatar'] != null
                          ? DecorationImage(
                              image: FileImage(
                                File(user['avatar'] as String),
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: user['avatar'] == null
                        ? Center(
                            child: Text(
                              _initials(name as String?),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 18),
                  // Name and actions
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          email as String,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white24),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                                );
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Edit Profile'),
                            ),
                            const SizedBox(width: 8),
                            // Styled logout button with confirmation
                            SizedBox(
                              height: 40,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Confirm Logout'),
                                      content: const Text('Are you sure you want to logout?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Logout')),
                                      ],
                                    ),
                                  );

                                  if (confirm != true) return;

                                  // show loading dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (ctx) => const Center(child: CircularProgressIndicator()),
                                  );

                                  try {
                                    await Provider.of<AuthProvider>(context, listen: false).logout();
                                    await AuthService().logout();
                                  } catch (e) {
                                    // ignore errors but print
                                    print('Logout error: $e');
                                  } finally {
                                    // close loading
                                    Navigator.of(context, rootNavigator: true).pop();
                                  }

                                  Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                                },
                                icon: const Icon(Icons.logout, color: Colors.white),
                                label: const Text('Logout', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Quick stats
            Row(
              children: [
                _statCard('Appointments', total.toString(), Icons.calendar_today, Colors.deepPurple),
                const SizedBox(width: 12),
                _statCard('Upcoming', upcoming.toString(), Icons.schedule, Colors.teal),
              ],
            ),

            const SizedBox(height: 18),

            // Profile details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _detailRow(Icons.person_outline, 'Full name', name as String),
                  const SizedBox(height: 8),
                  _detailRow(Icons.email_outlined, 'Email', email as String),
                  const SizedBox(height: 8),
                  _detailRow(Icons.phone_outlined, 'Phone', phone as String),
                  const SizedBox(height: 8),
                  _detailRow(Icons.cake_outlined, 'Date of birth', dob as String),
                  const SizedBox(height: 8),
                  _detailRow(Icons.wc, 'Gender', gender as String),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Insurance & Emergency
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Insurance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(insurance as String, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA6)),
                          onPressed: () {},
                          child: const Text('Manage'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Emergency', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('No emergency contact set', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
                          onPressed: () {},
                          child: const Text('Add Contact'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Recent appointments (preview)
            const Text('Recent Appointments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...appointmentProvider.userAppointments.take(3).map((apt) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.medical_services_outlined, color: Colors.white70),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(apt.doctorName, style: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('${apt.departmentName} • ${apt.dateTime}', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text('#${apt.queueNumber}', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}
