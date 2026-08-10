import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class VideoConsultScreen extends StatefulWidget {
  VideoConsultScreen({super.key});

  @override
  State<VideoConsultScreen> createState() => _VideoConsultScreenState();
}

class _VideoConsultScreenState extends State<VideoConsultScreen> with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _telemetryController;
  Timer? _callTimer;
  int _callDuration = 0; // seconds

  // Calling States: 'idle', 'connecting', 'ringing', 'active'
  String _callState = 'idle';
  String? _callingDoctorName;
  String? _callingDoctorDept;

  final List<Map<String, String>> _doctors = [
    {'name': 'Dr. Sarah Connor', 'dept': 'Cardiology Specialist', 'exp': '12 yrs exp', 'status': 'Online'},
    {'name': 'Dr. Bruce Banner', 'dept': 'Endocrinology & Vitals', 'exp': '15 yrs exp', 'status': 'Online'},
    {'name': 'Dr. Stephen Strange', 'dept': 'Neurology & Surgery', 'exp': '18 yrs exp', 'status': 'Busy'},
    {'name': 'Dr. Reed Richards', 'dept': 'General Diagnostics', 'exp': '20 yrs exp', 'status': 'Online'},
  ];

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
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
    _rippleController.dispose();
    _telemetryController.dispose();
    _callTimer?.cancel();
    super.dispose();
  }

  void _startCallSequence(String docName, String dept) {
    setState(() {
      _callState = 'connecting';
      _callingDoctorName = docName;
      _callingDoctorDept = dept;
    });
    _rippleController.repeat();

    // 1.5 seconds connecting -> ringing
    Timer(Duration(milliseconds: 1500), () {
      if (!mounted || _callState != 'connecting') return;
      setState(() {
        _callState = 'ringing';
      });

      // 2 seconds ringing -> active call
      Timer(Duration(seconds: 2), () {
        if (!mounted || _callState != 'ringing') return;
        setState(() {
          _callState = 'active';
        });
        _rippleController.stop();
        _telemetryController.repeat();
        _startTimer();
      });
    });
  }

  void _startTimer() {
    _callDuration = 0;
    _callTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _callDuration++;
      });
    });
  }

  void _hangUp() {
    _callTimer?.cancel();
    _rippleController.stop();
    _telemetryController.stop();
    setState(() {
      _callState = 'idle';
      _callDuration = 0;
      _callingDoctorName = null;
      _callingDoctorDept = null;
    });
  }

  String _formatDuration(int totalSecs) {
    final minutes = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSecs % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_callState != 'idle') {
      return _buildCallOverlay();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Telehealth Video Consult', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connect Instantly',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            SizedBox(height: 6),
            Text(
              'Select an online medical officer to start an encrypted video consultation.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            SizedBox(height: 24),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _doctors.length,
              itemBuilder: (context, index) {
                final doc = _doctors[index];
                final isOnline = doc['status'] == 'Online';
                return Container(
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: GlassCard(
                    radius: 20,
                    borderColor: isOnline ? AppTheme.primaryTeal.withOpacity(0.2) : AppTheme.borderCard,
                    fillColor: isOnline ? AppTheme.primaryTeal.withOpacity(0.02) : Color(0x05FFFFFF),
                    child: Row(
                      children: [
                        // Doctor Avatar Icon
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline ? AppTheme.primaryTeal.withOpacity(0.1) : AppTheme.textSecondary.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: isOnline ? AppTheme.primaryCyan : AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc['name']!,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${doc['dept']} • ${doc['exp']}',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isOnline ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    doc['status']!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isOnline ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: isOnline ? () => _startCallSequence(doc['name']!, doc['dept']!) : null,
                          icon: Icon(Icons.video_call_rounded, color: Colors.white, size: 16),
                          label: Text('CALL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOnline ? AppTheme.primaryTeal : Colors.grey[800],
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
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

  Widget _buildCallOverlay() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Active Call Video Simulator (Draws digital matrix nodes)
            if (_callState == 'active')
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _telemetryController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: TelemetryCanvasPainter(
                        value: _telemetryController.value,
                        doctorName: _callingDoctorName ?? 'Consultant',
                      ),
                    );
                  },
                ),
              ),

            // 2. Connecting & Ringing Animatic Ripples
            if (_callState == 'connecting' || _callState == 'ringing')
              Positioned(
                top: MediaQuery.of(context).size.height * 0.25,
                child: AnimatedBuilder(
                  animation: _rippleController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140 * _rippleController.value,
                          height: 140 * _rippleController.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryTeal.withOpacity(0.2 * (1 - _rippleController.value)),
                            border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.4 * (1 - _rippleController.value)), width: 2),
                          ),
                        ),
                        Container(
                          width: 200 * _rippleController.value,
                          height: 200 * _rippleController.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryTeal.withOpacity(0.1 * (1 - _rippleController.value)),
                            border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2 * (1 - _rippleController.value)), width: 1.5),
                          ),
                        ),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.primaryTeal.withOpacity(0.15),
                          child: Icon(Icons.person, size: 64, color: AppTheme.primaryCyan),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // 3. Header Caller Meta
            Positioned(
              top: 40,
              child: Column(
                children: [
                  Text(
                    _callingDoctorName ?? 'Medical Specialist',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _callState == 'active'
                        ? _formatDuration(_callDuration)
                        : _callState.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      color: _callState == 'active' ? AppTheme.primaryCyan : AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  if (_callState != 'active') ...[
                    SizedBox(height: 6),
                    Text(
                      _callingDoctorDept ?? '',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ]
                ],
              ),
            ),

            // 4. PIP Local Video Stream (Miniature camera mockup)
            if (_callState == 'active')
              Positioned(
                top: 40,
                right: 20,
                child: GlassCard(
                  radius: 16,
                  width: 90,
                  height: 130,
                  padding: EdgeInsets.zero,
                  borderColor: AppTheme.primaryCyan.withOpacity(0.3),
                  fillColor: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam, color: Colors.greenAccent, size: 24),
                        SizedBox(height: 6),
                        Text('Patient (You)', style: TextStyle(color: Colors.white, fontSize: 8)),
                      ],
                    ),
                  ),
                ),
              ),

            // 5. Caller Actions Controller panel
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
            )
          ],
        ),
      ),
    );
  }
}

// Simulated Telemetry overlay painter for doctor side video stream
class TelemetryCanvasPainter extends CustomPainter {
  final double value;
  final String doctorName;

  TelemetryCanvasPainter({required this.value, required this.doctorName});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw animated telemetry graphs/scan lines
    final techPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final centerY = size.height * 0.5;
    final graphPath = Path()..moveTo(0, centerY);

    // Draw vital signs pulse wave
    for (double x = 0; x < size.width; x += 10) {
      double phase = (x / 20) - (value * 2 * 3.1415);
      double y = centerY + 30 * sin(phase);
      // add standard heartbeat pulse spike
      if ((x.toInt() % 160) < 20) {
        y -= 70 * sin((x % 160) / 20 * 3.1415);
      }
      graphPath.lineTo(x, y);
    }
    canvas.drawPath(graphPath, techPaint);

    // 2. Draw animated targets
    final targetPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final ringRadius = 80 + 10 * sin(value * 2 * 3.1415);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), ringRadius, targetPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 10, Paint()..color = Colors.greenAccent.withOpacity(0.5));

    // Simulated scanning sweep line
    final sweepPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.08)
      ..strokeWidth = 2.0;
    double sweepY = size.height * value;
    canvas.drawLine(Offset(0, sweepY), Offset(size.width, sweepY), sweepPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
