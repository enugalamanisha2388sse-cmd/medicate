import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/services/services.dart';

class PatientManagementTab extends StatefulWidget {
  const PatientManagementTab({super.key});

  @override
  State<PatientManagementTab> createState() => _PatientManagementTabState();
}

class _PatientManagementTabState extends State<PatientManagementTab> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Add / Edit Dialog ─────────────────────────────────────
  void _showAddEditDialog(BuildContext context, {PatientRecord? patient}) {
    final provider = Provider.of<MedicateProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: patient?.name ?? '');
    final ageCtrl = TextEditingController(text: patient?.age.toString() ?? '');
    final historyCtrl = TextEditingController(text: patient?.medicalHistory ?? '');
    final allergiesCtrl = TextEditingController(text: patient?.allergies ?? '');
    String selectedGender = patient?.gender ?? 'Male';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                const SizedBox(height: 12),
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
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      patient == null ? Icons.person_add_rounded : Icons.edit_rounded,
                      color: AppTheme.primaryGreen, size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    patient == null ? 'Add Patient Record' : 'Edit Patient Record',
                    style: AppTextStyles.heading3(),
                  ),
                ]),
                const SizedBox(height: 24),

                // Name
                TextFormField(
                  controller: nameCtrl,
                  style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
                  decoration: AppTheme.inputDecoration(
                    label: 'Full Name', icon: Icons.person_outline_rounded,
                    iconColor: AppTheme.primaryGreen,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                // Age + Gender row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: ageCtrl,
                        keyboardType: TextInputType.number,
                        style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
                        decoration: AppTheme.inputDecoration(
                          label: 'Age', icon: Icons.cake_outlined,
                          iconColor: AppTheme.primaryGreen,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (int.tryParse(v) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedGender,
                        dropdownColor: AppTheme.cardColor,
                        style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
                        decoration: AppTheme.inputDecoration(
                          label: 'Gender', icon: Icons.wc_outlined,
                          iconColor: AppTheme.primaryGreen,
                        ),
                        items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g),
                        )).toList(),
                        onChanged: (v) => selectedGender = v!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Medical history
                TextFormField(
                  controller: historyCtrl,
                  maxLines: 2,
                  style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
                  decoration: AppTheme.inputDecoration(
                    label: 'Medical History', icon: Icons.history_edu_rounded,
                    iconColor: AppTheme.primaryGreen,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Allergies
                TextFormField(
                  controller: allergiesCtrl,
                  style: AppTextStyles.bodyLarge(color: AppTheme.textPrimary),
                  decoration: AppTheme.inputDecoration(
                    label: 'Allergies (e.g. Penicillin)', icon: Icons.warning_amber_rounded,
                    iconColor: AppTheme.warning,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter \'None\' if no allergies' : null,
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: isSaving ? null : () async {
                      if (!formKey.currentState!.validate()) return;
                      setBS(() => isSaving = true);
                      await Future.delayed(const Duration(milliseconds: 400));

                      if (patient == null) {
                        provider.addPatient(
                          nameCtrl.text.trim(),
                          int.parse(ageCtrl.text.trim()),
                          selectedGender,
                          historyCtrl.text.trim(),
                          allergiesCtrl.text.trim(),
                        );
                      } else {
                        provider.updatePatient(
                          patient.id,
                          nameCtrl.text.trim(),
                          int.parse(ageCtrl.text.trim()),
                          selectedGender,
                          historyCtrl.text.trim(),
                          allergiesCtrl.text.trim(),
                        );
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: isSaving
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text(
                            patient == null ? 'Add Patient' : 'Save Changes',
                            style: AppTextStyles.buttonText(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Delete Confirm ────────────────────────────────────────
  void _confirmDelete(BuildContext context, MedicateProvider provider, PatientRecord patient) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.delete_outline_rounded, color: AppTheme.error),
          const SizedBox(width: 10),
          const Text('Delete Record'),
        ]),
        content: Text(
          'Are you sure you want to delete ${patient.name}\'s record? This cannot be undone.',
          style: AppTextStyles.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              provider.deletePatient(patient.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${patient.name}\'s record deleted', style: GoogleFonts.poppins()),
                backgroundColor: AppTheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ));
            },
            child: Text('Delete', style: AppTextStyles.buttonText()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final filtered = provider.patients.where((p) {
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.medicalHistory.toLowerCase().contains(q) ||
          p.allergies.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.people_alt_rounded, color: AppTheme.primaryGreen, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patients', style: AppTextStyles.heading2()),
                          Text('${provider.patients.length} total records', style: AppTextStyles.bodySmall()),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: AppTextStyles.bodyMedium(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search patients, allergies...',
                        hintStyle: AppTextStyles.bodyMedium(color: AppTheme.textHint),
                        prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 18),
                                onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Patient list
            Expanded(
              child: filtered.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.people_outline_rounded,
                      title: _searchQuery.isEmpty ? 'No Patients Yet' : 'No Matches Found',
                      subtitle: _searchQuery.isEmpty
                          ? 'Tap the + button to add your first patient record'
                          : 'Try a different search term',
                      actionLabel: _searchQuery.isEmpty ? 'Add Patient' : null,
                      onAction: _searchQuery.isEmpty ? () => _showAddEditDialog(context) : null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => FadeInSlide(
                        duration: const Duration(milliseconds: 350),
                        delay: Duration(milliseconds: i * 50),
                        child: _PatientCard(
                          patient: filtered[i],
                          onEdit: () => _showAddEditDialog(context, patient: filtered[i]),
                          onDelete: () => _confirmDelete(context, provider, filtered[i]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text('Add Patient', style: AppTextStyles.buttonText()),
      ),
    );
  }
}

// ── Patient Card ──────────────────────────────────────────────
class _PatientCard extends StatefulWidget {
  final PatientRecord patient;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PatientCard({
    required this.patient,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<_PatientCard> {
  bool _expanded = false;

  Color get _avatarColor {
    final colors = [
      AppTheme.primaryBlue,
      AppTheme.primaryGreen,
      AppTheme.primaryIndigo,
      AppTheme.primaryPurple,
      AppTheme.primaryOrange,
    ];
    return colors[widget.patient.name.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    final allergies = p.allergies.split(',').map((a) => a.trim()).where((a) => a.isNotEmpty).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Main row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: _avatarColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: _avatarColor.withOpacity(0.3), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.w700, color: _avatarColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: AppTextStyles.heading4(), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _InfoChip(label: '${p.age} yrs', color: AppTheme.primaryBlue),
                            const SizedBox(width: 6),
                            _InfoChip(
                              label: p.gender,
                              color: p.gender == 'Female' ? AppTheme.primaryPurple : AppTheme.info,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: widget.onEdit,
                            icon: Icon(Icons.edit_rounded, color: AppTheme.primaryBlue, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            onPressed: widget.onDelete,
                            icon: Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                      Icon(
                        _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textSecondary, size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded detail
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: _expanded
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: AppTheme.border, height: 16),
                        _DetailRow(
                          icon: Icons.history_edu_rounded,
                          label: 'Medical History',
                          value: p.medicalHistory,
                          iconColor: AppTheme.info,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Allergies', style: AppTextStyles.caption()),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6, runSpacing: 6,
                                    children: allergies.map((a) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warning.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                                      ),
                                      child: Text(a, style: GoogleFonts.poppins(
                                        fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.warning,
                                      )),
                                    )).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: GoogleFonts.poppins(
        fontSize: 11, fontWeight: FontWeight.w600, color: color,
      )),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption()),
              const SizedBox(height: 3),
              Text(value, style: AppTextStyles.bodyMedium(color: AppTheme.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
