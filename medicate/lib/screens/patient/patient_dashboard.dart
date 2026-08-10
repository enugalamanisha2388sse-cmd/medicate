import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';
import '../auth/role_selection_screen.dart';
import 'appointment_calendar_screen.dart';
import 'ai_chat_screen.dart';
import 'video_consult_screen.dart';
import 'emergency_screen.dart';
import 'trackers_screen.dart';
import 'vaccination_screen.dart';
import 'health_analytics_screen.dart';
import 'inventory_screen.dart';
import 'tabs/patient_management_tab.dart';
import 'tabs/medicines_tab.dart';
import 'tabs/calendar_tab.dart';
import 'tabs/profile_tab.dart';
import 'rx_scanner_screen.dart';

class PatientDashboard extends StatefulWidget {
  PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  // Nav icon colors
  final _navColors = [
    const Color(0xFF2563EB), // Home - Blue
    const Color(0xFF16A34A), // Patients - Green
    const Color(0xFF8B5CF6), // Medicines - Purple
    const Color(0xFFF97316), // Calendar - Orange
    const Color(0xFF4F46E5), // Profile - Indigo
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final user = provider.currentUser;

    if (user == null) return const RoleSelectionScreen();

    final pages = [
      _HomeTab(provider: provider, user: user),
      const PatientManagementTab(),
      const MedicinesTab(),
      const CalendarTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: pages[_currentIndex],
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
        boxShadow: AppTheme.isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, 'Home'),
              _navItem(1, Icons.people_alt_rounded, Icons.people_alt_outlined, 'Patients'),
              _navItem(2, Icons.medication_rounded, Icons.medication_outlined, 'Medicines'),
              _navItem(3, Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Calendar'),
              _navItem(4, Icons.account_circle_rounded, Icons.account_circle_outlined, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? _navColors[index] : AppTheme.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HOME TAB
// ─────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final MedicateProvider provider;
  final UserAccount user;

  const _HomeTab({required this.provider, required this.user});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final pendingReminders = provider.reminders.where((r) => !r.isTaken).toList();
    final adherence = provider.getAdherenceRate();
    final lowStock = provider.lowStockItems.length;

    return DynamicBackground(
      child: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(gradient: AppTheme.headerGradient),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                              ),
                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                            ),
                            child: Center(
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_greeting()},',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.8), fontSize: 13,
                                  ),
                                ),
                                Text(
                                  user.name.split(' ').first,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Notification bell
                          Stack(
                            children: [
                              _HeaderIconButton(
                                icon: Icons.notifications_outlined,
                                onTap: () => _showNotifications(context),
                              ),
                              if (provider.notifications.isNotEmpty)
                                Positioned(
                                  right: 6, top: 6,
                                  child: Container(
                                    width: 8, height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF59E0B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 6),
                          _HeaderIconButton(
                            icon: Icons.logout_rounded,
                            onTap: () {
                              provider.logout();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Search Bar
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.8), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Search patients, medicines...',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.65), fontSize: 13,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                DateFormat('MMM d').format(DateTime.now()),
                                style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Stats Cards ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -1),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Row
                      Row(
                        children: [
                          Expanded(child: _StatCard(
                            icon: Icons.medication_rounded,
                            label: 'Pending',
                            value: '${pendingReminders.length}',
                            subtitle: 'Medicines',
                            color: AppTheme.warning,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard(
                            icon: Icons.calendar_today_rounded,
                            label: 'Today',
                            value: '${provider.appointments.length}',
                            subtitle: 'Appointments',
                            color: AppTheme.primaryBlue,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard(
                            icon: Icons.inventory_2_rounded,
                            label: 'Low Stock',
                            value: '$lowStock',
                            subtitle: 'Items',
                            color: lowStock > 0 ? AppTheme.error : AppTheme.success,
                          )),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Adherence card
                      _AdherenceCard(adherence: adherence),
                      const SizedBox(height: 28),

                      // Quick Actions
                      SectionHeader(
                        title: 'Quick Actions',
                        subtitle: 'Frequently used features',
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Quick Actions Grid ──────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildListDelegate([
                _QuickActionCard(
                  icon: Icons.calendar_month_rounded,
                  label: 'Book\nConsult',
                  color: AppTheme.primaryBlue,
                  lightColor: AppTheme.lightBlue,
                  delay: 0,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentCalendarScreen())),
                ),
                _QuickActionCard(
                  icon: Icons.video_call_rounded,
                  label: 'Video\nCall',
                  color: AppTheme.primaryIndigo,
                  lightColor: const Color(0xFFE0E7FF),
                  delay: 80,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoConsultScreen())),
                ),
                _QuickActionCard(
                  icon: Icons.contact_emergency_rounded,
                  label: 'SOS\nEmergency',
                  color: AppTheme.error,
                  lightColor: const Color(0xFFFEE2E2),
                  delay: 160,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EmergencyScreen())),
                ),
                _QuickActionCard(
                  icon: Icons.monitor_heart_rounded,
                  label: 'My\nTrackers',
                  color: AppTheme.info,
                  lightColor: const Color(0xFFE0F2FE),
                  delay: 240,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackersScreen())),
                ),
                _QuickActionCard(
                  icon: Icons.bar_chart_rounded,
                  label: 'Analytics',
                  color: AppTheme.primaryPurple,
                  lightColor: const Color(0xFFEDE9FE),
                  delay: 320,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthAnalyticsScreen())),
                ),
                _QuickActionCard(
                  icon: Icons.inventory_2_rounded,
                  label: 'Inventory',
                  color: AppTheme.primaryGreen,
                  lightColor: const Color(0xFFDCFCE7),
                  delay: 400,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen())),
                ),
                _QuickActionCard(
                  icon: Icons.smart_toy_rounded,
                  label: 'AI Chat',
                  color: AppTheme.primaryBlue,
                  lightColor: AppTheme.lightBlue,
                  delay: 480,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AiChatScreen())),
                ),
                _QuickActionCard(
                  icon: Icons.vaccines_rounded,
                  label: 'Vaccine\nHub',
                  color: AppTheme.warning,
                  lightColor: const Color(0xFFFEF3C7),
                  delay: 540,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VaccinationScreen())),
                ),
                _QuickActionCard(
                  icon: Icons.document_scanner_rounded,
                  label: 'Rx\nScanner',
                  color: const Color(0xFF0891B2),
                  lightColor: const Color(0xFFCFFAFE),
                  delay: 600,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RxScannerScreen())),
                ),
              ]),
            ),
          ),

          // ── Today's Schedule ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: "Today's Schedule",
                    subtitle: '${provider.reminders.length} medicine reminders',
                    actionLabel: 'See All',
                    onAction: () {},
                  ),
                  const SizedBox(height: 16),
                  if (provider.reminders.isEmpty)
                    EmptyStateWidget(
                      icon: Icons.medication_outlined,
                      title: 'No Medicines Scheduled',
                      subtitle: 'Add a medicine reminder to get started',
                    )
                  else
                    ...provider.reminders.map((r) => FadeInSlide(
                      duration: const Duration(milliseconds: 400),
                      child: _ReminderCard(
                        reminder: r,
                        onToggle: () => provider.toggleReminderTaken(r.id),
                        onDelete: () => provider.removeReminder(r.id),
                      ),
                    )),
                ],
              ),
            ),
          ),

          // ── Recent Activity ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Recent Activity',
                    actionLabel: 'Clear All',
                    onAction: () => provider.clearAllNotifications(),
                  ),
                  const SizedBox(height: 16),
                  if (provider.notifications.isEmpty)
                    EmptyStateWidget(
                      icon: Icons.notifications_none_rounded,
                      title: 'No Notifications',
                      subtitle: 'Your activity will appear here',
                    )
                  else
                    ...provider.notifications.take(5).map((n) => _ActivityItem(notification: n)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) {
          return Consumer<MedicateProvider>(
            builder: (_, prov, __) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Text('Notifications', style: AppTextStyles.heading3()),
                      const Spacer(),
                      if (prov.notifications.isNotEmpty)
                        TextButton(
                          onPressed: () { prov.clearAllNotifications(); Navigator.pop(ctx); },
                          child: Text('Clear All', style: GoogleFonts.poppins(color: AppTheme.error, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: prov.notifications.isEmpty
                      ? EmptyStateWidget(icon: Icons.notifications_none_rounded, title: 'All Caught Up', subtitle: 'No new notifications')
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: prov.notifications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _ActivityItem(notification: prov.notifications[i]),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.poppins(
            fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
          )),
          Text(subtitle, style: AppTextStyles.caption()),
        ],
      ),
    );
  }
}

class _AdherenceCard extends StatelessWidget {
  final double adherence;
  const _AdherenceCard({required this.adherence});

  @override
  Widget build(BuildContext context) {
    final percent = (adherence * 100).round();
    final color = percent >= 80 ? AppTheme.success : (percent >= 50 ? AppTheme.warning : AppTheme.error);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Medication Adherence', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                const SizedBox(height: 4),
                Text('$percent%', style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: adherence,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  percent >= 80 ? '🎉 Excellent! Keep it up.' : 'Keep taking your medicines on time.',
                  style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.75), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 62, height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: const Icon(Icons.medication_liquid_rounded, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color lightColor;
  final int delay;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.lightColor,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return FadeInSlide(
      delay: Duration(milliseconds: widget.delay),
      duration: const Duration(milliseconds: 400),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
              boxShadow: AppTheme.isDark ? [] : [
                BoxShadow(
                  color: widget.color.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: widget.lightColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    height: 1.3,
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

class _ReminderCard extends StatelessWidget {
  final MedicineReminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isTaken = reminder.isTaken;
    final statusColor = isTaken ? AppTheme.success : AppTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isTaken ? AppTheme.success.withOpacity(0.3) : AppTheme.border),
        boxShadow: AppTheme.isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isTaken ? Icons.check_circle_rounded : Icons.medication_rounded,
                color: statusColor, size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.medicineName,
                    style: AppTextStyles.labelLarge(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${reminder.dosage} • ${reminder.time}',
                    style: AppTextStyles.bodySmall(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status badge
            GestureDetector(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withOpacity(0.35)),
                ),
                child: Text(
                  isTaken ? 'Taken' : 'Pending',
                  style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w600, color: statusColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final AppNotification notification;
  const _ActivityItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isSuccess = notification.text.startsWith('SUCCESS');
    final isWarning = notification.text.startsWith('WARNING') || notification.text.startsWith('ALERT');
    final color = isSuccess ? AppTheme.success : (isWarning ? AppTheme.warning : AppTheme.info);
    final icon = isSuccess ? Icons.check_circle_outline_rounded
        : (isWarning ? Icons.warning_amber_rounded : Icons.info_outline_rounded);

    final now = DateTime.now();
    final diff = now.difference(notification.timestamp);
    final timeStr = diff.inMinutes < 1
        ? 'Just now'
        : diff.inHours < 1
            ? '${diff.inMinutes}m ago'
            : diff.inDays < 1
                ? '${diff.inHours}h ago'
                : '${diff.inDays}d ago';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.text,
                  style: AppTextStyles.bodySmall(color: AppTheme.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(timeStr, style: AppTextStyles.caption()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
