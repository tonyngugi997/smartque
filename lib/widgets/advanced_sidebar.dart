import 'package:flutter/material.dart';
import 'package:advanced_login_app/screens/departments_list_screen.dart';
import 'package:advanced_login_app/screens/settings_screen.dart';

class AdvancedSidebar extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const AdvancedSidebar({
    Key? key,
    required this.expanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          // Gradient header with toggle
          Container(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.onPrimary.withOpacity(0.15),
                  ),
                  child: Icon(
                    Icons.person,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                if (expanded)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SmarTQue',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Smart Hospital Dashboard',
                          style: TextStyle(
                            color:
                                colorScheme.onPrimary.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    expanded
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                  },
                  expanded: expanded,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.local_hospital_rounded,
                  label: 'Departments',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const DepartmentsListScreen(),
                      ),
                    );
                  },
                  expanded: expanded,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.calendar_month_rounded,
                  label: 'Appointments',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/appointments');
                  },
                  expanded: expanded,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                  expanded: expanded,
                ),
              ],
            ),
          ),
          // Footer hint
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                if (expanded)
                  Expanded(
                    child: Text(
                      'Tap the arrow to collapse or expand the sidebar.',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool expanded,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              if (expanded) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
