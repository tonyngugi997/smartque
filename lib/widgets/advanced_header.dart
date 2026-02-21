import 'package:flutter/material.dart';

class AdvancedHeader extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const AdvancedHeader({
    Key? key,
    required this.onMenuTap,
    required this.onNotificationTap,
    required this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A23),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: onMenuTap,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Smart Queue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: onNotificationTap,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: onProfileTap,
          ),
        ],
      ),
    );
  }
}
