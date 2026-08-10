import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';
import '../patient/patient_dashboard.dart';
import '../doctor/doctor_dashboard.dart';

// Admin dashboard placeholder (keeps existing import)
// ignore: must_be_immutable
class _AdminDashboardPlaceholder extends StatelessWidget {
  const _AdminDashboardPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class LoginSignupScreen extends StatefulWidget {
  final UserRole role;
  const LoginSignupScreen({super.key, required this.role});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  // Login controllers
  final _loginEmail    = TextEditingController();
  final _loginPassword = TextEditingController();

  // Signup controllers
  final _signupName     = TextEditingController();
  final _signupEmail    = TextEditingController();
  final _signupPassword = TextEditingController();
  final _signupConfirm  = TextEditingController();
  final _adminCode      = TextEditingController();

  // OTP
  final _otpController = TextEditingController();
  bool _showOtpField = false;

  bool _loginObscure  = true;
  bool _signupObscure = true;
  bool _confirmObscure = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Pre-fill demo credentials
    _loginEmail.text = _demoEmail;
    _loginPassword.text = 'password123';
  }

  String get _demoEmail {
    switch (widget.role) {
      case UserRole.patient: return 'patient@medicate.com';
      case UserRole.doctor:  return 'doctor@medicate.com';
      case UserRole.admin:   return 'admin@medicate.com';
    }
  }

  String get _roleName {
    switch (widget.role) {
      case UserRole.patient: return 'Patient';
      case UserRole.doctor:  return 'Doctor';
      case UserRole.admin:   return 'Administrator';
    }
  }

  Color get _roleColor {
    switch (widget.role) {
      case UserRole.patient: return AppTheme.primaryBlue;
      case UserRole.doctor:  return AppTheme.primaryIndigo;
      case UserRole.admin:   return const Color(0xFFF59E0B);
    }
  }

  IconData get _roleIcon {
    switch (widget.role) {
      case UserRole.patient: return Icons.person_rounded;
      case UserRole.doctor:  return Icons.medical_services_rounded;
      case UserRole.admin:   return Icons.admin_panel_settings_rounded;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmail.dispose();    _loginPassword.dispose();
    _signupName.dispose();    _signupEmail.dispose();
    _signupPassword.dispose(); _signupConfirm.dispose();
    _adminCode.dispose();     _otpController.dispose();
    super.dispose();
  }

  // ── Login ──────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final provider = Provider.of<MedicateProvider>(context, listen: false);
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final success = provider.login(
      _loginEmail.text.trim(),
      _loginPassword.text,
      widget.role,
    );
    setState(() => _isLoading = false);

    if (success) {
      _navigateToDashboard();
    } else {
      _showError('Invalid credentials or role mismatch. Try the demo account.');
    }
  }

  // ── Sign Up ────────────────────────────────────────────────
  Future<void> _handleSignup() async {
    if (!_signupFormKey.currentState!.validate()) return;
    if (widget.role == UserRole.admin && _adminCode.text.trim() != 'ADMIN2026') {
      _showError('Invalid administrator verification code.');
      return;
    }

    final provider = Provider.of<MedicateProvider>(context, listen: false);
    setState(() => _isLoading = true);

    if (!_showOtpField) {
      // Request OTP
      try {
        await Future.delayed(const Duration(milliseconds: 600));
        provider.requestSignUpOtp(_signupEmail.text.trim());
        setState(() { _showOtpField = true; _isLoading = false; });
        _showSuccess('OTP sent! Use the code shown in the debug banner (simulated).');
      } catch (e) {
        setState(() => _isLoading = false);
        _showError(e.toString().replaceAll('Exception:', '').trim());
      }
    } else {
      // Verify OTP
      await Future.delayed(const Duration(milliseconds: 600));
      final ok = provider.verifyOtpAndRegister(
        _signupName.text.trim(),
        _signupEmail.text.trim(),
        _signupPassword.text,
        widget.role,
        _otpController.text.trim(),
      );
      setState(() => _isLoading = false);

      if (ok) {
        _navigateToDashboard();
      } else {
        _showError('Invalid OTP. Check the debug banner and try again.');
      }
    }
  }

  void _navigateToDashboard() {
    final provider = Provider.of<MedicateProvider>(context, listen: false);
    final user = provider.currentUser;
    if (user == null) return;

    Widget dest;
    switch (user.role) {
      case UserRole.patient: dest = PatientDashboard(); break;
      case UserRole.doctor:  dest = DoctorDashboard(); break;
      case UserRole.admin:   dest = PatientDashboard(); break; // Admin uses same shell for now
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dest));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: GoogleFonts.poppins(fontSize: 13))),
      ]),
      backgroundColor: AppTheme.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: GoogleFonts.poppins(fontSize: 13))),
      ]),
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showForgotPasswordSheet() {
    final emailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Icon(Icons.lock_reset_rounded, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text('Reset Password', style: AppTextStyles.heading3()),
            ]),
            const SizedBox(height: 8),
            Text(
              'Enter your registered email to receive a reset link.',
              style: AppTextStyles.bodyMedium(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
              decoration: AppTheme.inputDecoration(
                label: 'Email Address',
                icon: Icons.email_outlined,
                hint: 'you@example.com',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final provider = Provider.of<MedicateProvider>(ctx, listen: false);
                  final sent = provider.sendPasswordReset(emailCtrl.text.trim());
                  Navigator.pop(ctx);
                  if (sent) {
                    _showSuccess('Reset link sent to ${emailCtrl.text.trim()}!');
                  } else {
                    _showError('No account found with that email.');
                  }
                },
                child: const Text('Send Reset Link'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Top gradient header
          Positioned(
            top: 0, left: 0, right: 0,
            height: 260,
            child: Container(
              decoration: BoxDecoration(gradient: AppTheme.headerGradient),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(_roleIcon, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_roleName Portal',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Welcome to SmartMed',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main scrollable content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 160),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Tab bar
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        onTap: (_) { setState(() { _showOtpField = false; }); },
                        indicator: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w500,
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: AppTheme.textSecondary,
                        tabs: const [
                          Tab(text: 'Sign In'),
                          Tab(text: 'Sign Up'),
                        ],
                      ),
                    ),

                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLoginTab(),
                          _buildSignupTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Login Tab ──────────────────────────────────────────────
  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo: $_demoEmail / password123',
                      style: AppTextStyles.bodySmall(color: AppTheme.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Email
            Text('Email Address', style: AppTextStyles.labelLarge()),
            const SizedBox(height: 8),
            TextFormField(
              controller: _loginEmail,
              keyboardType: TextInputType.emailAddress,
              style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
              decoration: AppTheme.inputDecoration(
                label: '',
                icon: Icons.email_outlined,
                hint: 'Enter your email',
              ).copyWith(labelText: null),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Password
            Text('Password', style: AppTextStyles.labelLarge()),
            const SizedBox(height: 8),
            TextFormField(
              controller: _loginPassword,
              obscureText: _loginObscure,
              style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
              decoration: AppTheme.inputDecoration(
                label: '',
                icon: Icons.lock_outline_rounded,
                hint: 'Enter your password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _loginObscure = !_loginObscure),
                  icon: Icon(
                    _loginObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppTheme.textSecondary, size: 20,
                  ),
                ),
              ).copyWith(labelText: null),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPasswordSheet,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white,
                        ),
                      )
                    : Text('Sign In', style: AppTextStyles.buttonText()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Signup Tab ─────────────────────────────────────────────
  Widget _buildSignupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Form(
        key: _signupFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showOtpField) ..._buildSignupFields(),
            if (_showOtpField) ..._buildOtpFields(),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                child: _isLoading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white,
                        ),
                      )
                    : Text(
                        _showOtpField ? 'Verify & Create Account' : 'Create Account',
                        style: AppTextStyles.buttonText(),
                      ),
              ),
            ),
            if (_showOtpField) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _showOtpField = false),
                  child: Text(
                    'Back to details',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary, fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSignupFields() => [
    _fieldLabel('Full Name'),
    const SizedBox(height: 8),
    TextFormField(
      controller: _signupName,
      style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
      decoration: AppTheme.inputDecoration(label: '', icon: Icons.person_outline_rounded, hint: 'Your full name').copyWith(labelText: null),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
    ),
    const SizedBox(height: 16),
    _fieldLabel('Email Address'),
    const SizedBox(height: 8),
    TextFormField(
      controller: _signupEmail,
      keyboardType: TextInputType.emailAddress,
      style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
      decoration: AppTheme.inputDecoration(label: '', icon: Icons.email_outlined, hint: 'you@example.com').copyWith(labelText: null),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Email is required';
        if (!v.contains('@')) return 'Enter a valid email';
        return null;
      },
    ),
    const SizedBox(height: 16),
    _fieldLabel('Password'),
    const SizedBox(height: 8),
    TextFormField(
      controller: _signupPassword,
      obscureText: _signupObscure,
      style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
      decoration: AppTheme.inputDecoration(
        label: '', icon: Icons.lock_outline_rounded, hint: 'Create a strong password',
        suffixIcon: IconButton(
          onPressed: () => setState(() => _signupObscure = !_signupObscure),
          icon: Icon(_signupObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppTheme.textSecondary, size: 20),
        ),
      ).copyWith(labelText: null),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        if (v.length < 6) return 'Must be at least 6 characters';
        return null;
      },
    ),
    const SizedBox(height: 16),
    _fieldLabel('Confirm Password'),
    const SizedBox(height: 8),
    TextFormField(
      controller: _signupConfirm,
      obscureText: _confirmObscure,
      style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
      decoration: AppTheme.inputDecoration(
        label: '', icon: Icons.lock_outline_rounded, hint: 'Confirm your password',
        suffixIcon: IconButton(
          onPressed: () => setState(() => _confirmObscure = !_confirmObscure),
          icon: Icon(_confirmObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppTheme.textSecondary, size: 20),
        ),
      ).copyWith(labelText: null),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please confirm your password';
        if (v != _signupPassword.text) return 'Passwords do not match';
        return null;
      },
    ),
    if (widget.role == UserRole.admin) ...[
      const SizedBox(height: 16),
      _fieldLabel('Admin Code'),
      const SizedBox(height: 8),
      TextFormField(
        controller: _adminCode,
        style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
        decoration: AppTheme.inputDecoration(label: '', icon: Icons.vpn_key_rounded, hint: 'Enter admin verification code').copyWith(labelText: null),
        validator: (v) => (v == null || v.isEmpty) ? 'Admin code is required' : null,
      ),
    ],
  ];

  List<Widget> _buildOtpFields() => [
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.mail_outline_rounded, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'OTP sent to ${_signupEmail.text}. In simulation, check the debug console for the generated OTP.',
              style: AppTextStyles.bodySmall(color: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 24),
    _fieldLabel('Enter OTP'),
    const SizedBox(height: 8),
    TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
      decoration: AppTheme.inputDecoration(
        label: '', icon: Icons.pin_outlined, hint: '6-digit code',
      ).copyWith(labelText: null, counterText: ''),
      validator: (v) {
        if (v == null || v.isEmpty) return 'OTP is required';
        if (v.length != 6) return 'Enter the 6-digit code';
        return null;
      },
    ),
  ];

  Widget _fieldLabel(String text) => Text(text, style: AppTextStyles.labelLarge());
}
