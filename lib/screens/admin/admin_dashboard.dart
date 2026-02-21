import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

// Dark professional admin dashboard that uses real backend data
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? stats;
  bool loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => loadingStats = true);
    final token = await AuthService().getToken();
    if (token == null) return setState(() => loadingStats = false);
    final res = await ApiService.getAdminStats(token);
    if (res['success'] == true) {
      setState(() {
        stats = (res['stats'] ?? {}) as Map<String, dynamic>;
      });
    }
    setState(() => loadingStats = false);
  }

  void _navigate(String route) => Navigator.pushNamed(context, route);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF07101A),
        cardColor: const Color(0xFF0F1A24),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF5A8FD9),
          secondary: const Color(0xFF00BFA6),
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth > 900;
            return Row(
              children: [
                _SideNavigation(selected: '/admin', isExpanded: wide),
                Expanded(
                  child: Column(
                    children: [
                      _Header(onReports: () => _navigate('/admin/reports'), onRefresh: _loadStats),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _WelcomeHeader(stats: stats, loading: loadingStats),
                                const SizedBox(height: 18),
                                _MetricsGrid(stats: stats, loading: loadingStats),
                                const SizedBox(height: 18),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 2, child: _ActivitySection(onViewAll: () => _navigate('/admin/appointments'))),
                                    const SizedBox(width: 16),
                                    Expanded(flex: 1, child: _InsightsPanel()),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final Map<String, dynamic>? stats;
  final bool loading;
  const _WelcomeHeader({Key? key, this.stats, this.loading = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pending = stats?['pendingAppointments'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0A65CC), Color(0xFF5A8FD9)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Welcome back, Administrator 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text(loading ? 'Loading stats…' : 'You have $pending pending appointments to review', style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(spacing: 10, children: [
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.check), label: const Text('Quick Approve')),
                OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.insert_drive_file), label: const Text('Export')),
              ])
            ]),
          ),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28)),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final Map<String, dynamic>? stats;
  final bool loading;
  const _MetricsGrid({Key? key, this.stats, required this.loading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(label: 'Total Users', value: stats?['usersCount']?.toString() ?? '—', icon: Icons.people, gradient: const LinearGradient(colors: [Color(0xFF4158D0), Color(0xFFC850C0)]), change: '+12%'),
      _MetricData(label: 'Total Appointments', value: stats?['totalAppointments']?.toString() ?? '—', icon: Icons.event_available, gradient: const LinearGradient(colors: [Color(0xFF0093E9), Color(0xFF80D0C7)]), change: '+8%'),
      _MetricData(label: 'Currently Active', value: stats?['activeNow']?.toString() ?? '—', icon: Icons.timer, gradient: const LinearGradient(colors: [Color(0xFFFF9966), Color(0xFFFF5E62)]), change: '-3%'),
      _MetricData(label: 'Completion Rate', value: stats?['completionRate']?.toString() ?? '—', icon: Icons.verified, gradient: const LinearGradient(colors: [Color(0xFF11998e), Color(0xFF38ef7d)]), suffix: '%'),
    ];

    if (loading) return const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: CircularProgressIndicator()));

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      int crossAxisCount = 4;
      if (width < 600) crossAxisCount = 1;
      else if (width < 900) crossAxisCount = 2;
      else if (width < 1200) crossAxisCount = 3;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.6),
        itemCount: metrics.length,
        itemBuilder: (context, i) => _ModernMetricCard(metric: metrics[i]),
      );
    });
  }
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final String? change;
  final String? suffix;
  _MetricData({required this.label, required this.value, required this.icon, required this.gradient, this.change, this.suffix});
}

class _ModernMetricCard extends StatelessWidget {
  final _MetricData metric;
  const _ModernMetricCard({Key? key, required this.metric}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)]),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: metric.gradient, borderRadius: BorderRadius.circular(8)), child: Icon(metric.icon, color: Colors.white, size: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(metric.label, style: const TextStyle(fontSize: 13, color: Colors.white60, fontWeight: FontWeight.w500)), const SizedBox(height: 8), Text('${metric.value}${metric.suffix ?? ''}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5))]),
            ),
          ]),
          if (metric.change != null)
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: metric.change!.startsWith('+') ? Colors.green.shade800 : Colors.orange.shade800, borderRadius: BorderRadius.circular(20)), child: Text(metric.change!, style: const TextStyle(color: Colors.white, fontSize: 12))),
        ]),
      ),
    );
  }
}

class _ActivitySection extends StatefulWidget {
  final VoidCallback onViewAll;
  const _ActivitySection({Key? key, required this.onViewAll}) : super(key: key);

  @override
  State<_ActivitySection> createState() => _ActivitySectionState();
}

class _ActivitySectionState extends State<_ActivitySection> {
  List<Map<String, dynamic>> activities = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => loading = true);
    final token = await AuthService().getToken();
    if (token == null) return setState(() => loading = false);
    final res = await ApiService.getAdminAppointments(token: token);
    if (res['success'] == true) {
      final list = (res['appointments'] as List).cast<Map<String, dynamic>>();
      setState(() {
        activities = list.take(8).toList();
      });
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Live Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.5)), TextButton(onPressed: widget.onViewAll, child: const Text('View all →', style: TextStyle(fontWeight: FontWeight.w600)))])),
        const Divider(height: 1, color: Color(0xFF1A2938)),
        if (loading) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
        else if (activities.isEmpty) Padding(padding: const EdgeInsets.all(16), child: Text('No activity', style: TextStyle(color: Colors.white54)))
        else ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white10, indent: 72),
          itemBuilder: (context, index) {
            final a = activities[index];
            final user = a['userName'] ?? a['user'] ?? a['customer'] ?? a['email'] ?? 'Unknown';
            final service = a['serviceName'] ?? a['service'] ?? a['department'] ?? '';
            final time = a['time'] ?? a['scheduledAt'] ?? a['createdAt'] ?? '';
            final status = a['status'] ?? '';
            String initials = '';
            if (user is String && user.isNotEmpty) {
              final parts = user.split(' ').where((s) => s.isNotEmpty).toList();
              if (parts.isNotEmpty) initials += parts[0][0];
              if (parts.length > 1) initials += parts[1][0];
              initials = initials.toUpperCase();
            }

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: _getStatusColor(status).withOpacity(0.15), 
                child: Text(initials, style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.w700))
              ),
              title: Text(user, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              subtitle: Text(service, style: const TextStyle(color: Colors.white60, fontSize: 13)),
              trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text(time, style: const TextStyle(fontSize: 12, color: Colors.white60)), const SizedBox(height: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: _getStatusColor(status).withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: Text(status, style: TextStyle(color: _getStatusColor(status), fontSize: 12, fontWeight: FontWeight.w600)))]),
            );
          },
        ),
      ]),
    );
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return Colors.green.shade400;
    case 'in progress':
    case 'in_progress':
      return Colors.blue.shade400;
    case 'pending':
      return Colors.orange.shade400;
    case 'waiting':
      return Colors.purple.shade400;
    default:
      return Colors.grey.shade400;
  }
}

class _InsightsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 12), _QuickActionButton(icon: Icons.people_outline, label: 'Manage Users', color: const Color(0xFF5A8FD9), onTap: () => Navigator.pushNamed(context, '/admin/users')), const SizedBox(height: 8), _QuickActionButton(icon: Icons.settings_outlined, label: 'Services', color: const Color(0xFF00BFA6), onTap: () => Navigator.pushNamed(context, '/admin/services')), const SizedBox(height: 8), _QuickActionButton(icon: Icons.analytics_outlined, label: 'Reports', color: const Color(0xFFFF9966), onTap: () => Navigator.pushNamed(context, '/admin/reports'))])),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('System Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 12), _StatusRow(label: 'API', status: 'Operational', isOperational: true), const SizedBox(height: 8), _StatusRow(label: 'Database', status: 'Healthy', isOperational: true)])),
    ]);
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionButton({Key? key, required this.icon, required this.label, required this.color, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12, width: 1.5)
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20)
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)))
        ]),
      )
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String status;
  final bool isOperational;
  const _StatusRow({Key? key, required this.label, required this.status, required this.isOperational}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14))),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isOperational ? Colors.green.shade400 : Colors.red.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                status,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isOperational ? Colors.green.shade300 : Colors.red.shade300,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}

class _SideNavigation extends StatelessWidget {
  final String selected;
  final bool isExpanded;
  const _SideNavigation({Key? key, required this.selected, this.isExpanded = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.dashboard_outlined, 'label': 'Dashboard', 'route': '/admin'},
      {'icon': Icons.people_outline, 'label': 'Users', 'route': '/admin/users'},
      {'icon': Icons.event_outlined, 'label': 'Appointments', 'route': '/admin/appointments'},
      {'icon': Icons.room_service_outlined, 'label': 'Services', 'route': '/admin/services'},
      {'icon': Icons.bar_chart_outlined, 'label': 'Reports', 'route': '/admin/reports'},
    ];

    return Container(
      width: isExpanded ? 220 : 72,
      color: const Color(0xFF071826),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A65CC), Color(0xFF5A8FD9)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 22,
              ),
            ),
            if (isExpanded) const SizedBox(width: 12),
            if (isExpanded)
              const Text('Admin Panel',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 15,
                    letterSpacing: -0.5,
                  )),
          ]),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 8 : 4,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final active = item['route'] == selected;
              return ListTile(
                leading: Icon(
                  item['icon'] as IconData,
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white54,
                ),
                title: isExpanded
                    ? Text(
                        item['label'] as String,
                        style: TextStyle(
                          color: active
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white70,
                        ),
                      )
                    : null,
                onTap: () => Navigator.pushNamed(
                  context,
                  item['route'] as String,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: isExpanded
              ? const Text('© SmartQueue',
                  style: TextStyle(color: Colors.white54))
              : const Icon(Icons.copyright, color: Colors.white54),
        ),
      ]),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onReports;
  final VoidCallback onRefresh;
  const _Header({Key? key, required this.onReports, required this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Administration Console',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          Row(children: [
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onReports,
              icon: const Icon(Icons.bar_chart),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.person,
                color: Color(0xFF0A65CC),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
