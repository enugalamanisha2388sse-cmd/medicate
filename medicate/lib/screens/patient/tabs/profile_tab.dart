import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/services/services.dart';
import '../../auth/role_selection_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final user = provider.currentUser;

    if (user == null) return const RoleSelectionScreen();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(gradient: AppTheme.headerGradient),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                          ),
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(user.name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.role.name.substring(0, 1).toUpperCase() + user.role.name.substring(1),
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(user.email, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Stats row
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -1),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  children: [
                    Expanded(child: _StatTile(value: '${provider.patients.length}', label: 'Patients')),
                    Container(width: 1, height: 40, color: AppTheme.border),
                    Expanded(child: _StatTile(value: '${provider.appointments.length}', label: 'Appointments')),
                    Container(width: 1, height: 40, color: AppTheme.border),
                    Expanded(child: _StatTile(value: '${provider.reminders.length}', label: 'Reminders')),
                  ],
                ),
              ),
            ),
          ),

          // Settings sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text('Account', style: AppTextStyles.heading4()),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsCard(children: [
                _ProfileListTile(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppTheme.primaryBlue,
                  title: 'Edit Profile',
                  subtitle: user.name,
                  onTap: () => _showEditProfileSheet(context, provider, user),
                ),
                _SettingsDivider(),
                _ProfileListTile(
                  icon: Icons.phone_outlined,
                  iconColor: AppTheme.primaryBlue,
                  title: 'Phone',
                  subtitle: user.phone,
                  onTap: () => _showEditProfileSheet(context, provider, user),
                ),
                _SettingsDivider(),
                _ProfileListTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppTheme.primaryBlue,
                  title: 'Bio',
                  subtitle: user.bio.length > 40 ? '${user.bio.substring(0, 40)}...' : user.bio,
                  onTap: () => _showEditProfileSheet(context, provider, user),
                ),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text('Preferences', style: AppTextStyles.heading4()),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsCard(children: [
                _SwitchListTile(
                  icon: Icons.dark_mode_outlined,
                  iconColor: AppTheme.primaryIndigo,
                  title: 'Dark Mode',
                  value: provider.themeMode == ThemeMode.dark,
                  onChanged: (_) => provider.toggleTheme(),
                ),
                _SettingsDivider(),
                _ProfileListTile(
                  icon: Icons.notifications_outlined,
                  iconColor: AppTheme.primaryOrange,
                  title: 'Notifications',
                  subtitle: 'Push reminders enabled',
                  onTap: () {},
                ),
                _SettingsDivider(),
                _ProfileListTile(
                  icon: Icons.language_outlined,
                  iconColor: AppTheme.info,
                  title: 'Language',
                  subtitle: 'English (US)',
                  onTap: () {},
                ),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text('More', style: AppTextStyles.heading4()),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsCard(children: [
                _ProfileListTile(
                  icon: Icons.backup_outlined,
                  iconColor: AppTheme.primaryGreen,
                  title: 'Cloud Backup',
                  subtitle: 'Last backup: Today',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Cloud backup initiated!', style: GoogleFonts.poppins()),
                      backgroundColor: AppTheme.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ));
                  },
                ),
                _SettingsDivider(),
                _ProfileListTile(
                  icon: Icons.picture_as_pdf_outlined,
                  iconColor: AppTheme.primaryPurple,
                  title: 'Export PDF Report',
                  subtitle: 'Generate health summary',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('PDF report generated successfully!', style: GoogleFonts.poppins()),
                      backgroundColor: AppTheme.primaryPurple,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ));
                  },
                ),
                _SettingsDivider(),
                _ProfileListTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppTheme.textSecondary,
                  title: 'Help & Support',
                  subtitle: 'FAQ, Contact Us',
                  onTap: () {},
                ),
              ]),
            ),
          ),

          // Sign out button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    provider.logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: BorderSide(color: AppTheme.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text('Sign Out', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, MedicateProvider provider, UserAccount user) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone);
    final bioCtrl = TextEditingController(text: user.bio);
    final passCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 20),
                Text('Edit Profile', style: AppTextStyles.heading3()),
                const SizedBox(height: 20),
                TextFormField(controller: nameCtrl, style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary), decoration: AppTheme.inputDecoration(label: 'Full Name', icon: Icons.person_outline_rounded)),
                const SizedBox(height: 14),
                TextFormField(controller: emailCtrl, style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary), decoration: AppTheme.inputDecoration(label: 'Email', icon: Icons.email_outlined)),
                const SizedBox(height: 14),
                TextFormField(controller: phoneCtrl, style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary), decoration: AppTheme.inputDecoration(label: 'Phone', icon: Icons.phone_outlined)),
                const SizedBox(height: 14),
                TextFormField(controller: bioCtrl, maxLines: 2, style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary), decoration: AppTheme.inputDecoration(label: 'Bio', icon: Icons.info_outline_rounded)),
                const SizedBox(height: 14),
                TextFormField(controller: passCtrl, obscureText: true, style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary), decoration: AppTheme.inputDecoration(label: 'New Password (optional)', icon: Icons.lock_outline_rounded)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.updateUserProfile(
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        bio: bioCtrl.text.trim(),
                        password: passCtrl.text.isNotEmpty ? passCtrl.text : null,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Profile updated!', style: GoogleFonts.poppins()),
                        backgroundColor: AppTheme.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ));
                    },
                    child: Text('Save Changes', style: AppTextStyles.buttonText()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
      Text(label, style: AppTextStyles.caption()),
    ],
  );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: AppTheme.cardDecoration,
    child: Column(children: children),
  );
}

class _ProfileListTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const _ProfileListTile({required this.icon, required this.iconColor, required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: iconColor, size: 20),
    ),
    title: Text(title, style: AppTextStyles.labelLarge()),
    subtitle: subtitle != null ? Text(subtitle!, style: AppTextStyles.bodySmall(), maxLines: 1, overflow: TextOverflow.ellipsis) : null,
    trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
  );
}

class _SwitchListTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchListTile({required this.icon, required this.iconColor, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: iconColor, size: 20),
    ),
    title: Text(title, style: AppTextStyles.labelLarge()),
    trailing: Switch(
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryBlue,
    ),
  );
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) => Divider(
    height: 1, indent: 72, endIndent: 16,
    color: AppTheme.border,
  );
}
