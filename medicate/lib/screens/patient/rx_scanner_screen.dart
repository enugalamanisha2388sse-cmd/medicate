import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';

class RxScannerScreen extends StatefulWidget {
  const RxScannerScreen({super.key});

  @override
  State<RxScannerScreen> createState() => _RxScannerScreenState();
}

class _RxScannerScreenState extends State<RxScannerScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ───────────────────────────────────
  late AnimationController _sweepController;
  late AnimationController _pulseController;
  late AnimationController _cornerController;
  late AnimationController _resultController;

  late Animation<double> _sweepAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _cornerAnim;
  late Animation<double> _resultAnim;

  // ── State ───────────────────────────────────────────────────
  bool _isScanning = false;
  bool _scanComplete = false;
  _ScanResult? _result;

  // Simulated prescription text lines revealed progressively
  final List<String> _ocrLines = [
    'Patient: John Patient',
    'DOB: 14 / 03 / 1985',
    '',
    'Rx:',
    '  Amoxicillin 500 mg',
    '  Sig: 1 cap TID x 7 days',
    '',
    '  Montelukast 10 mg',
    '  Sig: 1 tab QD (night)',
    '',
    '  Amlodipine 5 mg',
    '  Sig: 1 tab QD (morning)',
    '',
    'Refills: 0',
    'Dr. Sarah Connor  MD-998877',
    'Issued: 09 / 08 / 2026',
  ];
  List<String> _revealedLines = [];

  // ── Lifecycle ───────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _cornerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _sweepAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sweepController, curve: Curves.easeInOut),
    );

    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _cornerAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cornerController, curve: Curves.elasticOut),
    );

    _resultAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeOutCubic),
    );

    _cornerController.forward();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _pulseController.dispose();
    _cornerController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  // ── Scan logic ──────────────────────────────────────────────
  Future<void> _startScan() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _scanComplete = false;
      _result = null;
      _revealedLines = [];
    });

    _sweepController.repeat();

    // Reveal OCR lines progressively while scanning
    for (int i = 0; i < _ocrLines.length; i++) {
      await Future.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;
      setState(() {
        _revealedLines = _ocrLines.sublist(0, i + 1);
      });
    }

    await Future.delayed(const Duration(milliseconds: 400));
    _sweepController.stop();
    _sweepController.reset();

    // Call service mock
    if (!mounted) return;
    final provider = Provider.of<MedicateProvider>(context, listen: false);
    await provider.runOcrPrescriptionScan('prescription_scan.jpg');

    final medicines = [
      _ScannedMed(name: 'Amoxicillin 500mg', dosage: '1 cap TID', duration: '7 days'),
      _ScannedMed(name: 'Montelukast 10mg', dosage: '1 tab QD (night)', duration: 'Ongoing'),
      _ScannedMed(name: 'Amlodipine 5mg', dosage: '1 tab QD (morning)', duration: 'Ongoing'),
    ];

    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _scanComplete = true;
      _result = _ScanResult(
        doctor: 'Dr. Sarah Connor',
        licenseNo: 'MD-998877',
        date: '09/08/2026',
        medicines: medicines,
      );
    });

    _resultController.forward(from: 0);
  }

  void _reset() {
    setState(() {
      _isScanning = false;
      _scanComplete = false;
      _result = null;
      _revealedLines = [];
    });
    _resultController.reset();
    _cornerController.forward(from: 0);
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildScanViewport(),
                  const SizedBox(height: 28),
                  if (!_scanComplete) _buildScanButton(),
                  if (_scanComplete && _result != null) ...[
                    _buildResultsCard(),
                    const SizedBox(height: 16),
                    _buildScanAgainButton(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0369A1), Color(0xFF0891B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.document_scanner_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rx Scanner',
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          Text('OCR Prescription Reader',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.75))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  // ── Scan Viewport ────────────────────────────────────────────
  Widget _buildScanViewport() {
    return AnimatedBuilder(
      animation: _cornerAnim,
      builder: (context, _) {
        return Transform.scale(
          scale: 0.9 + 0.1 * _cornerAnim.value,
          child: Opacity(
            opacity: _cornerAnim.value.clamp(0.0, 1.0),
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF0C1628),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0891B2).withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Background grid pattern
                    CustomPaint(
                      painter: _GridPainter(),
                      size: const Size(double.infinity, 300),
                    ),
                    // OCR text reveal
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _revealedLines.map((line) {
                              final isHeader = line.trim().startsWith('Rx:') ||
                                  line.trim().startsWith('Patient:') ||
                                  line.trim().startsWith('Dr.');
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 1.5),
                                child: Text(
                                  line.isEmpty ? ' ' : line,
                                  style: GoogleFonts.sourceCodePro(
                                    fontSize: isHeader ? 11.5 : 11,
                                    color: isHeader
                                        ? const Color(0xFF38BDF8)
                                        : Colors.white.withOpacity(0.78),
                                    fontWeight: isHeader
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    // Sweep line
                    if (_isScanning)
                      AnimatedBuilder(
                        animation: _sweepAnim,
                        builder: (_, __) => Positioned(
                          top: _sweepAnim.value * 260 + 20,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF0EA5E9).withOpacity(0.9),
                                  const Color(0xFF38BDF8),
                                  const Color(0xFF0EA5E9).withOpacity(0.9),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withOpacity(0.8),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Corner brackets
                    ..._buildCornerBrackets(),
                    // Center idle message
                    if (!_isScanning && !_scanComplete)
                      Center(
                        child: AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (_, __) => Opacity(
                            opacity: _pulseAnim.value,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.document_scanner_rounded,
                                    color: const Color(0xFF38BDF8).withOpacity(0.6),
                                    size: 48),
                                const SizedBox(height: 8),
                                Text('Tap Scan to read prescription',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.4),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Done overlay
                    if (_scanComplete)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.success.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.success, width: 2),
                              ),
                              child: Icon(Icons.check_rounded,
                                  color: AppTheme.success, size: 26),
                            ),
                            const SizedBox(height: 8),
                            Text('Scan complete',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppTheme.success,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCornerBrackets() {
    const color = Color(0xFF0EA5E9);
    const size = 24.0;
    const thick = 3.0;
    const r = 6.0;
    return [
      Positioned(
        top: 12,
        left: 12,
        child: _CornerBracket(color: color, size: size, thick: thick, radius: r,
            flip: false, vertical: false),
      ),
      Positioned(
        top: 12,
        right: 12,
        child: _CornerBracket(color: color, size: size, thick: thick, radius: r,
            flip: true, vertical: false),
      ),
      Positioned(
        bottom: 12,
        left: 12,
        child: _CornerBracket(color: color, size: size, thick: thick, radius: r,
            flip: false, vertical: true),
      ),
      Positioned(
        bottom: 12,
        right: 12,
        child: _CornerBracket(color: color, size: size, thick: thick, radius: r,
            flip: true, vertical: true),
      ),
    ];
  }

  // ── Scan Button ──────────────────────────────────────────────
  Widget _buildScanButton() {
    return GestureDetector(
      onTap: _isScanning ? null : _startScan,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, __) {
          return Transform.scale(
            scale: _isScanning ? 0.97 + 0.03 * _pulseAnim.value : 1.0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0369A1), Color(0xFF0891B2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0891B2).withOpacity(_isScanning ? 0.5 : 0.3),
                    blurRadius: _isScanning ? 20 : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isScanning)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  else
                    const Icon(Icons.document_scanner_rounded,
                        color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    _isScanning ? 'Scanning...' : 'Scan Prescription',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScanAgainButton() {
    return GestureDetector(
      onTap: _reset,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF0891B2), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh_rounded, color: Color(0xFF0891B2), size: 20),
            const SizedBox(width: 8),
            Text('Scan Another',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0891B2),
                )),
          ],
        ),
      ),
    );
  }

  // ── Results Card ─────────────────────────────────────────────
  Widget _buildResultsCard() {
    final r = _result!;
    return AnimatedBuilder(
      animation: _resultAnim,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, 32 * (1 - _resultAnim.value)),
          child: Opacity(
            opacity: _resultAnim.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prescription header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0369A1), Color(0xFF0891B2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0891B2).withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.verified_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Prescription Verified',
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text('${r.doctor}  ·  ${r.licenseNo}',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8))),
                            Text('Issued: ${r.date}',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.65))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Medicines Detected',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 10),
                ...r.medicines.asMap().entries.map((e) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 350 + e.key * 120),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                          offset: Offset(0, 20 * (1 - v)), child: child),
                    ),
                    child: _MedCard(med: e.value),
                  );
                }),
                const SizedBox(height: 16),
                _buildAddRemindersCta(r.medicines),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddRemindersCta(List<_ScannedMed> meds) {
    return GestureDetector(
      onTap: () {
        final provider = Provider.of<MedicateProvider>(context, listen: false);
        for (final med in meds) {
          final times = ['08:00 AM', '02:00 PM', '09:00 PM'];
          final time = times[Random().nextInt(times.length)];
          provider.addMedicineReminder(med.name, med.dosage, time);
        }
        provider.addNotification(
            'SUCCESS: Added ${meds.length} medicine reminder(s) from Rx scan.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            '${meds.length} reminders added from your prescription!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: AppTheme.successGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.success.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alarm_add_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text('Add All as Reminders',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Data models ──────────────────────────────────────────────
class _ScannedMed {
  final String name;
  final String dosage;
  final String duration;
  const _ScannedMed({required this.name, required this.dosage, required this.duration});
}

class _ScanResult {
  final String doctor;
  final String licenseNo;
  final String date;
  final List<_ScannedMed> medicines;
  const _ScanResult({
    required this.doctor,
    required this.licenseNo,
    required this.date,
    required this.medicines,
  });
}

// ── Med card widget ──────────────────────────────────────────
class _MedCard extends StatelessWidget {
  final _ScannedMed med;
  const _MedCard({required this.med});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0891B2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication_rounded,
                color: Color(0xFF0891B2), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                Text(med.dosage,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.success.withOpacity(0.3)),
            ),
            child: Text(med.duration,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.success)),
          ),
        ],
      ),
    );
  }
}

// ── Corner bracket widget ────────────────────────────────────
class _CornerBracket extends StatelessWidget {
  final Color color;
  final double size;
  final double thick;
  final double radius;
  final bool flip;
  final bool vertical;

  const _CornerBracket({
    required this.color,
    required this.size,
    required this.thick,
    required this.radius,
    required this.flip,
    required this.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      scaleY: vertical ? -1 : 1,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _BracketPainter(color: color, thick: thick, radius: radius),
        ),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Color color;
  final double thick;
  final double radius;

  _BracketPainter({required this.color, required this.thick, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(radius, 0)
      ..quadraticBezierTo(0, 0, 0, radius)
      ..lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Background grid painter ──────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
