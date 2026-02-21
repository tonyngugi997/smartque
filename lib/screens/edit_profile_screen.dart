import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:advanced_login_app/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _insuranceController;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user ?? {};
    _nameController = TextEditingController(text: user['name'] ?? '');
    _phoneController = TextEditingController(text: user['phone'] ?? '');
    _dobController = TextEditingController(text: user['dob'] ?? '');
    _genderController = TextEditingController(text: user['gender'] ?? '');
    _insuranceController = TextEditingController(text: user['insurance'] ?? '');
    _avatarPath = user['avatar'] as String?;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      setState(() => _avatarPath = file.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.updateProfile({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'dob': _dobController.text.trim(),
      'gender': _genderController.text.trim(),
      'insurance': _insuranceController.text.trim(),
      'avatar': _avatarPath,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A23),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.white12,
                  backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                  child: _avatarPath == null
                      ? const Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 36)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Change Photo', style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Full name', labelStyle: TextStyle(color: Colors.white70)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Phone', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dobController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Date of birth', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _genderController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Gender', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _insuranceController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Insurance', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
                onPressed: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
