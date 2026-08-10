import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/services/services.dart';

class MedicinesTab extends StatefulWidget {
  const MedicinesTab({super.key});

  @override
  State<MedicinesTab> createState() => _MedicinesTabState();
}

class _MedicinesTabState extends State<MedicinesTab> with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  // Drug checker
  String _selectedDrugA = 'Paracetamol 500mg (Crocin)';
  String _selectedDrugB = 'Ibuprofen 400mg (Combiflam)';
  Map<String, String>? _interactionResult;

  // Reminder form
  final _medNameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    _medNameCtrl.dispose();
    _dosageCtrl.dispose();
    super.dispose();
  }

  // ── Add Reminder Sheet ────────────────────────────────────
  void _showAddReminderSheet(BuildContext context, MedicateProvider provider) {
    final formKey = GlobalKey<FormState>();
    _medNameCtrl.clear();
    _dosageCtrl.clear();
    _reminderTime = const TimeOfDay(hour: 8, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 20),
                Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.alarm_add_rounded, color: AppTheme.primaryPurple, size: 22)),
                  const SizedBox(width: 12),
                  Text('Add Medicine Reminder', style: AppTextStyles.heading3()),
                ]),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _medNameCtrl,
                  style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
                  decoration: AppTheme.inputDecoration(label: 'Medicine Name', icon: Icons.medication_rounded, iconColor: AppTheme.primaryPurple),
                  validator: (v) => (v == null || v.isEmpty) ? 'Medicine name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dosageCtrl,
                  style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
                  decoration: AppTheme.inputDecoration(label: 'Dosage (e.g. 1 tablet)', icon: Icons.format_list_numbered_rounded, iconColor: AppTheme.primaryPurple),
                  validator: (v) => (v == null || v.isEmpty) ? 'Dosage is required' : null,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(context: ctx, initialTime: _reminderTime);
                    if (picked != null) setBS(() => _reminderTime = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.isDark ? const Color(0xFF0F172A) : AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, color: AppTheme.primaryPurple, size: 20),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Reminder Time', style: AppTextStyles.caption()),
                          Text(_reminderTime.format(ctx), style: AppTextStyles.labelLarge(color: AppTheme.primaryPurple)),
                        ]),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      provider.addMedicineReminder(
                        _medNameCtrl.text.trim(),
                        _dosageCtrl.text.trim(),
                        _reminderTime.format(ctx),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Reminder added for ${_medNameCtrl.text.trim()}', style: GoogleFonts.poppins()),
                        backgroundColor: AppTheme.primaryPurple,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ));
                    },
                    child: Text('Set Reminder', style: AppTextStyles.buttonText()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.medication_rounded, color: AppTheme.primaryPurple, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Medicines', style: AppTextStyles.heading2()),
                      Text('${provider.reminders.length} reminders active', style: AppTextStyles.bodySmall()),
                    ],
                  ),
                ],
              ),
            ),

            // Sub-tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: TabBar(
                controller: _subTabController,
                indicator: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(9),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400),
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                tabs: const [
                  Tab(text: 'Reminders'),
                  Tab(text: 'Drug Check'),
                  Tab(text: 'Inventory'),
                ],
              ),
            ),
            const SizedBox(height: 4),

            Expanded(
              child: TabBarView(
                controller: _subTabController,
                children: [
                  _buildRemindersTab(context, provider),
                  _buildDrugCheckerTab(context, provider),
                  _buildInventoryTab(context, provider),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _subTabController,
        builder: (_, __) => _subTabController.index == 0
            ? FloatingActionButton.extended(
                onPressed: () => _showAddReminderSheet(context, provider),
                backgroundColor: AppTheme.primaryPurple,
                icon: const Icon(Icons.alarm_add_rounded, color: Colors.white),
                label: Text('Add Reminder', style: AppTextStyles.buttonText()),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  // ── Reminders Sub-Tab ─────────────────────────────────────
  Widget _buildRemindersTab(BuildContext context, MedicateProvider provider) {
    final reminders = provider.reminders;
    if (reminders.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.alarm_outlined,
        title: 'No Reminders Set',
        subtitle: 'Tap + to schedule your first medicine reminder',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: reminders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final rem = reminders[i];
        final isTaken = rem.isTaken;
        final color = isTaken ? AppTheme.success : AppTheme.warning;

        return FadeInSlide(
          delay: Duration(milliseconds: i * 60),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isTaken ? AppTheme.success.withOpacity(0.3) : AppTheme.border),
              boxShadow: AppTheme.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isTaken ? Icons.check_circle_rounded : Icons.medication_rounded,
                      color: color, size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rem.medicineName, style: AppTextStyles.labelLarge(), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Text('${rem.dosage} • ${rem.time}', style: AppTextStyles.bodySmall()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Toggle taken
                  GestureDetector(
                    onTap: () => provider.toggleReminderTaken(rem.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(
                        isTaken ? 'Taken ✓' : 'Mark Taken',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () => provider.removeReminder(rem.id),
                    icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Drug Checker Sub-Tab ──────────────────────────────────
  Widget _buildDrugCheckerTab(BuildContext context, MedicateProvider provider) {
    final medicines = provider.medicines.map((m) => m.name).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.info.withOpacity(0.25)),
            ),
            child: Row(children: [
              Icon(Icons.science_outlined, color: AppTheme.info, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'Select two medicines to check for potential drug interactions.',
                style: AppTextStyles.bodySmall(color: AppTheme.info),
              )),
            ]),
          ),
          const SizedBox(height: 24),

          // Drug A
          Text('Drug A', style: AppTextStyles.labelLarge()),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.isDark ? const Color(0xFF0F172A) : AppTheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDrugA,
                isExpanded: true,
                dropdownColor: AppTheme.cardColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: BorderRadius.circular(14),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
                style: AppTextStyles.bodyMedium(color: AppTheme.textPrimary),
                items: medicines.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setState(() { _selectedDrugA = v!; _interactionResult = null; }),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // vs divider
          Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('vs', style: GoogleFonts.poppins(color: AppTheme.primaryPurple, fontWeight: FontWeight.w700, fontSize: 14)),
          )),
          const SizedBox(height: 16),

          // Drug B
          Text('Drug B', style: AppTextStyles.labelLarge()),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.isDark ? const Color(0xFF0F172A) : AppTheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDrugB,
                isExpanded: true,
                dropdownColor: AppTheme.cardColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: BorderRadius.circular(14),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
                style: AppTextStyles.bodyMedium(color: AppTheme.textPrimary),
                items: medicines.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setState(() { _selectedDrugB = v!; _interactionResult = null; }),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Check button
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                final result = Provider.of<MedicateProvider>(context, listen: false)
                    .checkDrugInteraction(_selectedDrugA, _selectedDrugB);
                setState(() => _interactionResult = result);
              },
              icon: const Icon(Icons.biotech_rounded, color: Colors.white, size: 20),
              label: Text('Check Interaction', style: AppTextStyles.buttonText()),
            ),
          ),

          // Result card
          if (_interactionResult != null) ...[
            const SizedBox(height: 24),
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              child: _InteractionResultCard(result: _interactionResult!),
            ),
          ],
        ],
      ),
    );
  }

  // ── Inventory Sub-Tab ─────────────────────────────────────
  Widget _buildInventoryTab(BuildContext context, MedicateProvider provider) {
    final inventory = provider.inventory;
    final lowStock = provider.lowStockItems;
    final expired = provider.expiredItems;
    final expiringSoon = provider.expiringSoonItems;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert banners
          if (expired.isNotEmpty)
            _AlertBanner(
              icon: Icons.dangerous_rounded,
              text: '${expired.length} item(s) have expired and must be replaced.',
              color: AppTheme.error,
            ),
          if (lowStock.isNotEmpty)
            _AlertBanner(
              icon: Icons.warning_amber_rounded,
              text: '${lowStock.length} item(s) are running low on stock.',
              color: AppTheme.warning,
            ),
          if (expiringSoon.isNotEmpty)
            _AlertBanner(
              icon: Icons.schedule_rounded,
              text: '${expiringSoon.length} item(s) expiring within 30 days.',
              color: AppTheme.info,
            ),

          const SizedBox(height: 4),

          // Inventory list
          ...inventory.map((item) => _InventoryCard(
            item: item,
            onRestock: (amount) {
              provider.updateInventoryStock(item.id, item.stock + amount);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${item.name} restocked by $amount ${item.unit}', style: GoogleFonts.poppins()),
                backgroundColor: AppTheme.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ));
            },
          )),
        ],
      ),
    );
  }
}

// ── Drug Interaction Result Card ──────────────────────────────
class _InteractionResultCard extends StatelessWidget {
  final Map<String, String> result;
  const _InteractionResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final colorStr = result['color'] ?? 'blue';
    final Color color;
    final IconData icon;
    switch (colorStr) {
      case 'red':    color = AppTheme.error;   icon = Icons.dangerous_rounded; break;
      case 'orange': color = AppTheme.warning;  icon = Icons.warning_amber_rounded; break;
      case 'green':  color = AppTheme.success;  icon = Icons.check_circle_rounded; break;
      default:       color = AppTheme.info;     icon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Text(result['status'] ?? '', style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w700, color: color,
            )),
          ]),
          const SizedBox(height: 12),
          Text(result['details'] ?? '', style: AppTextStyles.bodyMedium()),
        ],
      ),
    );
  }
}

// ── Inventory Card ────────────────────────────────────────────
class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final ValueChanged<int> onRestock;

  const _InventoryCard({required this.item, required this.onRestock});

  @override
  Widget build(BuildContext context) {
    final isExpired = item.isExpired;
    final isLow = item.isLowStock;
    final isExpiringSoon = item.isExpiringSoon && !isExpired;
    final stockPct = item.stock / (item.threshold * 3).clamp(1, double.infinity);
    final barColor = isExpired ? AppTheme.error : (isLow ? AppTheme.warning : AppTheme.success);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpired ? AppTheme.error.withOpacity(0.4) : (isLow ? AppTheme.warning.withOpacity(0.4) : AppTheme.border),
        ),
        boxShadow: AppTheme.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.medication_liquid_rounded, color: barColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: AppTextStyles.labelLarge(), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(item.category, style: AppTextStyles.caption()),
                  ],
                ),
              ),
              // Status badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.stock} ${item.unit}',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: barColor),
                  ),
                  if (isExpired)
                    _MiniChip(label: 'Expired', color: AppTheme.error)
                  else if (isExpiringSoon)
                    _MiniChip(label: 'Exp. Soon', color: AppTheme.warning)
                  else if (isLow)
                    _MiniChip(label: 'Low Stock', color: AppTheme.warning),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onRestock(50),
                icon: Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryBlue, size: 22),
                tooltip: 'Restock +50',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: stockPct.clamp(0.0, 1.0),
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation(barColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Min: ${item.threshold} ${item.unit} • Expiry: ${item.expiryDate.day}/${item.expiryDate.month}/${item.expiryDate.year}',
            style: AppTextStyles.caption(),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _AlertBanner({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTextStyles.bodySmall(color: color))),
      ]),
    );
  }
}

// Private const access helpers
extension _AppThemeAccess on AppTheme {
  static const Color _error = Color(0xFFEF4444);
  static const Color _warning = Color(0xFFF59E0B);
}
