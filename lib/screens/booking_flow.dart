import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:advanced_login_app/providers/appointment_provider.dart';
import 'package:advanced_login_app/providers/auth_provider.dart';
import 'package:advanced_login_app/services/api_service.dart';

class DoctorSelectionScreen extends StatefulWidget {
  final String departmentName;
  final Color departmentColor;

  const DoctorSelectionScreen({
    Key? key,
    required this.departmentName,
    required this.departmentColor,
  }) : super(key: key);

  @override
  State<DoctorSelectionScreen> createState() => _DoctorSelectionScreenState();
}

class _DoctorSelectionScreenState extends State<DoctorSelectionScreen> {
  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. Rayhab Loyce',
      'specialty': 'Specialist',
      'rating': 4.8,
      'reviews': 324,
      'nextSlot': 'Today, 3:00 PM',
      'experience': '12 years',
      'image': '👩‍⚕️',
      'languages': ['English', 'Swahili'],
    },
    {
      'name': 'Dr. Brenda Jonnes',
      'specialty': 'Senior Consultant',
      'rating': 4.9,
      'reviews': 456,
      'nextSlot': 'Tomorrow, 10:00 AM',
      'experience': '15 years',
      'image': '👨‍⚕️',
      'languages': ['English', 'Mandarin'],
    },
    {
      'name': 'Dr. Keziah Njeri',
      'specialty': 'Consultant',
      'rating': 4.6,
      'reviews': 218,
      'nextSlot': 'Today, 5:30 PM',
      'experience': '8 years',
      'image': '👩‍⚕️',
      'languages': ['English', 'Spanish'],
    },
    {
      'name': 'Dr. James Kariuki',
      'specialty': 'Specialist',
      'rating': 4.7,
      'reviews': 289,
      'nextSlot': 'This Week, 2:00 PM',
      'experience': '10 years',
      'image': '👨‍⚕️',
      'languages': ['English', 'Swahili'],
    },
    {
      'name': 'Dr. Tony Gitau',
      'specialty': 'Senior Consultant',
      'rating': 4.8,
      'reviews': 398,
      'nextSlot': 'Today, 4:00 PM',
      'experience': '14 years',
      'image': '👩‍⚕️',
      'languages': ['English', 'French'],
    },
  ];

  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A23),
        elevation: 0,
        title: Text(
          '${widget.departmentName} Doctors',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('All', widget.departmentColor),
                const SizedBox(width: 8),
                _buildFilterChip('Available Today', widget.departmentColor),
                const SizedBox(width: 8),
                _buildFilterChip('Top Rated', widget.departmentColor),
              ],
            ),
          ),
          // Doctors List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DateTimeSelectionScreen(
                          doctorName: doctor['name'] as String,
                          departmentName: widget.departmentName,
                          departmentColor: widget.departmentColor,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A23),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.departmentColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Doctor Avatar
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color:
                                      widget.departmentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    doctor['image'] as String,
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Doctor Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor['name'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${doctor['specialty']} • ${doctor['experience']}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${doctor['rating']} (${doctor['reviews']} reviews)',
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: widget.departmentColor.withOpacity(0.6),
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: widget.departmentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: widget.departmentColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Next: ${doctor['nextSlot']}',
                                  style: TextStyle(
                                    color: widget.departmentColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color color) {
    final isSelected = selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = label;
        });
      },
      backgroundColor: Colors.white.withOpacity(0.1),
      selectedColor: color,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontSize: 12,
      ),
    );
  }
}

// DATE & TIME SELECTION
class DateTimeSelectionScreen extends StatefulWidget {
  final String doctorName;
  final String departmentName;
  final Color departmentColor;

  const DateTimeSelectionScreen({
    Key? key,
    required this.doctorName,
    required this.departmentName,
    required this.departmentColor,
  }) : super(key: key);

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  late DateTime selectedDate;
  String? selectedTime;
  late PageController _pageController;

  final List<String> availableTimes = [
    '9:00 AM',
    '10:30 AM',
    '12:00 PM',
    '2:00 PM',
    '3:30 PM',
    '4:45 PM',
    '5:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A23),
        elevation: 0,
        title: const Text(
          'Select Date & Time',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Calendar
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select a Date',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: 14,
                    itemBuilder: (context, index) {
                      final date = DateTime.now().add(Duration(days: index));
                      final isSelected = selectedDate.day == date.day &&
                          selectedDate.month == date.month &&
                          selectedDate.year == date.year;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = date;
                            selectedTime = null;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? widget.departmentColor
                                : const Color(0xFF1A1A23),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? widget.departmentColor
                                  : Colors.white.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                date.day.toString(),
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                [
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat',
                                  'Sun'
                                ][date.weekday - 1],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.white60,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Select a Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Time Slots
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2,
                    ),
                    itemCount: availableTimes.length,
                    itemBuilder: (context, index) {
                      final time = availableTimes[index];
                      final isSelected = selectedTime == time;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTime = time;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? widget.departmentColor
                                : const Color(0xFF1A1A23),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? widget.departmentColor
                                  : Colors.white.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              time,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Next Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedTime != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfirmationScreen(
                              doctorName: widget.doctorName,
                              departmentName: widget.departmentName,
                              departmentColor: widget.departmentColor,
                              date: selectedDate,
                              time: selectedTime!,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.departmentColor,
                  disabledBackgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//CONFIRMATION SCREEN
class ConfirmationScreen extends StatefulWidget {
  final String doctorName;
  final String departmentName;
  final Color departmentColor;
  final DateTime date;
  final String time;

  const ConfirmationScreen({
    Key? key,
    required this.doctorName,
    required this.departmentName,
    required this.departmentColor,
    required this.date,
    required this.time,
  }) : super(key: key);

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final TextEditingController notesController = TextEditingController();
  String paymentMethod = 'pay_now';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A23),
        elevation: 0,
        title: const Text(
          'Confirm Appointment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A23),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.departmentColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Doctor', widget.doctorName),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Department', widget.departmentName),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Date',
                    '${widget.date.day} ${[
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
                    ][widget.date.month - 1]} ${widget.date.year}',
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Time', widget.time),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Consultation Fee', 'KSh 1,500'),
                  const Divider(color: Colors.white24, height: 24),
                  _buildSummaryRow('Total', 'KSh 1,500',
                      bold: true, color: widget.departmentColor),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Notes Section
            const Text(
              'Additional Notes (Optional)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add any additional information...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1A1A23),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.departmentColor.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.departmentColor),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Payment Method
            const Text(
              'Payment Method',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentOption('pay_now', 'Pay Now (M-Pesa)'),
            _buildPaymentOption('pay_hospital', 'Pay at Hospital'),
            _buildPaymentOption('insurance', 'Use Insurance'),
            const SizedBox(height: 24),
            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final messenger = ScaffoldMessenger.of(context);
                    final appointmentProvider =
                        context.read<AppointmentProvider>();
                    final authProvider = context.read<AuthProvider>();

                    // Set user context if not already set
                    if (authProvider.currentUser != null &&
                        authProvider.token != null) {
                      appointmentProvider.setUserContext(
                        (authProvider.currentUser!['id'] ?? '').toString(),
                        authProvider.token!,
                      );
                    }

                    // Payment is performed after admin approval. Do not initiate STK here.

                    // Proceed to book appointment
                    final success = await appointmentProvider.bookAppointment(
                      doctorName: widget.doctorName,
                      departmentName: widget.departmentName,
                      dateTime: DateTime(
                        widget.date.year,
                        widget.date.month,
                        widget.date.day,
                        int.parse(widget.time.split(':')[0]),
                        int.parse(widget.time
                            .split(':')[1]
                            .replaceAll(RegExp(r'[^0-9]'), '')),
                      ),
                      consultationFee: 1500,
                    );

                    if (!mounted) return;

                    if (success) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuccessScreen(
                            doctorName: widget.doctorName,
                            departmentName: widget.departmentName,
                            departmentColor: widget.departmentColor,
                            date: widget.date,
                            time: widget.time,
                          ),
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Failed to book appointment. Please try again.'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.departmentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: paymentMethod == value
              ? widget.departmentColor
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: paymentMethod,
        onChanged: (val) {
          setState(() {
            paymentMethod = val!;
          });
        },
        activeColor: widget.departmentColor,
        title: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// Prompt user for M-Pesa phone numbe
Future<String?> _promptForPhoneNumber(BuildContext context) async {
  final controller = TextEditingController(text: '+254');
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Enter M-Pesa Phone Number'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          hintText: 'e.g. 2547XXXXXXXX',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isEmpty) {
              Navigator.of(ctx).pop(null);
            } else {
              Navigator.of(ctx).pop(value);
            }
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

//SUCCESS SCREEN
class SuccessScreen extends StatefulWidget {
  final String doctorName;
  final String departmentName;
  final Color departmentColor;
  final DateTime date;
  final String time;

  const SuccessScreen({
    Key? key,
    required this.doctorName,
    required this.departmentName,
    required this.departmentColor,
    required this.date,
    required this.time,
  }) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Generate appointment ID and queue number
  final String appointmentId =
      'APT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  final int queueNumber = 3;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Set user context for appointment provider
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
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Success Animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: widget.departmentColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 80,
                      color: widget.departmentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Appointment Requested',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A23),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.departmentColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Doctor', widget.doctorName,
                        icon: Icons.person),
                    const SizedBox(height: 16),
                    _buildDetailRow('Department', widget.departmentName,
                        icon: Icons.local_hospital),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Date & Time',
                      '${widget.date.day} ${[
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
                      ][widget.date.month - 1]} ${widget.date.year}, ${widget.time}',
                      icon: Icons.access_time,
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    _buildDetailRow('Appointment ID', appointmentId,
                        icon: Icons.receipt_long, highlight: true),
                    const SizedBox(height: 16),
                    _buildDetailRow('Queue Number', '#$queueNumber',
                        icon: Icons.queue, highlight: true),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.departmentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.departmentColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: widget.departmentColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'You\'ll receive a reminder 1 hour before your appointment',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Info about approval and payment
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.departmentColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your booking request has been sent and is pending approval by the clinic. You will be notified when it is approved. Payment is requested only after approval.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to home if appointment already confirmed
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.departmentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: widget.departmentColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Share Appointment',
                    style: TextStyle(
                      color: widget.departmentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {IconData? icon, bool highlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, color: widget.departmentColor, size: 20),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: highlight ? widget.departmentColor : Colors.white,
                  fontSize: 14,
                  fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
