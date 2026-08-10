import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';


class BluetoothVitalsScreen extends StatefulWidget {
  BluetoothVitalsScreen({super.key});

  @override
  State<BluetoothVitalsScreen> createState() => _BluetoothVitalsScreenState();
}

class _BluetoothVitalsScreenState extends State<BluetoothVitalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Two main tabs: 1) Device Connection, 2) Live Vitals Dashboard
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);

    // If connected, automatically switch or allow switching tabs.
    // If not connected, we prompt pairing first but let them browse.
    return MobileViewFrame(
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Smart Sensor Hub',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primaryCyan,
            dividerColor: AppTheme.borderCard,
            labelColor: AppTheme.primaryCyan,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: [
              Tab(icon: Icon(Icons.bluetooth_searching_rounded), text: 'DEVICE PAIRING'),
              Tab(icon: Icon(Icons.health_and_safety_rounded), text: 'LIVE TELEMETRY'),
            ],
          ),
        ),
        body: DynamicBackground(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPairingTab(context, provider),
              _buildTelemetryTab(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DEVICE PAIRING TAB
  // ==========================================
  Widget _buildPairingTab(BuildContext context, MedicateProvider provider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wearable Accessories',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'Connect your Bluetooth watch or smart ring to stream real-time blood glucose and ECG levels directly.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
          ),
          SizedBox(height: 20),

          // Active Device Card if connected
          if (provider.btStatus == BluetoothConnectionStatus.connected && provider.connectedDevice != null) ...[
            _buildConnectedDeviceCard(context, provider),
          ] else if (provider.btStatus == BluetoothConnectionStatus.connecting) ...[
            _buildConnectingCard(provider),
          ] else if (provider.btStatus == BluetoothConnectionStatus.scanning) ...[
            Center(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  RadarWidget(),
                  SizedBox(height: 24),
                  Text(
                    'Searching for Nearby Accessories...',
                    style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Ensure your Watch or Ring is in pairing mode',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildDisconnectedPanel(context, provider),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectedDeviceCard(BuildContext context, MedicateProvider provider) {
    final dev = provider.connectedDevice!;
    final isWatch = dev.type == BluetoothDeviceType.watch;

    return FadeInSlide(
      child: GlassCard(
        radius: 24,
        borderColor: AppTheme.primaryCyan.withOpacity(0.3),
        fillColor: AppTheme.primaryCyan.withOpacity(0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryCyan.withOpacity(0.12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryCyan.withOpacity(0.2),
                        blurRadius: 8,
                      )
                    ]
                  ),
                  child: Icon(
                    isWatch ? Icons.watch_rounded : Icons.trip_origin_rounded,
                    color: AppTheme.primaryCyan,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dev.name,
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Active Connection',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Divider(color: AppTheme.borderCard, height: 1),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildConnectedStat(Icons.battery_charging_full_rounded, '${dev.batteryLevel}%', 'Battery'),
                _buildConnectedStat(Icons.signal_cellular_alt_rounded, '${dev.signalStrength} dBm', 'Signal (RSSI)'),
                _buildConnectedStat(Icons.sensors_rounded, 'Streaming', 'Sensor Stream'),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _tabController.animateTo(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryCyan,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('OPEN TELEMETRY DASHBOARD', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => provider.disconnectDevice(),
                icon: Icon(Icons.bluetooth_disabled_rounded, size: 16, color: Colors.redAccent),
                label: Text('DISCONNECT DEVICE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.redAccent, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectingCard(MedicateProvider provider) {
    return GlassCard(
      radius: 20,
      borderColor: AppTheme.primaryIndigo.withOpacity(0.3),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: AppTheme.primaryIndigo,
                  strokeWidth: 3.5,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Establishing Secure Link...',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Syncing ECG & Glucose protocols',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisconnectedPanel(BuildContext context, MedicateProvider provider) {
    return Column(
      children: [
        if (provider.discoveredDevices.isEmpty) ...[
          SizedBox(height: 20),
          GlassCard(
            radius: 20,
            borderColor: AppTheme.borderCard,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.bluetooth_disabled_rounded, color: AppTheme.textSecondary.withOpacity(0.5), size: 48),
                    SizedBox(height: 16),
                    Text(
                      'No Connected Accessories',
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Scan to find your smart watch or ring.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => provider.startScanning(),
                      icon: Icon(Icons.search_rounded, color: Colors.white),
                      label: Text('SCAN FOR DEVICES', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Discovered Accessories', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: () => provider.startScanning(),
                icon: Icon(Icons.refresh_rounded, size: 14, color: AppTheme.primaryCyan),
                label: Text('RESCAN', style: TextStyle(fontSize: 11, color: AppTheme.primaryCyan, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: provider.discoveredDevices.length,
            itemBuilder: (context, idx) {
              final dev = provider.discoveredDevices[idx];
              final isWatch = dev.type == BluetoothDeviceType.watch;
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  radius: 16,
                  borderColor: AppTheme.borderCard,
                  padding: EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.04),
                        ),
                        child: Icon(
                          isWatch ? Icons.watch_rounded : Icons.trip_origin_rounded,
                          color: isWatch ? AppTheme.primaryCyan : AppTheme.primaryPurple,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dev.name, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                            SizedBox(height: 4),
                            Text(
                              'Signal strength: ${dev.signalStrength} dBm • Battery: ${dev.batteryLevel}%',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => provider.connectDevice(dev),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.08),
                          foregroundColor: AppTheme.textPrimary,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: AppTheme.borderCard),
                          ),
                        ),
                        child: Text('PAIR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ]
      ],
    );
  }

  Widget _buildConnectedStat(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 18),
        SizedBox(height: 6),
        Text(val, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
      ],
    );
  }

  // ==========================================
  // LIVE TELEMETRY TAB
  // ==========================================
  Widget _buildTelemetryTab(BuildContext context, MedicateProvider provider) {
    if (provider.btStatus != BluetoothConnectionStatus.connected) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bluetooth_disabled_rounded, size: 54, color: AppTheme.textSecondary.withOpacity(0.4)),
              SizedBox(height: 20),
              Text(
                'No Wearable Connection',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Connect a Smart Watch or Ring first under the Device Pairing tab to enable live telemetry.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('GO TO PAIRING', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final dev = provider.connectedDevice!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Telemetry status banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.2), width: 1.2),
            ),
            child: Row(
              children: [
                Icon(Icons.bluetooth_connected_rounded, color: Colors.greenAccent, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Streaming from: ${dev.name}',
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                Text(
                  'Batt: ${dev.batteryLevel}%',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          SizedBox(height: 20),

          // ECG Telemetry Node
          _buildECGCard(provider),
          SizedBox(height: 20),

          // Glucose Vitals Node
          _buildGlucoseCard(provider),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildECGCard(MedicateProvider provider) {
    return GlassCard(
      radius: 24,
      borderColor: AppTheme.primaryCyan.withOpacity(0.2),
      fillColor: Colors.black.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.monitor_heart_rounded, color: AppTheme.primaryCyan, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'ELECTROCARDIOGRAM (ECG)',
                    style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                  ),
                ],
              ),
              Text(
                'LIVE SENSOR',
                style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Graph Canvas
          SizedBox(
            height: 100,
            width: double.infinity,
            child: LiveECGCanvas(bpm: provider.bpmValue),
          ),
          SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HEART RATE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${provider.bpmValue}',
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 32),
                      ),
                      SizedBox(width: 4),
                      Text('bpm', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('DIAGNOSIS', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.25)),
                    ),
                    child: Text(
                      'Normal Sinus',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: AppTheme.borderCard, height: 1),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Heart Rate Variability (HRV)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              Text(
                '${60 + (provider.bpmValue % 10)} ms',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlucoseCard(MedicateProvider provider) {
    final double gVal = provider.glucoseValue;
    String status = 'Normal';
    Color statusColor = Colors.greenAccent;
    if (gVal < 70.0) {
      status = 'Low (Hypoglycemia)';
      statusColor = Colors.orangeAccent;
    } else if (gVal > 125.0) {
      status = 'High (Hyperglycemia)';
      statusColor = Colors.redAccent;
    } else if (gVal >= 100.0) {
      status = 'Elevated (Pre-diabetic)';
      statusColor = Colors.amberAccent;
    }

    // Trend direction check from history
    IconData trendIcon = Icons.trending_flat_rounded;
    Color trendColor = AppTheme.textSecondary;
    if (provider.glucoseHistory.length >= 2) {
      final prevVal = provider.glucoseHistory[provider.glucoseHistory.length - 2];
      if (gVal > prevVal + 0.3) {
        trendIcon = Icons.trending_up_rounded;
        trendColor = Colors.redAccent;
      } else if (gVal < prevVal - 0.3) {
        trendIcon = Icons.trending_down_rounded;
        trendColor = AppTheme.primaryCyan;
      }
    }

    return GlassCard(
      radius: 24,
      borderColor: AppTheme.primaryPurple.withOpacity(0.25),
      fillColor: Colors.black.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.opacity_rounded, color: AppTheme.primaryPurple, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'BLOOD GLUCOSE MONITOR',
                    style: TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                  ),
                ],
              ),
              Text(
                'REAL-TIME',
                style: TextStyle(color: AppTheme.primaryPurple, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ],
          ),
          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CURRENT LEVEL', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        gVal.toStringAsFixed(1),
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 36),
                      ),
                      SizedBox(width: 6),
                      Text('mg/dL', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(trendIcon, color: trendColor, size: 28),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.25)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),

          // Glucose Trend Line Graph
          Text('GLUCOSE TREND (LAST 15 SEC)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          SizedBox(height: 10),
          SizedBox(
            height: 90,
            width: double.infinity,
            child: GlucoseTrendCanvas(history: provider.glucoseHistory),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Measurement Interval', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              Text('Continuous (Every 2s)', style: TextStyle(color: AppTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// RADAR RADIAL SCANNING EFFECT
// ==========================================
class RadarWidget extends StatefulWidget {
  RadarWidget({super.key});

  @override
  State<RadarWidget> createState() => _RadarWidgetState();
}

class _RadarWidgetState extends State<RadarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(180, 180),
          painter: RadarPainter(_controller.value),
        );
      },
    );
  }
}

class RadarPainter extends CustomPainter {
  final double sweepProgress;
  RadarPainter(this.sweepProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Grid Painter
    final gridPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw concentric rings
    canvas.drawCircle(center, maxRadius * 0.3, gridPaint);
    canvas.drawCircle(center, maxRadius * 0.6, gridPaint);
    canvas.drawCircle(center, maxRadius * 0.9, gridPaint);

    // Crosslines
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), gridPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), gridPaint);

    // Sweeping line painter
    final double angle = sweepProgress * 2 * pi;
    final sweepPaint = Paint()
      ..color = AppTheme.primaryCyan
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final lineEnd = Offset(
      center.dx + maxRadius * 0.9 * cos(angle),
      center.dy + maxRadius * 0.9 * sin(angle),
    );
    canvas.drawLine(center, lineEnd, sweepPaint);

    // Sweeping fade gradient sector
    final sweepRect = Rect.fromCircle(center: center, radius: maxRadius * 0.9);
    final gradient = SweepGradient(
      center: Alignment.center,
      startAngle: angle - 0.6,
      endAngle: angle,
      colors: [
        AppTheme.primaryCyan.withOpacity(0.0),
        AppTheme.primaryCyan.withOpacity(0.25),
      ],
      stops: [0.0, 1.0],
    );
    final sectorPaint = Paint()
      ..shader = gradient.createShader(sweepRect)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      sweepRect,
      angle - 0.6,
      0.6,
      true,
      sectorPaint,
    );

    // Pulsing core dot
    final corePaint = Paint()
      ..color = AppTheme.primaryCyan
      ..style = PaintingStyle.fill;
    final outerRingPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.35 - (sweepProgress % 0.5) * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, 5.0, corePaint);
    canvas.drawCircle(center, 5.0 + 30.0 * (sweepProgress % 0.5), outerRingPaint);
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) => oldDelegate.sweepProgress != sweepProgress;
}

// ==========================================
// GLUCOSE TREND LINE GRAPH CANVAS
// ==========================================
class GlucoseTrendCanvas extends StatelessWidget {
  final List<double> history;
  GlucoseTrendCanvas({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: GlucoseTrendPainter(history),
    );
  }
}

class GlucoseTrendPainter extends CustomPainter {
  final List<double> history;
  GlucoseTrendPainter(this.history);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.8;

    // Draw background grid lines
    final double stepY = size.height / 3;
    for (int i = 0; i <= 3; i++) {
      canvas.drawLine(Offset(0, i * stepY), Offset(size.width, i * stepY), gridPaint);
    }
    final double stepX = size.width / 5;
    for (int i = 0; i <= 5; i++) {
      canvas.drawLine(Offset(i * stepX, 0), Offset(i * stepX, size.height), gridPaint);
    }

    // Determine min & max values for scaling
    double minVal = history.reduce(min);
    double maxVal = history.reduce(max);
    
    // Safety margin to prevent divide by zero and give top/bottom space
    if (maxVal - minVal < 4.0) {
      minVal -= 3.0;
      maxVal += 3.0;
    } else {
      minVal -= 1.0;
      maxVal += 1.0;
    }

    final double range = maxVal - minVal;
    final int dataCount = history.length;
    final double xIncrement = size.width / (dataCount > 1 ? dataCount - 1 : 1);

    final linePath = Path();
    final fillPath = Path();

    // Map history to points
    final List<Offset> points = [];
    for (int i = 0; i < dataCount; i++) {
      final double x = i * xIncrement;
      // Invert Y because canvas origin (0,0) is top-left
      final double y = size.height - ((history[i] - minVal) / range) * size.height;
      points.add(Offset(x, y));
    }

    linePath.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, size.height);
    fillPath.lineTo(points.first.dx, points.first.dy);

    // Build cubic bezier curved line path
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlX1 = p1.dx + (p2.dx - p1.dx) / 2;
      final controlY1 = p1.dy;
      final controlX2 = p1.dx + (p2.dx - p1.dx) / 2;
      final controlY2 = p2.dy;

      linePath.cubicTo(controlX1, controlY1, controlX2, controlY2, p2.dx, p2.dy);
      fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, p2.dx, p2.dy);
    }

    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    // Area fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.primaryPurple.withOpacity(0.25),
          AppTheme.primaryPurple.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Line Paint with glowing properties
    final linePaint = Paint()
      ..color = AppTheme.primaryPurple
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = AppTheme.primaryPurple.withOpacity(0.3)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, shadowPaint);
    canvas.drawPath(linePath, linePaint);

    // Draw glowing node dots
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotRingPaint = Paint()
      ..color = AppTheme.primaryPurple
      ..style = PaintingStyle.fill;

    // Draw only the last node as highlighted glowing dot
    if (points.isNotEmpty) {
      final lastPoint = points.last;
      canvas.drawCircle(lastPoint, 6, dotRingPaint);
      canvas.drawCircle(lastPoint, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GlucoseTrendPainter oldDelegate) => oldDelegate.history != history;
}

// ==========================================
// LIVE COMPONENT ECG WAVEFORM
// ==========================================
class LiveECGCanvas extends StatefulWidget {
  final int bpm;
  LiveECGCanvas({super.key, required this.bpm});

  @override
  State<LiveECGCanvas> createState() => _LiveECGCanvasState();
}

class _LiveECGCanvasState extends State<LiveECGCanvas> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Frequency of wave animation adapts based on BPM
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant LiveECGCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Dynamically adjust speed slightly according to pulse
    final double speedMultiplier = widget.bpm / 75.0;
    _controller.duration = Duration(milliseconds: (2000 / speedMultiplier).round());
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ECGPainter(_controller.value),
        );
      },
    );
  }
}
// ==========================================
// ECG CUSTOM PAINTER
// ==========================================
class ECGPainter extends CustomPainter {
  final double progress;
  ECGPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryPurple
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = AppTheme.primaryPurple.withOpacity(0.3)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double midY = h / 2;

    // One ECG cycle is defined in normalised x [0..1]
    // We scroll it by `progress` so the waveform sweeps from right to left.
    final int cycles = 2;
    final double cycleWidth = w / cycles;

    bool started = false;
    for (int c = 0; c < cycles; c++) {
      final double base = c * cycleWidth - progress * cycleWidth;

      // Segment breakpoints (as fraction of cycleWidth)
      final List<List<double>> pts = [
        [0.00, midY],
        [0.10, midY],
        // P wave
        [0.15, midY - h * 0.08],
        [0.20, midY],
        [0.25, midY],
        // Q dip
        [0.30, midY + h * 0.05],
        // R spike
        [0.35, midY - h * 0.45],
        // S dip
        [0.40, midY + h * 0.10],
        [0.45, midY],
        // T wave
        [0.55, midY - h * 0.15],
        [0.65, midY],
        [1.00, midY],
      ];

      for (int i = 0; i < pts.length; i++) {
        final double x = base + pts[i][0] * cycleWidth;
        final double y = pts[i][1];
        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }
      }
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ECGPainter oldDelegate) => oldDelegate.progress != progress;
}
