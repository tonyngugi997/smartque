import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:advanced_login_app/google_fonts_stub.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/auth_provider.dart';

enum AuthMode { login, signup }

class EnhancedLoginScreen extends StatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Animation Controllers
  late AnimationController _mainController;
  late AnimationController _otpController;

  // Form Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpInputController = TextEditingController();

  // State controllerss
  AuthMode _mode = AuthMode.login;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  late ConfettiController _confetti;

  // OTP State
  int _otpTimer = 0;
  Timer? _timer;
  bool _isOtpVerifying = false;
  String _pendingEmail = '';
  String _pendingPassword = '';
  String _pendingName = '';

  // Colors
  final Color primary = const Color(0xFF6C63FF);
  final Color secondary = const Color(0xFF00BFA6);
  final Color dark = const Color(0xFF0A0A0F);
  final Color card = const Color(0xFF1A1A2E);
  final Color error = const Color(0xFFFF6B6B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _otpController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _mainController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mainController.dispose();
    _otpController.dispose();
    _confetti.dispose();
    _timer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _otpInputController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    _mainController.reverse().then((_) {
      setState(() {
        _mode = mode;
        _errorMessage = null;
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _nameController.clear();
      });
      _mainController.forward();
    });
  }

  void _startOtpTimer() {
    _timer?.cancel();
    setState(() => _otpTimer = 300); // 5 minutes

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_otpTimer > 0) {
            _otpTimer--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill all fields');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'Invalid email format');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(email, password);

      if (success) {
        if (mounted) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final user = authProvider.user ?? authProvider.currentUser;
          // Debug: print user object to console
          // ignore: avoid_print
          print('🔍 Logged in user: $user');

          bool isAdmin = false;
          if (user != null) {
            final role = user['role'] ?? user['type'];
            if (role is String && role.toLowerCase() == 'admin') isAdmin = true;
            if (user['isAdmin'] == true) isAdmin = true;
            if (user['roles'] is List && (user['roles'] as List).contains('admin')) isAdmin = true;
          }

          if (isAdmin) {
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } else {
        setState(() => _errorMessage = authProvider.error ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Connection error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final name = _nameController.text.trim();

    // Validation
    if (email.isEmpty || password.isEmpty || confirm.isEmpty || name.isEmpty) {
      setState(() => _errorMessage = 'Please fill all fields');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'Invalid email format');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    if (password != confirm) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.generateOtp(email);

      if (result) {
        // Store pending data
        _pendingEmail = email;
        _pendingPassword = password;
        _pendingName = name;
        _otpInputController.clear();
        _startOtpTimer();

        if (mounted) {
          _showOtpDialog();
        }
      } else {
        setState(
            () => _errorMessage = authProvider.error ?? 'Failed to send OTP');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Connection error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOtpDialog() {
    _otpController.reset();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        _otpController.forward();
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: _buildOtpDialog(),
        );
      },
    );
  }

  Widget _buildOtpDialog() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _otpController, curve: Curves.elasticOut),
      ),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [card, dark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: secondary.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: secondary.withOpacity(0.15),
                  border:
                      Border.all(color: secondary.withOpacity(0.3), width: 2),
                ),
                child: Icon(
                  Icons.mail_outline_rounded,
                  size: 40,
                  color: secondary,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Verify Your Email',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Enter the 6-digit code sent to\n$_pendingEmail',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 25),

              // OTP Input
              TextField(
                controller: _otpInputController,
                maxLength: 6,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                enabled: !_isOtpVerifying,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 10,
                ),
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 32,
                    color: Colors.white30,
                    letterSpacing: 10,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: secondary.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: secondary.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: secondary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onChanged: (value) {
                  if (value.length == 6) {
                    _verifyOtp(value);
                  }
                },
              ),
              const SizedBox(height: 15),

              // Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_outlined, size: 18, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    'Expires in ${_formatTime(_otpTimer)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isOtpVerifying
                      ? null
                      : () => _verifyOtp(_otpInputController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: secondary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isOtpVerifying
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Verify & Create Account',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel Button
              TextButton(
                onPressed:
                    _isOtpVerifying ? null : () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOtp(String otp) async {
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please enter a 6-digit code', style: GoogleFonts.poppins()),
          backgroundColor: error,
        ),
      );
      return;
    }

    setState(() => _isOtpVerifying = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Verify OTP
      final verifyResult = await authProvider.verifyOtp(_pendingEmail, otp);

      if (!verifyResult) {
        setState(() => _isOtpVerifying = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid OTP', style: GoogleFonts.poppins()),
              backgroundColor: error,
            ),
          );
        }
        return;
      }

      // Register user
      final registerResult = await authProvider.register(
        _pendingEmail,
        _pendingPassword,
        _pendingName,
      );

      setState(() => _isOtpVerifying = false);

      if (registerResult) {
        if (mounted) {
          _confetti.play();
          Navigator.pop(context); // Close OTP dialog

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created successfully!',
                  style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );

          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.error ?? 'Registration failed',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: error,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isOtpVerifying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error: ${e.toString()}', style: GoogleFonts.poppins()),
            backgroundColor: error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  dark,
                  const Color(0xFF1A1A2E),
                  primary.withOpacity(0.1),
                ],
              ),
            ),
          ),

          // Confetti
          Positioned.fill(
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: -pi / 2,
              emissionFrequency: 0.03,
              numberOfParticles: 30,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink],
            ),
          ),

          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  _buildLogo(),
                  const SizedBox(height: 40),

                  // Form Container
                  _buildFormContainer(),
                  const SizedBox(height: 30),

                  // Mode Switcher
                  _buildModeSwitcher(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _mainController, curve: Curves.easeOut)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, secondary],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            'SmarTQue',
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _mode == AuthMode.login ? 'Welcome Back' : 'Join Us',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContainer() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _mainController, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
            .animate(
          CurvedAnimation(parent: _mainController, curve: Curves.easeOutBack),
        ),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: card.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primary.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Email Field
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password Field
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePassword,
                onObscureTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 20),

              // Confirm Password
              if (_mode == AuthMode.signup) ...[
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  icon: Icons.lock_reset_rounded,
                  obscure: _obscureConfirm,
                  onObscureTap: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                const SizedBox(height: 20),
              ],

              // Name Field 
              if (_mode == AuthMode.signup) ...[
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),
              ],

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: error, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            color: error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_mode == AuthMode.login
                          ? _handleLogin
                          : _handleSignup),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _mode == AuthMode.login
                              ? 'Sign In'
                              : 'Create Account',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onObscureTap,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        prefixIcon: Icon(icon, color: primary),
        suffixIcon: onObscureTap != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: primary,
                ),
                onPressed: onObscureTap,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _mode == AuthMode.login
                ? "Don't have an account? "
                : "Already have an account? ",
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          TextButton(
            onPressed: () => _switchMode(
              _mode == AuthMode.login ? AuthMode.signup : AuthMode.login,
            ),
            child: Text(
              _mode == AuthMode.login ? 'Sign Up' : 'Sign In',
              style: GoogleFonts.poppins(
                color: secondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _mainController.forward();
    }
  }
}
