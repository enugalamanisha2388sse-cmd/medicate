import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';
import '../auth/role_selection_screen.dart';
import '../patient/user_profile_screen.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final user = provider.currentUser;

    if (user == null) {
      return RoleSelectionScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: DynamicBackground(
        child: SafeArea(
          child: Column(
            children: [
            // Admin Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin Dashboard', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      SizedBox(height: 4),
                      Text(user.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
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
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Tab selectors
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(16)),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.black,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicator: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(12)),
                  tabs: [
                    Tab(child: Text('HOSPITAL VACANCY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9))),
                    Tab(child: Text('SHOP INVENTORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9))),
                    Tab(child: Text('ADMIN PROFILE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9))),
                  ],
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHospitalsVacancyTab(provider),
                  _buildShopInventoryTab(provider),
                  _buildAdminProfileTab(context, provider, user),
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}

  Widget _buildHospitalsVacancyTab(MedicateProvider provider) {
    final hospitals = provider.hospitals;

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: hospitals.length + 1,
      itemBuilder: (context, idx) {
        if (idx == 0) {
          return Container(
            margin: EdgeInsets.only(bottom: 20),
            child: HospitalOccupancyChart(hospitals: hospitals),
          );
        }

        final hospital = hospitals[idx - 1];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: GlassCard(
            radius: 20,
            borderColor: Colors.amber.withOpacity(0.15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 4),
                Text('Contact Number: ${hospital.contact}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BED VACANCY', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                          '${hospital.vacancy} / ${hospital.totalBeds} Beds',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.amber),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: Colors.amber, size: 28),
                          onPressed: () {
                            provider.updateHospitalVacancy(hospital.id, hospital.vacancy - 1);
                          },
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: Colors.amber, size: 28),
                          onPressed: () {
                            provider.updateHospitalVacancy(hospital.id, hospital.vacancy + 1);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShopInventoryTab(MedicateProvider provider) {
    final medicines = provider.medicines;

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: medicines.length,
      itemBuilder: (context, idx) {
        final med = medicines[idx];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: GlassCard(
            radius: 20,
            borderColor: Colors.amber.withOpacity(0.15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        med.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        med.category,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text('Price per unit: ₹${med.price.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STOCK QUANTITY', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                          '${med.stock} units available',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: med.stock < 10 ? Colors.redAccent : Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => provider.restockMedicine(med.id, 10),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text('+10', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => provider.restockMedicine(med.id, 50),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text('+50', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminProfileTab(BuildContext context, MedicateProvider provider, UserAccount user) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.35),
                        blurRadius: 16,
                      )
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: AppTheme.cardColor,
                    child: Icon(Icons.admin_panel_settings_rounded, size: 48, color: Colors.amber),
                  ),
                ),
                SizedBox(height: 16),
                Text(user.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text('System Operations Administrator', style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          SizedBox(height: 32),

          Text('System Status Controls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 12),
          GlassCard(
            radius: 20,
            borderColor: Colors.amber.withOpacity(0.15),
            child: Column(
              children: [
                _buildSystemRow('DATABASE NODE', 'Firebase Simulated/Demo Hybrid'),
                _buildSystemRow('API SERVICE STATUS', 'Online (Latency 14ms)'),
                _buildSystemRow('DRONE ROUTING LOG', 'Active (Simulated rider maps online)'),
                _buildSystemRow('ADMIN CODE ACCESS', 'ADMIN2026 Verified'),
              ],
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen())),
              icon: Icon(Icons.manage_accounts_rounded, color: Colors.black),
              label: Text('EDIT ADMIN PROFILE DETAILS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemRow(String label, String value) {
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
            child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
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
          borderColor: Colors.amber.withOpacity(0.3),
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
                        Icon(Icons.notifications_active_rounded, color: Colors.amber, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'System Notifications',
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
                      child: Text('No system logs.', style: TextStyle(color: AppTheme.textSecondary)),
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
                              Icon(Icons.info_outline_rounded, color: Colors.amber, size: 18),
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

class HospitalOccupancyChart extends StatelessWidget {
  final List<Hospital> hospitals;
  HospitalOccupancyChart({super.key, required this.hospitals});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      borderColor: Colors.amber.withOpacity(0.15),
      fillColor: Colors.amber.withOpacity(0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Text(
                'Occupancy Rate Analytics',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 18),
          ...hospitals.map((h) {
            final occupied = h.totalBeds - h.vacancy;
            final occupiedRate = h.totalBeds > 0 ? occupied / h.totalBeds : 0.0;
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          h.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${(occupiedRate * 100).toInt()}% Occupied',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: occupiedRate > 0.8 ? Colors.redAccent : (occupiedRate > 0.5 ? Colors.orange : Colors.greenAccent),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: occupiedRate,
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        occupiedRate > 0.8 ? Colors.redAccent : (occupiedRate > 0.5 ? Colors.orange : Colors.greenAccent),
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
