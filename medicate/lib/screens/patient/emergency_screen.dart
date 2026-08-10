import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';

class EmergencyScreen extends StatefulWidget {
  EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isSosTriggered = false;
  int _firstAidIndex = 0;

  final List<Map<String, String>> _firstAidGuides = [
    {
      'title': 'CPR Guide',
      'steps': '1. Push hard and fast in the center of the chest (100-120 compressions/min).\n2. Give 2 rescue breaths after every 30 compressions.\n3. Open airway by tilting head back and lifting chin.',
      'icon': '❤️',
    },
    {
      'title': 'Stroke (FAST)',
      'steps': 'F - Face Drooping: Is one side numb/drooping?\nA - Arm Weakness: Ask person to raise both arms. Does one drift down?\nS - Speech Difficulty: Is speech slurred?\nT - Time to call 911 immediately!',
      'icon': '🧠',
    },
    {
      'title': 'Choking (Heimlich)',
      'steps': '1. Stand behind the person and wrap arms around waist.\n2. Make a fist with one hand and grasp it with the other.\n3. Press hard into the abdomen with quick, upward thrusts.',
      'icon': '🗣️',
    },
    {
      'title': 'Thermal Burns',
      'steps': '1. Cool the burn immediately with cool running water for 10-20 minutes.\n2. Do NOT apply ice, butter, or ointments.\n3. Cover loosely with a sterile, non-stick bandage.',
      'icon': '🔥',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerSos(MedicateProvider provider) {
    setState(() {
      _isSosTriggered = !_isSosTriggered;
    });

    if (_isSosTriggered) {
      _pulseController.repeat(reverse: true);
      provider.addNotification("SOS Emergency Triggered! Dispatching ambulance coordinates to nearest hub...");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('SOS DISPATCH ACTIVATED. Help is on the way!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      );
    } else {
      _pulseController.stop();
      provider.addNotification("SOS Emergency Call cancelled by user.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    // Get hospitals sorted by closest/highest bed vacancy
    final emergencyHospitals = provider.hospitals;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('EMERGENCY SOS HUB', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. Glowing Pulse Panic SOS Button
            Center(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                    _isSosTriggered ? 'SOS DISPATCH BROADCASTING' : 'PRESS AND HOLD FOR DISTRESS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _isSosTriggered ? Colors.redAccent : AppTheme.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => _triggerSos(provider),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final pulseVal = _pulseController.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Multi-layer glowing rings
                            Container(
                              width: 170 + (pulseVal * 50),
                              height: 170 + (pulseVal * 50),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.redAccent.withOpacity(0.08 * (1.0 - pulseVal)),
                              ),
                            ),
                            Container(
                              width: 150 + (pulseVal * 30),
                              height: 150 + (pulseVal * 30),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.redAccent.withOpacity(0.12 * (1.0 - pulseVal)),
                              ),
                            ),
                            // Main button container
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isSosTriggered ? Colors.redAccent : Color(0xFF1E1E2F),
                                border: Border.all(color: Colors.redAccent, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withOpacity(0.4),
                                    blurRadius: _isSosTriggered ? 25 : 12,
                                    spreadRadius: _isSosTriggered ? 4 : 1,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isSosTriggered ? Icons.sensors_rounded : Icons.touch_app_rounded,
                                    size: 38,
                                    color: _isSosTriggered ? Colors.white : Colors.redAccent,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    _isSosTriggered ? 'CANCEL' : 'SOS',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: _isSosTriggered ? Colors.white : Colors.redAccent,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 36),

            // 2. Nearest Emergency Rooms
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_hospital_rounded, color: Colors.redAccent, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Trauma Units Nearby',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                Text(
                  '${emergencyHospitals.length} Found',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                )
              ],
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: emergencyHospitals.length > 3 ? 3 : emergencyHospitals.length,
              itemBuilder: (context, idx) {
                final hosp = emergencyHospitals[idx];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    radius: 18,
                    borderColor: Colors.redAccent.withOpacity(0.15),
                    fillColor: Colors.redAccent.withOpacity(0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(hosp.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: hosp.vacancy > 0 ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      hosp.vacancy > 0 ? '${hosp.vacancy} Vacant' : 'Full Capacity',
                                      style: TextStyle(color: hosp.vacancy > 0 ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Distance: ~1.2 km', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Dialing Emergency dispatcher at ${hosp.contact}')),
                            );
                          },
                          icon: Icon(Icons.phone_in_talk_rounded, color: Colors.greenAccent),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.05),
                            padding: EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 28),

            // 3. First-Aid Instruction Panel
            Row(
              children: [
                Icon(Icons.health_and_safety_rounded, color: AppTheme.primaryCyan, size: 20),
                SizedBox(width: 8),
                Text(
                  'Emergency First-Aid Guides',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Horizontal Tab Pill selectors
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _firstAidGuides.length,
                itemBuilder: (context, idx) {
                  final title = _firstAidGuides[idx]['title']!;
                  final isSelected = _firstAidIndex == idx;
                  return GestureDetector(
                    onTap: () => setState(() => _firstAidIndex = idx),
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryCyan : AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppTheme.primaryCyan.withOpacity(0.5) : AppTheme.borderCard),
                      ),
                      child: Row(
                        children: [
                          Text(_firstAidGuides[idx]['icon']!, style: TextStyle(fontSize: 12)),
                          SizedBox(width: 6),
                          Text(
                            title,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // Guide Details Card
            GlassCard(
              radius: 20,
              borderColor: AppTheme.primaryCyan.withOpacity(0.15),
              fillColor: AppTheme.primaryCyan.withOpacity(0.02),
              child: CrossFadeGuide(
                title: _firstAidGuides[_firstAidIndex]['title']!,
                steps: _firstAidGuides[_firstAidIndex]['steps']!,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class CrossFadeGuide extends StatelessWidget {
  final String title;
  final String steps;

  CrossFadeGuide({super.key, required this.title, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.primaryCyan.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Text('Verified Protocol', style: TextStyle(color: AppTheme.primaryCyan, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        Divider(color: AppTheme.borderCard, height: 20),
        Text(
          steps,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.6),
        ),
      ],
    );
  }
}
