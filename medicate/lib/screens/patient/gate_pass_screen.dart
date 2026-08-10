import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/theme.dart';
import '../../core/services/services.dart';

class GatePassScreen extends StatefulWidget {
  final Appointment? appointment;

  GatePassScreen({super.key, this.appointment});

  @override
  State<GatePassScreen> createState() => _GatePassScreenState();
}

class _GatePassScreenState extends State<GatePassScreen> with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;
  late String _passId;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();

    // Generate random pass id
    final rand = Random();
    _passId = 'PASS-${rand.nextInt(90000) + 10000}';
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docName = widget.appointment?.doctorName ?? 'General Visit';
    final dept = widget.appointment?.department ?? 'Outpatient Care';
    final dateStr = widget.appointment != null
        ? '${widget.appointment!.dateTime.day}/${widget.appointment!.dateTime.month}/${widget.appointment!.dateTime.year}'
        : 'Today';
    final timeStr = widget.appointment != null
        ? '${widget.appointment!.dateTime.hour.toString().padLeft(2, '0')}:${widget.appointment!.dateTime.minute.toString().padLeft(2, '0')}'
        : '09:00 AM';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('DIGITAL ACCESS PASS', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            Text(
              'Present this ticket at the clinic entrance gate barcode reader for automated verification check-in.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
            ),
            SizedBox(height: 32),

            // Holographic Access Ticket
            Center(
              child: GlassCard(
                radius: 24,
                borderColor: AppTheme.primaryTeal.withOpacity(0.3),
                fillColor: AppTheme.cardColor.withOpacity(0.4),
                padding: EdgeInsets.zero,
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryTeal.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withOpacity(0.08),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CLINIC ENTRY PASS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13, letterSpacing: 1.2)),
                                SizedBox(height: 4),
                                Text('MEDICATE AUTHENTICATION', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 9)),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryCyan, size: 18),
                            )
                          ],
                        ),
                      ),

                      // Ticket Details
                      Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            _buildTicketRow('PATIENT', widget.appointment?.patientName ?? 'John Patient'),
                            SizedBox(height: 16),
                            _buildTicketRow('CLINICIAN / DEPT', '$docName\n$dept'),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('DATE', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                                    SizedBox(height: 4),
                                    Text(dateStr, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('TIME', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                                    SizedBox(height: 4),
                                    Text(timeStr, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('GATE NO', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                                    SizedBox(height: 4),
                                    Text(widget.appointment != null ? 'GATE-B2 (Cardiology)' : 'GATE-A1 (General)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('ENTRY STATUS', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                                    SizedBox(height: 4),
                                    Text(
                                      widget.appointment?.status == 'Approved' ? 'VERIFIED' : 'PENDING APPROVAL',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: widget.appointment?.status == 'Approved' ? Colors.greenAccent : Colors.orangeAccent,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Dotted Ticket Divider
                      Row(
                        children: [
                          Container(width: 12, height: 24, decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)))),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              child: DottedLinePainter(),
                            ),
                          ),
                          Container(width: 12, height: 24, decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)))),
                        ],
                      ),

                      // Barcode section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 64,
                              width: double.infinity,
                              child: AnimatedBuilder(
                                animation: _sweepController,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: BarcodePainter(_sweepController.value),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              _passId,
                              style: TextStyle(letterSpacing: 8, fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),

            // Print / Save to device mock action
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gate Pass saved to device files (simulated).')),
                  );
                },
                icon: Icon(Icons.download_rounded, color: Colors.white),
                label: Text('SAVE PASS TO STORAGE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketRow(String title, String val) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          Text(
            val,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14, height: 1.3),
          ),
        ],
      ),
    );
  }
}

class DottedLinePainter extends StatelessWidget {
  DottedLinePainter({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, 1),
      painter: _DottedPainter(),
    );
  }
}

class _DottedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.borderCard
      ..strokeWidth = 1.5;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BarcodePainter extends CustomPainter {
  final double value;

  BarcodePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()
      ..color = AppTheme.textPrimary
      ..strokeWidth = 2.0;

    // Draw realistic barcode lines
    final rand = Random(42); // Seeded random for consistent lines
    double x = 0;
    while (x < size.width) {
      final lineW = 1.0 + rand.nextInt(4);
      final spaceW = 2.0 + rand.nextInt(5);
      barPaint.strokeWidth = lineW;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), barPaint);
      x += lineW + spaceW;
    }

    // Glowing laser scanner sweep line
    final scanPaint = Paint()
      ..color = AppTheme.primaryCyan
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final sweepY = size.height * value;
    canvas.drawLine(Offset(0, sweepY), Offset(size.width, sweepY), scanPaint);

    final glowPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.2)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, sweepY), Offset(size.width, sweepY), glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
