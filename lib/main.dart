// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:advanced_login_app/google_fonts_stub.dart';
import 'package:advanced_login_app/providers/auth_provider.dart';
import 'package:advanced_login_app/providers/appointment_provider.dart';
import 'package:advanced_login_app/routes.dart';
import 'package:advanced_login_app/screens/splash_screen.dart';
import 'package:advanced_login_app/providers/theme_provider.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'SmarTQue',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const SplashScreen(),
            routes: appRoutes,
          );
        },
      ),
    );
  }
}
