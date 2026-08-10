import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';

class TrackersScreen extends StatefulWidget {
  TrackersScreen({super.key});

  @override
  State<TrackersScreen> createState() => _TrackersScreenState();
}

class _TrackersScreenState extends State<TrackersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Symptom Logging States
  final _symptomController = TextEditingController();
  double _severity = 5.0;

  // Medicine Scheduling States
  final _medNameController = TextEditingController();
  final _dosageController = TextEditingController();
  TimeOfDay _reminderTime = TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _symptomController.dispose();
    _medNameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _logSymptom(MedicateProvider provider) {
    if (_symptomController.text.trim().isEmpty) return;
    provider.addSymptom(_symptomController.text.trim(), _severity);
    _symptomController.clear();
    setState(() {
      _severity = 5.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Symptom logged successfully.')),
    );
  }

  void _addReminder(MedicateProvider provider) {
    if (_medNameController.text.trim().isEmpty || _dosageController.text.trim().isEmpty) return;
    
    final formattedTime = _reminderTime.format(context);
    provider.addMedicineReminder(
      _medNameController.text.trim(),
      _dosageController.text.trim(),
      formattedTime,
    );

    _medNameController.clear();
    _dosageController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Medicine reminder scheduled.')),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('My Logs & Trackers', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Sub tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(16)),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.transparent,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                indicator: BoxDecoration(color: AppTheme.primaryTeal, borderRadius: BorderRadius.circular(12)),
                tabs: [
                  Tab(text: 'PATIENT TRACKING'),
                  Tab(text: 'MEDICINE TRACKING'),
                ],
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSymptomTab(provider),
                _buildMedicineTab(provider),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSymptomTab(MedicateProvider provider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log New Symptom', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 12),
          GlassCard(
            radius: 20,
            borderColor: AppTheme.primaryCyan.withOpacity(0.15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _symptomController,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'What symptoms are you experiencing?',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.15),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.borderCard)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.primaryCyan)),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Symptom Severity', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    Text(
                      _severity.toInt().toString(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryCyan),
                    )
                  ],
                ),
                Slider(
                  value: _severity,
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  activeColor: AppTheme.primaryCyan,
                  inactiveColor: AppTheme.borderCard,
                  onChanged: (val) {
                    setState(() {
                      _severity = val;
                    });
                  },
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _logSymptom(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('SAVE SYMPTOM LOG', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),

          Text('Severity Metrics (History)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 16),

          // Custom Neon bar charts
          if (provider.symptoms.isEmpty)
            GlassCard(
              radius: 16,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('No logged symptoms found.', style: TextStyle(color: AppTheme.textSecondary)),
                ),
              ),
            )
          else ...[
            _buildNeonSeverityChart(provider.symptoms),
            SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: provider.symptoms.length,
              itemBuilder: (context, idx) {
                final log = provider.symptoms[provider.symptoms.length - 1 - idx];
                final dateStr = '${log.timestamp.day}/${log.timestamp.month} ${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}';
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    radius: 14,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log.symptom, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                            SizedBox(height: 4),
                            Text(dateStr, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                          ),
                          child: Text(
                            'S:${log.severity.toInt()}',
                            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNeonSeverityChart(List<SymptomLog> logs) {
    // Show maximum 6 recent logs
    final chartLogs = logs.length > 6 ? logs.sublist(logs.length - 6) : logs;
    return GlassCard(
      radius: 20,
      borderColor: AppTheme.borderCard,
      child: Column(
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, color: AppTheme.primaryCyan, size: 16),
              SizedBox(width: 8),
              Text('Severity Waveform Index', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            ],
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartLogs.map((log) {
                final heightFactor = log.severity / 10.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      log.severity.toInt().toString(),
                      style: TextStyle(fontSize: 9, color: AppTheme.primaryCyan, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Container(
                      width: 16,
                      height: 80 * heightFactor,
                      decoration: BoxDecoration(
                        gradient: AppTheme.tealCyanGradient,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryCyan.withOpacity(0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      log.symptom.length > 5 ? '${log.symptom.substring(0, 4)}.' : log.symptom,
                      style: TextStyle(fontSize: 8, color: AppTheme.textSecondary),
                    )
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineTab(MedicateProvider provider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Medicine Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 12),
          GlassCard(
            radius: 20,
            borderColor: AppTheme.primaryIndigo.withOpacity(0.15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _medNameController,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: _inputDecoration('Medicine Name (e.g. Paracetamol)', Icons.medication_liquid_rounded),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _dosageController,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: _inputDecoration('Dosage Details (e.g. 1 Tablet, 5ml)', Icons.healing_rounded),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trigger Schedule: ${_reminderTime.format(context)}',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _selectTime(context),
                      icon: Icon(Icons.timer_outlined, size: 14, color: AppTheme.primaryCyan),
                      label: Text('SET TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan)),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.primaryCyan)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _addReminder(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryIndigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('ADD PILL REMINDER', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),

          Text('Reminders Inventory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 16),

          if (provider.reminders.isEmpty)
            GlassCard(
              radius: 16,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('No scheduled medicine lists.', style: TextStyle(color: AppTheme.textSecondary)),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: provider.reminders.length,
              itemBuilder: (context, idx) {
                final rem = provider.reminders[idx];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    radius: 16,
                    borderColor: rem.isTaken ? Colors.green.withOpacity(0.2) : AppTheme.borderCard,
                    fillColor: rem.isTaken ? Colors.green.withOpacity(0.04) : Color(0x0AFFFFFF),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                rem.isTaken ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                color: rem.isTaken ? Colors.green : AppTheme.primaryTeal,
                              ),
                              onPressed: () => provider.toggleReminderTaken(rem.id),
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rem.medicineName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                    decoration: rem.isTaken ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('${rem.dosage} @ ${rem.time}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 20),
                          onPressed: () => provider.removeReminder(rem.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: AppTheme.primaryCyan, size: 18),
      filled: true,
      fillColor: Colors.black.withOpacity(0.15),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.borderCard)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.primaryCyan)),
    );
  }
}
