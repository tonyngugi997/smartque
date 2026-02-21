import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:advanced_login_app/google_fonts_stub.dart';
import 'package:advanced_login_app/providers/appointment_provider.dart';
import 'package:advanced_login_app/providers/auth_provider.dart';
import 'package:advanced_login_app/models/appointment_model.dart';
import '../services/api_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  Timer? _queueTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load appointments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);

      if (authProvider.currentUser != null && authProvider.token != null) {
        appointmentProvider.setUserContext(
          (authProvider.currentUser!['id'] ?? '').toString(),
          authProvider.token!,
        );
      }

      _loadAppointments();
    });
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    await Provider.of<AppointmentProvider>(context, listen: false)
        .loadAppointments();
    setState(() => _isLoading = false);
    // Refresh queue positions immediately and start polling
    try {
      final provider = Provider.of<AppointmentProvider>(context, listen: false);
      await provider.refreshAllQueuePositions();
      _startQueuePolling();
    } catch (_) {}
  }

  void _startQueuePolling() {
    _queueTimer?.cancel();
    _queueTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      final provider = Provider.of<AppointmentProvider>(context, listen: false);
      await provider.refreshAllQueuePositions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _queueTimer?.cancel();
    super.dispose();
  }

  String _formatDate(DateTime dateTime) {
    final months = [
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
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getTimeRemaining(DateTime appointmentTime) {
    final now = DateTime.now();
    final difference = appointmentTime.difference(now);

    if (difference.isNegative) {
      return 'Appointment passed';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h remaining';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m remaining';
    } else {
      return '${minutes}m remaining';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFC107);
      case 'approved':
        return const Color(0xFF00BFA6);
      case 'in_progress':
        return const Color(0xFF6C63FF);
      case 'upcoming':
        return const Color(0xFF00BFA6);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return const Color(0xFFFF6B6B);
      case 'rejected':
        return const Color(0xFFB00020);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.surface, colorScheme.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'My Appointments',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View and manage your appointments',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: colorScheme.primary,
                unselectedLabelColor: Colors.white.withOpacity(0.5),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF6C63FF).withOpacity(0.2),
                ),
                tabs: const [
                  Tab(
                    child: Text(
                      'Upcoming',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Completed',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Cancelled',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF),
                      ),
                    )
                  : Consumer<AppointmentProvider>(
                      builder: (context, appointmentProvider, child) {
                        final allAppointments =
                            appointmentProvider.userAppointments;
                        final upcomingAppointments = allAppointments
                          .where((apt) => ['upcoming', 'pending', 'approved', 'in_progress'].contains(apt.status))
                          .toList();
                        final completedAppointments = allAppointments
                            .where((apt) => apt.status == 'completed')
                            .toList();
                        final cancelledAppointments = allAppointments
                            .where((apt) => apt.status == 'cancelled')
                            .toList();

                        return TabBarView(
                          controller: _tabController,
                          children: [
                            // Upcoming Tab
                            _buildAppointmentsList(
                              upcomingAppointments,
                              appointmentProvider,
                              context,
                            ),
                            // Completed Tab
                            _buildAppointmentsList(
                              completedAppointments,
                              appointmentProvider,
                              context,
                            ),
                            // Cancelled Tab
                            _buildAppointmentsList(
                              cancelledAppointments,
                              appointmentProvider,
                              context,
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(
    List<Appointment> appointments,
    AppointmentProvider appointmentProvider,
    BuildContext context,
  ) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today,
                size: 50,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No appointments',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any appointments in this category',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final statusColor = _getStatusColor(appointment.status);

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.doctorName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appointment.departmentName,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        appointment.status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Color(0xFF00BFA6), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(appointment.dateTime),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.access_time,
                        color: Color(0xFF00BFA6), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(appointment.dateTime),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.queue, color: Color(0xFF6C63FF), size: 18),
                    const SizedBox(width: 8),
                    Consumer<AppointmentProvider>(
                      builder: (context, provider, _) {
                        final dynamicPos = provider.queuePositionFor(appointment.id);
                        final display = dynamicPos != null ? '#$dynamicPos' : '#${appointment.queueNumber}';
                        return Text(
                          'Queue $display',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6C63FF),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    if (appointment.status == 'upcoming' || appointment.status == 'in_progress')
                      Text(
                        _getTimeRemaining(appointment.dateTime),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00BFA6),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF6C63FF),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Consultation Fee: KSH ${appointment.consultationFee.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (appointment.status == 'upcoming' || appointment.status == 'in_progress') ...[
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showDetailModal(
                            context,
                            appointment,
                          ),
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: Text(
                            'Details',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF6C63FF).withOpacity(0.2),
                            foregroundColor: const Color(0xFF6C63FF),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (appointment.status != 'pending' && appointment.status != 'approved')
                        const SizedBox(width: 10),
                      if (appointment.status != 'pending' && appointment.status != 'approved')
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showRescheduleDialog(
                              context,
                              appointment,
                              appointmentProvider,
                            ),
                            icon: const Icon(Icons.edit, size: 18),
                            label: Text(
                              'Reschedule',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF00BFA6).withOpacity(0.2),
                              foregroundColor: const Color(0xFF00BFA6),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: Color(0xFF00BFA6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showCancelDialog(
                            context,
                            appointment,
                            appointmentProvider,
                          ),
                          icon: const Icon(Icons.close, size: 18),
                          label: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFF6B6B).withOpacity(0.2),
                            foregroundColor: const Color(0xFFFF6B6B),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: Color(0xFFFF6B6B),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // If appointment is approved, allow payment
                      if (appointment.status == 'approved')
                        const SizedBox(width: 10),
                      if (appointment.status == 'approved')
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _promptAndPay(context, appointment),
                            icon: const Icon(Icons.payment, size: 18),
                            label: Text('Pay', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
                              foregroundColor: const Color(0xFF6C63FF),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Color(0xFF6C63FF)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCancelDialog(
    BuildContext context,
    Appointment appointment,
    AppointmentProvider appointmentProvider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFFF6B6B),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Cancel Appointment?',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to cancel your appointment with ${appointment.doctorName}?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Keep It',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final success = await appointmentProvider
                            .cancelAppointment(appointment.id);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Appointment cancelled successfully'),
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to cancel appointment'),
                              backgroundColor: Color(0xFFFF6B6B),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel It',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRescheduleDialog(
    BuildContext context,
    Appointment appointment,
    AppointmentProvider appointmentProvider,
  ) {
    DateTime selectedDate = appointment.dateTime;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(appointment.dateTime);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reschedule Appointment',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) {
                    selectedDate = date;
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _formatDate(selectedDate),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA6).withOpacity(0.2),
                  foregroundColor: const Color(0xFF00BFA6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: ctx,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    selectedTime = time;
                  }
                },
                icon: const Icon(Icons.access_time),
                label: Text(
                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA6).withOpacity(0.2),
                  foregroundColor: const Color(0xFF00BFA6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final newDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        final success = await appointmentProvider
                            .rescheduleAppointment(appointment.id, newDateTime);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Appointment rescheduled successfully'),
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to reschedule appointment'),
                              backgroundColor: Color(0xFFFF6B6B),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA6),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Reschedule',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailModal(
    BuildContext context,
    Appointment appointment,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder: (ctx) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Appointment Details',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Doctor Info Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF).withOpacity(0.2),
                      const Color(0xFF6C63FF).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doctor Information',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6C63FF),
                                Color(0xFF00BFA6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.doctorName,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appointment.departmentName,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.6),
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
              const SizedBox(height: 20),

              // Date & Time Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00BFA6).withOpacity(0.2),
                      const Color(0xFF00BFA6).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF00BFA6).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointment Time',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF00BFA6),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(appointment.dateTime),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(appointment.dateTime),
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Queue & Fee Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF9500).withOpacity(0.2),
                      const Color(0xFFFF9500).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFFF9500).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Queue Position',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.queue,
                                  color: Color(0xFFFF9500),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '#${appointment.queueNumber}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Consultation Fee',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'KSH ${appointment.consultationFee.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF9500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (appointment.status == 'upcoming') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF00BFA6),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _getTimeRemaining(appointment.dateTime),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF00BFA6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _getStatusColor(appointment.status),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      appointment.status == 'upcoming'
                          ? Icons.schedule
                          : appointment.status == 'completed'
                              ? Icons.check_circle
                              : Icons.cancel,
                      color: _getStatusColor(appointment.status),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      appointment.status.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(appointment.status),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _promptAndPay(BuildContext context, Appointment appointment) {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter phone number'),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: '2547XXXXXXXX'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = phoneController.text.trim();
              if (phone.isEmpty) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Initiating payment...')),
              );

              try {
                final res = await ApiService.initiateMpesaPayment(
                  phoneNumber: phone,
                  amount: appointment.consultationFee,
                  accountReference: 'Appointment#${appointment.id}',
                );

                if (res['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('STK push initiated. Check your phone.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment failed: ${res['error'] ?? 'unknown'}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment error: $e')),
                );
              }
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }
}
