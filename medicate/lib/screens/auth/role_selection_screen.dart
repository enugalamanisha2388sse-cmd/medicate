import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';
import 'login_signup_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(gradient: AppTheme.headerGradient),
          ),
          // Decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top Brand Section
                Expanded(
                  flex: 2,
                  child: FadeInSlide(
                    duration: const Duration(milliseconds: 700),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.medical_services_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'SmartMed',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'AI Medicine Reminder &\nPatient Management System',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom card section
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Select Your Role',
                            style: AppTextStyles.heading2(),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Choose how you\'d like to access SmartMed',
                            style: AppTextStyles.bodyMedium(),
                          ),
                          const SizedBox(height: 28),

                          // Role Cards
                          FadeInSlide(
                            delay: const Duration(milliseconds: 200),
                            child: _RoleCard(
                              icon: Icons.person_rounded,
                              title: 'Patient',
                              subtitle: 'Manage your medicines, book appointments & track your health',
                              color: AppTheme.primaryBlue,
                              lightColor: AppTheme.lightBlue,
                              onTap: () => _navigate(context, UserRole.patient),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInSlide(
                            delay: const Duration(milliseconds: 350),
                            child: _RoleCard(
                              icon: Icons.medical_services_rounded,
                              title: 'Doctor',
                              subtitle: 'View patients, manage appointments & consultations',
                              color: AppTheme.primaryIndigo,
                              lightColor: const Color(0xFFE0E7FF),
                              onTap: () => _navigate(context, UserRole.doctor),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInSlide(
                            delay: const Duration(milliseconds: 500),
                            child: _RoleCard(
                              icon: Icons.admin_panel_settings_rounded,
                              title: 'Administrator',
                              subtitle: 'Manage hospital resources, inventory & staff access',
                              color: const Color(0xFFF59E0B),
                              lightColor: const Color(0xFFFEF3C7),
                              onTap: () => _navigate(context, UserRole.admin),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: Text(
                              'SmartMed v2.0 • HIPAA Compliant • Secure',
                              style: AppTextStyles.caption(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, UserRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginSignupScreen(role: role)),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color lightColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.lightColor,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: widget.lightColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: AppTextStyles.heading4()),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: AppTextStyles.bodySmall(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: widget.color,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
