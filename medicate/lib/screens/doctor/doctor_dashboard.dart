import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';
import '../auth/role_selection_screen.dart';
import '../patient/user_profile_screen.dart';

class DoctorDashboard extends StatefulWidget {
  DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> with TickerProviderStateMixin {
  late AnimationController _callAnimationController;
  late AnimationController _telemetryController;

  int _currentIndex = 0;

  // Local call simulation states
  bool _isCallActive = false;
  String? _callingPatient;
  int _callDuration = 0;
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();
    _callAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _telemetryController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    );
  }

  @override
  void dispose() {
    _callAnimationController.dispose();
    _telemetryController.dispose();
    _callTimer?.cancel();
    super.dispose();
  }

  void _startCall(String patientName) {
    setState(() {
      _isCallActive = true;
      _callingPatient = patientName;
      _callDuration = 0;
    });
    _callAnimationController.repeat();

    Timer(Duration(seconds: 2), () {
      if (!mounted) return;
      _callAnimationController.stop();
      _telemetryController.repeat();
      _startTimer();
    });
  }

  void _startTimer() {
    _callTimer = Timer.periodic(Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _callDuration++;
      });
    });
  }

  void _hangUp() {
    _callTimer?.cancel();
    _telemetryController.stop();
    setState(() {
      _isCallActive = false;
      _callingPatient = null;
      _callDuration = 0;
    });
  }

  String _formatDuration(int secs) {
    final mins = (secs ~/ 60).toString().padLeft(2, '0');
    final seconds = (secs % 60).toString().padLeft(2, '0');
    return '$mins:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final user = provider.currentUser;

    if (user == null) {
      return RoleSelectionScreen();
    }

    if (_isCallActive) {
      return _buildCallScreen();
    }

    final myAppts = provider.appointments.where((a) => a.doctorName.toLowerCase() == user.name.toLowerCase()).toList();

    final tabs = [
      _buildHomeTab(context, provider, user, myAppts),
      _buildReportsTab(context, provider, user),
      _buildProfileTab(context, provider, user),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: DynamicBackground(
        child: tabs[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          border: Border(top: BorderSide(color: AppTheme.borderCard, width: 1.2)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryIndigo,
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.contact_page_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, MedicateProvider provider, UserAccount user, List<Appointment> myAppts) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(user),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'TOTAL PATIENTS',
                    '18',
                    Icons.people_alt_rounded,
                    AppTheme.primaryTeal,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'APPOINTMENTS',
                    myAppts.length.toString(),
                    Icons.calendar_month_rounded,
                    AppTheme.primaryIndigo,
                  ),
                ),
              ],
            ),
            SizedBox(height: 28),
            Text('Appointment Schedules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 16),

            if (myAppts.isEmpty)
              GlassCard(
                radius: 16,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text('No appointments scheduled yet.', style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: myAppts.length,
                itemBuilder: (context, idx) {
                  final appt = myAppts[idx];
                  final dateStr = '${appt.dateTime.day}/${appt.dateTime.month}/${appt.dateTime.year}';
                  final timeStr = '${appt.dateTime.hour.toString().padLeft(2, '0')}:${appt.dateTime.minute.toString().padLeft(2, '0')}';
                  final isPending = appt.status == 'Pending';

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      radius: 18,
                      borderColor: isPending ? AppTheme.primaryIndigo.withOpacity(0.3) : AppTheme.borderCard,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                appt.patientName,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPending ? Colors.orange.withOpacity(0.12) : Colors.green.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  appt.status,
                                  style: TextStyle(
                                    color: isPending ? Colors.orange : Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Consultation: ${appt.department} • $dateStr @ $timeStr',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              if (isPending) ...[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => provider.updateAppointmentStatus(appt.id, 'Approved'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryTeal,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: Text('APPROVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => provider.updateAppointmentStatus(appt.id, 'Cancelled'),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.redAccent),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: Text('CANCEL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                  ),
                                ),
                              ] else if (appt.status == 'Approved') ...[
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _startCall(appt.patientName),
                                    icon: Icon(Icons.video_call_rounded, color: Colors.white, size: 12),
                                    label: Text('LAUNCH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryIndigo,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showPrescriptionPad(context, provider, appt, user.name),
                                    icon: Icon(Icons.edit_note_rounded, color: Colors.black, size: 14),
                                    label: Text('PRESCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, IconData icon, Color color) {
    return GlassCard(
      radius: 20,
      borderColor: color.withOpacity(0.15),
      fillColor: color.withOpacity(0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          SizedBox(height: 12),
          Text(val, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildCallScreen() {
    final isRinging = _callDuration == 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video stream simulator
            if (!isRinging)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _telemetryController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: TelemetryCanvasPainter(
                        value: _telemetryController.value,
                        doctorName: _callingPatient ?? 'Patient',
                      ),
                    );
                  },
                ),
              ),

            // Ringing animation
            if (isRinging)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.25,
                child: AnimatedBuilder(
                  animation: _callAnimationController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140 * _callAnimationController.value,
                          height: 140 * _callAnimationController.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryIndigo.withOpacity(0.2 * (1 - _callAnimationController.value)),
                          ),
                        ),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.primaryIndigo.withOpacity(0.15),
                          child: Icon(Icons.person, size: 64, color: AppTheme.primaryPurple),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // Header info
            Positioned(
              top: 40,
              child: Column(
                children: [
                  Text(
                    _callingPatient ?? 'Patient File',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    isRinging ? 'CONNECTING TELEHEALTH...' : _formatDuration(_callDuration),
                    style: TextStyle(
                      fontSize: 14,
                      color: isRinging ? AppTheme.textSecondary : AppTheme.primaryCyan,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            // PIP Camera View Mockup
            if (!isRinging)
              Positioned(
                top: 40,
                right: 20,
                child: GlassCard(
                  radius: 16,
                  width: 90,
                  height: 130,
                  padding: EdgeInsets.zero,
                  borderColor: AppTheme.primaryPurple.withOpacity(0.3),
                  fillColor: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam, color: Colors.indigoAccent, size: 24),
                        SizedBox(height: 6),
                        Text('Doctor (You)', style: TextStyle(color: Colors.white, fontSize: 8)),
                      ],
                    ),
                  ),
                ),
              ),

            // Controller panel
            Positioned(
              bottom: 40,
              child: GlassCard(
                radius: 28,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                borderColor: Color(0x33FFFFFF),
                fillColor: Color(0x1AFFFFFF),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.mic, color: Colors.white),
                      onPressed: () {},
                      style: IconButton.styleFrom(backgroundColor: Colors.white12, padding: EdgeInsets.all(12)),
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.videocam, color: Colors.white),
                      onPressed: () {},
                      style: IconButton.styleFrom(backgroundColor: Colors.white12, padding: EdgeInsets.all(12)),
                    ),
                    SizedBox(width: 24),
                    IconButton(
                      icon: Icon(Icons.call_end, color: Colors.white),
                      onPressed: _hangUp,
                      style: IconButton.styleFrom(backgroundColor: Colors.redAccent, padding: EdgeInsets.all(14)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrescriptionPad(BuildContext context, MedicateProvider provider, Appointment appt, String doctorName) {
    final medController = TextEditingController();
    final dosageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.amber.withOpacity(0.3))),
        title: Row(
          children: [
            Icon(Icons.edit_note_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Prescription Pad', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Patient: ${appt.patientName}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            SizedBox(height: 16),
            TextField(
              controller: medController,
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Medicine Name',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                filled: true,
                fillColor: Colors.black.withOpacity(0.15),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.borderCard)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.amber)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: dosageController,
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Dosage details (e.g. 1 twice daily)',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                filled: true,
                fillColor: Colors.black.withOpacity(0.15),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.borderCard)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.amber)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('DISCARD', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (medController.text.trim().isNotEmpty && dosageController.text.trim().isNotEmpty) {
                provider.addPrescription(
                  appt.patientId,
                  doctorName,
                  medController.text.trim(),
                  dosageController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Prescription saved for ${appt.patientName}.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab(BuildContext context, MedicateProvider provider, UserAccount user) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(user),
            SizedBox(height: 24),
            DoctorWeeklyReportChart(data: user.patientsThisWeek),
            SizedBox(height: 24),
            Text('Clinical Performance Index', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatsInfoCard('AVG SESSION', '14.2 min', Icons.timer_outlined, AppTheme.primaryTeal),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatsInfoCard('SATISFACTION', '4.9 / 5', Icons.star_rounded, Colors.amber),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildDiagnosticsSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsInfoCard(String label, String val, IconData icon, Color color) {
    return GlassCard(
      radius: 18,
      borderColor: color.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          SizedBox(height: 10),
          Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildDiagnosticsSummaryCard() {
    return GlassCard(
      radius: 20,
      borderColor: AppTheme.borderCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SYSTEM LOG / ANOMALIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan, letterSpacing: 1)),
          SizedBox(height: 12),
          Text('• All telemetry connections running normal.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          SizedBox(height: 4),
          Text('• Outpatient clinic queues average wait time: 8 mins.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          SizedBox(height: 4),
          Text('• Emergency trauma nodes vacancy: 4 beds.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context, MedicateProvider provider, UserAccount user) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(user),
            SizedBox(height: 24),
            
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryIndigo, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryIndigo.withOpacity(0.3),
                          blurRadius: 16,
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: AppTheme.cardColor,
                      child: Icon(Icons.medication_rounded, size: 48, color: AppTheme.primaryIndigo),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(user.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 4),
                  Text(user.specialty, style: TextStyle(color: AppTheme.primaryCyan, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            SizedBox(height: 32),

            Text('Doctor Registration Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 12),
            GlassCard(
              radius: 20,
              borderColor: AppTheme.borderCard,
              child: Column(
                children: [
                  _buildProfileRow('LICENSE CODE', user.licenseNumber),
                  _buildProfileRow('TELEHEALTH RATE', '₹${user.consultFee.toStringAsFixed(0)} / Session'),
                  _buildProfileRow('CLINIC LOCATION', 'Level 3, Cardiac Wing at ${user.hospitalName.isNotEmpty ? user.hospitalName : "Central Clinic"}'),
                  _buildProfileRow('CLINICAL BIO', user.bio),
                ],
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen())),
                icon: Icon(Icons.manage_accounts_rounded, color: Colors.white),
                label: Text('EDIT ACCOUNT SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryIndigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String val) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 3,
            child: Text(val, style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(UserAccount user) {
    final provider = Provider.of<MedicateProvider>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Portal Operator,', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            SizedBox(height: 4),
            Text(user.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ],
        ),
        Row(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  onPressed: () => _showNotificationsBottomSheet(context, provider),
                  icon: Icon(Icons.notifications_outlined, color: AppTheme.textSecondary),
                  tooltip: 'Notifications',
                ),
                if (provider.notifications.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text(
                        '${provider.notifications.length}',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
            IconButton(
              onPressed: () {
                provider.logout();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RoleSelectionScreen()));
              },
              icon: Icon(Icons.logout_rounded, color: Colors.redAccent),
              tooltip: 'Logout',
            ),
          ],
        )
      ],
    );
  }

  void _showNotificationsBottomSheet(BuildContext context, MedicateProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GlassCard(
          radius: 30,
          borderColor: AppTheme.primaryIndigo.withOpacity(0.3),
          fillColor: AppTheme.background.withOpacity(0.98),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(color: AppTheme.textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications_active_rounded, color: AppTheme.primaryIndigo, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Doctor Notifications',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    if (provider.notifications.isNotEmpty)
                      TextButton(
                        onPressed: () => provider.clearAllNotifications(),
                        child: Text('CLEAR ALL', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                if (provider.notifications.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text('No new alerts.', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: provider.notifications.length,
                      itemBuilder: (context, idx) {
                        final notif = provider.notifications[idx];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderCard),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: AppTheme.primaryIndigo, size: 18),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  notif.text,
                                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.4),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close_rounded, size: 16, color: AppTheme.textSecondary),
                                onPressed: () => provider.dismissNotification(notif.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.borderCard),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('DISMISS', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class DoctorWeeklyReportChart extends StatelessWidget {
  final List<int> data;
  DoctorWeeklyReportChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final totalPatients = data.fold(0, (sum, val) => sum + val);

    return GlassCard(
      radius: 20,
      borderColor: AppTheme.primaryIndigo.withOpacity(0.2),
      fillColor: AppTheme.primaryIndigo.withOpacity(0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics_rounded, color: AppTheme.primaryIndigo, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Weekly Workload Report',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.primaryIndigo.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Text('$totalPatients Patients', style: TextStyle(color: AppTheme.primaryCyan, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          SizedBox(height: 6),
          Text('Total diagnostic consultations conducted this calendar week.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (idx) {
                final count = data[idx];
                final maxCount = data.reduce(max);
                final heightFactor = maxCount > 0 ? count / maxCount : 0.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 6),
                    Container(
                      width: 18,
                      height: 90 * heightFactor,
                      decoration: BoxDecoration(
                        gradient: AppTheme.indigoPurpleGradient,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryIndigo.withOpacity(0.3),
                            blurRadius: 6,
                          )
                        ]
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(days[idx], style: TextStyle(fontSize: 9, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                  ],
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}

class TelemetryCanvasPainter extends CustomPainter {
  final double value;
  final String doctorName;

  TelemetryCanvasPainter({required this.value, required this.doctorName});

  @override
  void paint(Canvas canvas, Size size) {
    final techPaint = Paint()
      ..color = AppTheme.primaryIndigo.withOpacity(0.12)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final centerY = size.height * 0.5;
    final graphPath = Path()..moveTo(0, centerY);

    for (double x = 0; x < size.width; x += 10) {
      double phase = (x / 20) - (value * 2 * 3.1415);
      double y = centerY + 20 * sin(phase);
      if ((x.toInt() % 140) < 20) {
        y -= 60 * sin((x % 140) / 20 * 3.1415);
      }
      graphPath.lineTo(x, y);
    }
    canvas.drawPath(graphPath, techPaint);

    final targetPaint = Paint()
      ..color = AppTheme.primaryPurple.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final ringRadius = 75 + 8 * sin(value * 2 * 3.1415);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), ringRadius, targetPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 8, Paint()..color = Colors.purpleAccent.withOpacity(0.5));

    final sweepPaint = Paint()
      ..color = AppTheme.primaryPurple.withOpacity(0.06)
      ..strokeWidth = 2.0;
    double sweepY = size.height * value;
    canvas.drawLine(Offset(0, sweepY), Offset(size.width, sweepY), sweepPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
