import 'package:flutter/material.dart';

class QueueStatusScreen extends StatelessWidget {
  const QueueStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A23),
        title: const Text('Queue Status', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Queue',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFF1A1A23),
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white70),
                title: const Text('No live queue available', style: TextStyle(color: Colors.white70)),
                subtitle: const Text('Queue tracking will appear here once enabled.', style: TextStyle(color: Colors.white54)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
