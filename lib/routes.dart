import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/enhanced_login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_appointments_screen.dart';
import 'screens/admin/admin_services_screen.dart';
import 'screens/admin/admin_counters_screen.dart';
import 'screens/admin/admin_reports_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (_) => const EnhancedLoginScreen(),
  '/dashboard': (_) => const HomeScreen(),
  '/home': (_) => const HomeScreen(),
  '/appointments': (_) => const AppointmentsScreen(),
  '/settings': (_) => const SettingsScreen(),
  '/admin': (_) => const AdminDashboardScreen(),
  '/admin/users': (_) => const AdminUsersScreen(),
  '/admin/appointments': (_) => const AdminAppointmentsScreen(),
  '/admin/services': (_) => const AdminServicesScreen(),
  '/admin/counters': (_) => const AdminCountersScreen(),
  '/admin/reports': (_) => const AdminReportsScreen(),
};
