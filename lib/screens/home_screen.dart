import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:advanced_login_app/providers/auth_provider.dart';
import 'package:advanced_login_app/providers/appointment_provider.dart';
import 'package:advanced_login_app/widgets/advanced_sidebar.dart';
import 'package:advanced_login_app/widgets/advanced_header.dart';
import 'package:advanced_login_app/models/appointment_model.dart';
import 'package:advanced_login_app/screens/settings_screen.dart';
import 'package:advanced_login_app/screens/departments_list_screen.dart';
import 'package:advanced_login_app/screens/records_screen.dart';
import 'package:advanced_login_app/screens/telemedicine_screen.dart';
import 'package:advanced_login_app/screens/queue_status_screen.dart';
import 'package:advanced_login_app/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _sidebarExpanded = true;

  @override
  void initState() {
    super.initState();
    // Load user appointments on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);

      // Set user context for appointment provider
      if (authProvider.currentUser != null && authProvider.token != null) {
        // Ensure userId is always a String
        final userId = (authProvider.currentUser!['id'] ?? '').toString();
        appointmentProvider.setUserContext(
          userId,
          authProvider.token!,
        );
      }

      appointmentProvider.loadAppointments();
    });
  }

  void _toggleSidebar() {
    setState(() {
      _sidebarExpanded = !_sidebarExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: AdvancedSidebar(
        expanded: _sidebarExpanded,
        onToggle: _toggleSidebar,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Advanced Header
            AdvancedHeader(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              onNotificationTap: () => _showNotifications(),
              onProfileTap: () => _showProfile(context),
            ),

            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomScrollView(
                  slivers: [
                    // Welcome Section
                    SliverToBoxAdapter(
                      child: _buildWelcomeSection(
                          authProvider.user?['name'] ?? 'User'),
                    ),

                    // Dashboard overview (stats + next appointment)
                    SliverToBoxAdapter(
                      child: _buildDashboardOverview(appointmentProvider),
                    ),

                    // Quick Actions
                    SliverToBoxAdapter(
                      child: _buildQuickActions(),
                    ),

                    // Upcoming Appointments
                    SliverToBoxAdapter(
                      child: _buildAppointmentsSection(appointmentProvider),
                    ),

                    // Hospital Departments
                    SliverToBoxAdapter(
                      child: _buildDepartmentsSection(),
                    ),

                    // Health Stats
                    SliverToBoxAdapter(
                      child: _buildHealthStats(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildWelcomeSection(String userName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFA6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF00BFA6).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            color: const Color(0xFF00BFA6),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Health Status: Good',
                            style: TextStyle(
                              color: Color(0xFF00BFA6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              icon: Icons.calendar_today_outlined,
              label: 'Book Appointment',
              color: const Color(0xFF6C63FF),
              onTap: () => _navigateToBooking(context),
            ),
            _buildActionCard(
              icon: Icons.access_time_outlined,
              label: 'Queue Status',
              color: const Color(0xFF00BFA6),
              onTap: () => _showQueueStatus(),
            ),
            _buildActionCard(
              icon: Icons.medical_services_outlined,
              label: 'My Records',
              color: const Color(0xFFFF6B6B),
              onTap: () => _showMedicalRecords(),
            ),
            _buildActionCard(
              icon: Icons.video_call_outlined,
              label: 'Telemedicine',
              color: const Color(0xFFFFA726),
              onTap: () => _startTelemedicine(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection(AppointmentProvider provider) {
    final appointments = provider.upcomingAppointments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 15),
          child: Text(
            'Upcoming Appointments',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (appointments.isEmpty)
          _buildEmptyAppointments()
        else
          ...appointments.map((apt) => _buildAppointmentCard(apt)).toList(),
      ],
    );
  }

  Widget _buildEmptyAppointments() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: Colors.white.withOpacity(0.3),
            size: 50,
          ),
          const SizedBox(height: 15),
          const Text(
            'No upcoming appointments',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Book your first appointment with a specialist',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final dateStr = '${appointment.dateTime.day} ${[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][appointment.dateTime.month - 1]}';
    final timeStr =
        '${appointment.dateTime.hour.toString().padLeft(2, '0')}:${appointment.dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.doctorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${appointment.departmentName} • $dateStr, $timeStr',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00BFA6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Queue #${appointment.queueNumber}',
              style: const TextStyle(
                color: Color(0xFF00BFA6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentsSection() {
    final departments = [
      {
        'icon': Icons.female_outlined,
        'label': 'Gynecology',
        'color': Color(0xFFE91E63)
      },
      {
        'icon': Icons.medical_services_outlined,
        'label': 'General',
        'color': Color(0xFF2196F3)
      },
      {
        'icon': Icons.psychology_outlined,
        'label': 'Psychology',
        'color': Color(0xFF9C27B0)
      },
      {
        'icon': Icons.favorite,
        'label': 'Dentistry',
        'color': Color(0xFF00BCD4)
      },
      {
        'icon': Icons.visibility_outlined,
        'label': 'Optometry',
        'color': Color(0xFFFF9800)
      },
      {
        'icon': Icons.science_outlined,
        'label': 'Lab Tests',
        'color': Color(0xFF4CAF50)
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 15),
          child: Text(
            'Hospital Departments',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: departments.map((dept) {
            return GestureDetector(
              onTap: () => _selectDepartment(dept['label'] as String),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      dept['icon'] as IconData,
                      color: dept['color'] as Color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dept['label'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHealthStats() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF0F3460),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Overview',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                value: '5',
                label: 'Visits this month',
                icon: Icons.medical_services_outlined,
                color: Color(0xFF6C63FF),
              ),
              _buildStatItem(
                value: '2.5h',
                label: 'Time saved',
                icon: Icons.access_time_outlined,
                color: Color(0xFF00BFA6),
              ),
              _buildStatItem(
                value: '98%',
                label: 'Satisfaction',
                icon: Icons.sentiment_satisfied_outlined,
                color: Color(0xFFFFA726),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Top-of-dashboard metrics + next upcoming appointment.
  Widget _buildDashboardOverview(AppointmentProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final all = provider.userAppointments;
    final now = DateTime.now();
    final upcoming = all
        .where((a) => a.status == 'upcoming' && a.dateTime.isAfter(now))
        .toList();
    final completed =
        all.where((a) => a.status == 'completed').toList();
    final cancelled =
        all.where((a) => a.status == 'cancelled').toList();

    Appointment? nextAppointment =
        upcoming.isNotEmpty ? upcoming.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Upcoming',
                value: upcoming.length.toString(),
                color: colorScheme.primary,
                icon: Icons.schedule,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'Completed',
                value: completed.length.toString(),
                color: Colors.greenAccent.shade400,
                icon: Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'Cancelled',
                value: cancelled.length.toString(),
                color: Colors.redAccent.shade200,
                icon: Icons.cancel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildNextAppointmentCard(nextAppointment),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 10),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextAppointmentCard(Appointment? appointment) {
    final colorScheme = Theme.of(context).colorScheme;

    if (appointment == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.event_busy,
                color: colorScheme.onSurface.withOpacity(0.7)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No upcoming appointments. Book your next visit.',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.85),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final date = appointment.dateTime;
    final dateStr =
        '${date.day}/${date.month}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_available,
                color: colorScheme.onPrimary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Appointment',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.doctorName,
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${appointment.departmentName} • $dateStr',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Navigation Methods
  void _navigateToBooking(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DepartmentsListScreen(),
      ),
    );
  }

  void _showQueueStatus() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QueueStatusScreen(),
      ),
    );
  }

  void _showMedicalRecords() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RecordsScreen(),
      ),
    );
  }

  void _startTelemedicine() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TelemedicineScreen(),
      ),
    );
  }

  void _selectDepartment(String department) {
    _navigateToBooking(context);
    // Could pass department as argument
  }

  void _showNotifications() {
    // Implement notifications
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notifications feature coming soon'),
        backgroundColor: const Color(0xFF6C63FF),
      ),
    );
  }

  void _showProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }
}
