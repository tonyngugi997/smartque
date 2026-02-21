import 'package:flutter/material.dart';
import 'package:advanced_login_app/screens/booking_flow.dart';

class DepartmentsListScreen extends StatefulWidget {
  const DepartmentsListScreen({Key? key}) : super(key: key);

  @override
  State<DepartmentsListScreen> createState() => _DepartmentsListScreenState();
}

class _DepartmentsListScreenState extends State<DepartmentsListScreen> {
  final List<Map<String, dynamic>> departments = [
    {
      'name': 'General Practice',
      'icon': Icons.healing,
      'description': 'General medical consultations and checkups',
      'doctors': 12,
      'avgRating': 4.5,
      'color': const Color(0xFF6C63FF),
    },
    {
      'name': 'Cardiology',
      'icon': Icons.favorite_outlined,
      'description': 'Heart and cardiovascular disease treatment',
      'doctors': 8,
      'avgRating': 4.8,
      'color': const Color(0xFFFF6B6B),
    },
    {
      'name': 'Dermatology',
      'icon': Icons.spa_outlined,
      'description': 'Skin care and dermatological treatments',
      'doctors': 6,
      'avgRating': 4.3,
      'color': const Color(0xFF4ECDC4),
    },
    {
      'name': 'Orthopedics',
      'icon': Icons.accessibility_outlined,
      'description': 'Bone, joint and muscle care',
      'doctors': 10,
      'avgRating': 4.6,
      'color': const Color(0xFFFFA500),
    },
    {
      'name': 'Neurology',
      'icon': Icons.psychology_outlined,
      'description': 'Neurological disorders and brain health',
      'doctors': 7,
      'avgRating': 4.7,
      'color': const Color(0xFF9C27B0),
    },
    {
      'name': 'Pediatrics',
      'icon': Icons.child_care_outlined,
      'description': 'Children and infant healthcare',
      'doctors': 9,
      'avgRating': 4.9,
      'color': const Color(0xFF00BCD4),
    },
    {
      'name': 'Dentistry',
      'icon': Icons.sentiment_satisfied,
      'description': 'Dental care and oral health treatments',
      'doctors': 5,
      'avgRating': 4.4,
      'color': const Color(0xFF8BC34A),
    },
    {
      'name': 'Psychology',
      'icon': Icons.psychology,
      'description': 'Mental health and psychological counseling',
      'doctors': 4,
      'avgRating': 4.7,
      'color': const Color(0xFFE91E63),
    },
    {
      'name': 'Oncology',
      'icon': Icons.local_hospital_outlined,
      'description': 'Cancer diagnosis and treatment',
      'doctors': 6,
      'avgRating': 4.8,
      'color': const Color(0xFF3F51B5),
    },
    {
      'name': 'Ophthalmology',
      'icon': Icons.remove_red_eye_outlined,
      'description': 'Eye care and vision correction',
      'doctors': 5,
      'avgRating': 4.5,
      'color': const Color(0xFF2196F3),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A23),
        elevation: 0,
        title: const Text(
          'Hospital Departments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final dept = departments[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorSelectionScreen(
                    departmentName: dept['name'] as String,
                    departmentColor: dept['color'] as Color,
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
                  color: (dept['color'] as Color).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: (dept['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        dept['icon'] as IconData,
                        color: dept['color'] as Color,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Department Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dept['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dept['description'] as String,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              // Doctors count
                              Icon(
                                Icons.person_outline,
                                color:
                                    (dept['color'] as Color).withOpacity(0.8),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${dept['doctors']} doctors',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Rating
                              Icon(
                                Icons.star_rounded,
                                color: const Color(0xFFFFD700),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${dept['avgRating']}',
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
                    // Arrow
                    Icon(
                      Icons.arrow_forward_ios,
                      color: (dept['color'] as Color).withOpacity(0.6),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
