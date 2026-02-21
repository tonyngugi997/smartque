import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:advanced_login_app/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Theme',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose how SmarTQue looks. Changes apply instantly and are saved.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                RadioListTile<AppThemeType>(
                  title: const Text('Light'),
                  subtitle: const Text('Bright background, great for daytime'),
                  value: AppThemeType.light,
                  groupValue: themeProvider.currentTheme,
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setTheme(value);
                    }
                  },
                ),
                const Divider(height: 0),
                RadioListTile<AppThemeType>(
                  title: const Text('Dark'),
                  subtitle: const Text('Dimmed UI, easy on the eyes'),
                  value: AppThemeType.dark,
                  groupValue: themeProvider.currentTheme,
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setTheme(value);
                    }
                  },
                ),
                const Divider(height: 0),
                RadioListTile<AppThemeType>(
                  title: const Text('Cyber'),
                  subtitle: const Text('Neon cyberpunk style theme'),
                  value: AppThemeType.cyber,
                  groupValue: themeProvider.currentTheme,
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setTheme(value);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Other',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: Text('Notifications'),
                  subtitle: Text('Configure notification preferences (coming soon)'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text('Privacy'),
                  subtitle: Text('Manage privacy and security (coming soon)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

