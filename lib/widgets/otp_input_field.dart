import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:advanced_login_app/google_fonts_stub.dart';

class OTPInputField extends StatefulWidget {
  final TextEditingController controller;
  final int length;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final bool autoFocus;

  const OTPInputField({
    super.key,
    required this.controller,
    required this.length,
    required this.onChanged,
    this.enabled = true,
    this.autoFocus = true,
  });

  @override
  State<OTPInputField> createState() => _OTPInputFieldState();
}

class _OTPInputFieldState extends State<OTPInputField> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  final Color _primaryColor = const Color(0xFF6C63FF);
  final Color _accentColor = const Color(0xFF00BFA6);
  final Color _successColor = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _controllers =
        List.generate(widget.length, (index) => TextEditingController());

    // Auto-focus first field
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }

    // Listen to individual controllers
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].addListener(() {
        _onTextChanged(i);
      });
    }

    // Listen to main controller for external changes
    widget.controller.addListener(() {
      _syncFromMainController();
    });
  }

  void _onTextChanged(int index) {
    final text = _controllers[index].text;

    // Move to next field if digit entered
    if (text.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    // Move to previous field if backspace pressed on empty field
    if (text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].selection = TextSelection.fromPosition(
        const TextPosition(offset: 1),
      );
    }

    // Update main controller
    _updateMainController();
  }

  void _updateMainController() {
    final otp = _controllers.map((c) => c.text).join();
    widget.controller.text = otp;
    widget.onChanged(otp);
  }

  void _syncFromMainController() {
    final otp = widget.controller.text;

    if (otp.length <= widget.length) {
      for (int i = 0; i < widget.length; i++) {
        final digit = i < otp.length ? otp[i] : '';
        if (_controllers[i].text != digit) {
          _controllers[i].text = digit;
        }
      }
    }
  }

  Color _getBorderColor(int index) {
    if (!widget.enabled) return Colors.grey;
    if (_controllers[index].text.isNotEmpty) return _successColor;
    if (_focusNodes[index].hasFocus) return _accentColor;
    return _primaryColor.withOpacity(0.5);
  }

  double _getBorderWidth(int index) {
    if (_focusNodes[index].hasFocus) return 2.5;
    if (_controllers[index].text.isNotEmpty) return 2;
    return 1.5;
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // OTP boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.length, (index) {
            return _buildDigitBox(index);
          }),
        ),

        const SizedBox(height: 20),

        // Hidden text field for keyboard input
        SizedBox(
          width: 0,
          height: 0,
          child: TextField(
            controller: widget.controller,
            maxLength: widget.length,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
          ),
        ),

        // Input instructions
        Text(
          'Enter the 6-digit code sent to your email',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildDigitBox(int index) {
    final hasValue = _controllers[index].text.isNotEmpty;
    final isFocused = _focusNodes[index].hasFocus;

    return GestureDetector(
      onTap: () {
        _focusNodes[index].requestFocus();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 55,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(index),
            width: _getBorderWidth(index),
          ),
          boxShadow: [
            if (isFocused)
              BoxShadow(
                color: _accentColor.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            if (hasValue && !isFocused)
              BoxShadow(
                color: _successColor.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.white.withOpacity(0.02),
            ],
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: _controllers[index].text.isEmpty
                ? Text(
                    (index + 1).toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white30,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                : Text(
                    _controllers[index].text,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ),
    ).animate(delay: (index * 50).ms).slideY(
          begin: 0.5,
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
  }
}
