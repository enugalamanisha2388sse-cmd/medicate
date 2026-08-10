import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _passwordController;

  bool _obscurePassword = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<MedicateProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save(MedicateProvider provider) {
    if (!_formKey.currentState!.validate()) return;

    provider.updateUserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      bio: _bioController.text.trim(),
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
    );

    setState(() {
      _isEditing = false;
      _passwordController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile details updated successfully.')),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return AppTheme.primaryTeal;
      case UserRole.doctor:
        return AppTheme.primaryIndigo;
      case UserRole.admin:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final user = provider.currentUser;

    if (user == null) {
      return Scaffold(body: Center(child: Text('No active session found.')));
    }

    final roleColor = _getRoleColor(user.role);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('My Profile Panel', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_note_rounded, color: roleColor),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Revert changes
                  _nameController.text = user.name;
                  _emailController.text = user.email;
                  _phoneController.text = user.phone;
                  _bioController.text = user.bio;
                  _passwordController.clear();
                }
                _isEditing = !_isEditing;
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Neon Glowing Profile Icon
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: roleColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: roleColor.withOpacity(0.25),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: AppTheme.cardColor,
                            child: Icon(Icons.person_outline_rounded, size: 54, color: roleColor),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      user.name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: roleColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        user.role.name.toUpperCase(),
                        style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 36),

              // Form fields card
              GlassCard(
                radius: 24,
                borderColor: roleColor.withOpacity(0.15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      enabled: _isEditing,
                      style: TextStyle(color: _isEditing ? AppTheme.textPrimary : AppTheme.textSecondary),
                      decoration: _inputDecoration('Full Name', Icons.person_outline, roleColor),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter name';
                        return null;
                      },
                    ),
                    SizedBox(height: 18),
                    TextFormField(
                      controller: _emailController,
                      enabled: _isEditing,
                      style: TextStyle(color: _isEditing ? AppTheme.textPrimary : AppTheme.textSecondary),
                      decoration: _inputDecoration('Email Address', Icons.mail_outline, roleColor),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    SizedBox(height: 18),
                    TextFormField(
                      controller: _phoneController,
                      enabled: _isEditing,
                      style: TextStyle(color: _isEditing ? AppTheme.textPrimary : AppTheme.textSecondary),
                      decoration: _inputDecoration('Contact Number', Icons.phone_android_rounded, roleColor),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter phone';
                        return null;
                      },
                    ),
                    SizedBox(height: 18),
                    TextFormField(
                      controller: _bioController,
                      enabled: _isEditing,
                      maxLines: 3,
                      style: TextStyle(color: _isEditing ? AppTheme.textPrimary : AppTheme.textSecondary),
                      decoration: _inputDecoration('Bio / Medical Summary', Icons.description_outlined, roleColor),
                    ),
                    if (_isEditing) ...[
                      SizedBox(height: 18),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: _inputDecoration(
                          'Update Password (Optional)',
                          Icons.lock_outline_rounded,
                          roleColor,
                          suffix: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary, size: 18),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v != null && v.isNotEmpty && v.length < 6) return 'Password must be >= 6 chars';
                          return null;
                        },
                      ),
                    ],
                    SizedBox(height: 24),

                    if (_isEditing)
                      ElevatedButton(
                        onPressed: () => _save(provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: roleColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      )
                    else
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderCard)),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppTheme.textSecondary, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tap the edit icon at the top right to modify profile settings.',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                              ),
                            )
                          ],
                        ),
                      )
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, Color roleColor, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: roleColor, size: 18),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.black.withOpacity(0.15),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.borderCard)),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.transparent)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: roleColor)),
    );
  }
}
