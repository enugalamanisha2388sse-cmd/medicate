import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';

class DeliveryTrackerScreen extends StatelessWidget {
  DeliveryTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final status = provider.deliveryStatus;
    final progress = provider.deliveryProgress;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Express Delivery Tracker', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 1. Moving Drone Route Map Simulator
              Expanded(
                flex: 3,
                child: GlassCard(
                  radius: 24,
                  borderColor: AppTheme.primaryCyan.withOpacity(0.2),
                  fillColor: Colors.black.withOpacity(0.4),
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // Map Grid and Dash line Painter
                        CustomPaint(
                          size: Size.infinite,
                          painter: RouteTrackerPainter(progress: progress),
                        ),

                        // Dispatcher node label
                        Positioned(
                          top: 35,
                          left: 35,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('APEX HUB', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                              Icon(Icons.storefront_rounded, color: Colors.amber, size: 20),
                            ],
                          ),
                        ),

                        // Patient Home node label
                        Positioned(
                          bottom: 35,
                          right: 35,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('HOME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan)),
                              Icon(Icons.home_rounded, color: AppTheme.primaryCyan, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // 2. Real-time Status Card
              Expanded(
                flex: 2,
                child: GlassCard(
                  radius: 24,
                  borderColor: AppTheme.borderCard,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: status == 'Delivered' ? Colors.greenAccent : AppTheme.primaryCyan,
                          letterSpacing: 2.0,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Progress bar indicator
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            status == 'Delivered' ? Colors.greenAccent : AppTheme.primaryCyan,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        status == 'Delivered'
                            ? 'Your medicine packages have been dropped off.'
                            : 'Estimated Delivery: ${(10 - (progress * 10)).toInt() + 1} minutes',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      SizedBox(height: 24),
                      if (status == 'Delivered')
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('DISMISS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryCyan),
                            ),
                            SizedBox(width: 10),
                            Text('Tracking satellite feed...', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          ],
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RouteTrackerPainter extends CustomPainter {
  final double progress;
  RouteTrackerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Grid
    final gridPaint = Paint()
      ..color = AppTheme.borderCard.withOpacity(0.2)
      ..strokeWidth = 0.8;
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += 20) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    // 2. Dash line track path
    final trackPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.15)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final start = Offset(50, 50);
    final end = Offset(size.width - 50, size.height - 50);

    canvas.drawLine(start, end, trackPaint);

    // 3. Drone current animated coordinate
    final currentPos = Offset(
      start.dx + (end.dx - start.dx) * progress,
      start.dy + (end.dy - start.dy) * progress,
    );

    // Pulse ripple for drone
    final pulsePaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.3 * (1 - (progress % 0.2) / 0.2))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(currentPos, 20 * ((progress % 0.2) / 0.2), pulsePaint);

    // Core drone marker
    final markerPaint = Paint()
      ..color = AppTheme.primaryCyan
      ..style = PaintingStyle.fill;
    canvas.drawCircle(currentPos, 6, markerPaint);
    
    // Draw crosshair corners around drone
    final crossPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromCenter(center: currentPos, width: 14, height: 14), crossPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
