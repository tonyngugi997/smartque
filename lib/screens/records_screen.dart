import 'package:flutter/material.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A23),
        title: const Text('My Records', style: TextStyle(color: Colors.white)),
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
              'Medical Records',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'You have no uploaded records yet. Use the upload button to add medical documents.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA6)),
              onPressed: () {},
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Record'),
            ),
          ],
        ),
      ),
    );
  }
}
