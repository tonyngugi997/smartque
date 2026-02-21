import 'package:flutter/material.dart';

class DepartmentSelectionScreen extends StatefulWidget {
  const DepartmentSelectionScreen({Key? key}) : super(key: key);

  @override
  State<DepartmentSelectionScreen> createState() =>
      _DepartmentSelectionScreenState();
}

class _DepartmentSelectionScreenState extends State<DepartmentSelectionScreen> {
  final List<Map<String, dynamic>> departments = [
    {
      'name': 'General Practice',
      'icon': Icons.healing,
      'description': 'General medical consultations',
    },
    {
      'name': 'Cardiology',
      'icon': Icons.favorite,
      'description': 'Heart and cardiovascular care',
    },
    {
      'name': 'Dermatology',
      'icon': Icons.spa_outlined,
      'description': 'Skin and beauty treatments',
    },
    {
      'name': 'Orthopedics',
      'icon': Icons.accessibility,
      'description': 'Bone and joint care',
    },
    {
      'name': 'Neurology',
      'icon': Icons.psychology,
      'description': 'Neurological disorders',
    },
    {
      'name': 'Pediatrics',
      'icon': Icons.child_care,
      'description': 'Child healthcare',
    },
    {
      'name': 'Dentistry',
      'icon': Icons.sentiment_satisfied,
      'description': 'Dental care and treatment',
    },
    {
      'name': 'Psychology',
      'icon': Icons.psychology_outlined,
      'description': 'Mental health services',
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
          'Select Department',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.95,
        ),
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final dept = departments[index];
          return GestureDetector(
            onTap: () {
              Navigator.pop(context, dept['name']);
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A23),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF4A9EFF),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    dept['icon'] as IconData,
                    color: const Color(0xFF4A9EFF),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dept['name'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      dept['description'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
