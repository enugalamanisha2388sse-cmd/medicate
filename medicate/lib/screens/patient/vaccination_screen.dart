import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';

class VaccinationScreen extends StatefulWidget {
  VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  DateTime _bookingDate = DateTime.now().add(Duration(days: 2));
  TimeOfDay _bookingTime = TimeOfDay(hour: 10, minute: 0);
  String _selectedLocation = 'City Central General Hospital';

  final List<String> _locations = [
    'City Central General Hospital',
    'St. Jude Cardiac Institute',
    'Apex Multi-Specialty Care',
    'Metro Children Clinic',
  ];

  void _showBookingDialog(BuildContext context, MedicateProvider provider, VaccineRecord vaccine) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: AppTheme.primaryTeal.withOpacity(0.3)),
            ),
            title: Row(
              children: [
                Icon(Icons.vaccines_rounded, color: AppTheme.primaryCyan),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Book: ${vaccine.name}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Administration Site', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderCard)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLocation,
                        dropdownColor: AppTheme.cardColor,
                        isExpanded: true,
                        style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => _selectedLocation = val);
                          }
                        },
                        items: _locations.map((loc) {
                          return DropdownMenuItem<String>(value: loc, child: Text(loc, overflow: TextOverflow.ellipsis));
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('APPOINTMENT DATE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                          SizedBox(height: 4),
                          Text('${_bookingDate.day}/${_bookingDate.month}/${_bookingDate.year}', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _bookingDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 90)),
                          );
                          if (picked != null) {
                            setModalState(() => _bookingDate = picked);
                          }
                        },
                        style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.primaryCyan)),
                        child: Text('PICK DATE', style: TextStyle(fontSize: 11, color: AppTheme.primaryCyan)),
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ADMINISTRATION TIME', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                          SizedBox(height: 4),
                          Text(_bookingTime.format(context), style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(context: context, initialTime: _bookingTime);
                          if (picked != null) {
                            setModalState(() => _bookingTime = picked);
                          }
                        },
                        style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.primaryCyan)),
                        child: Text('PICK TIME', style: TextStyle(fontSize: 11, color: AppTheme.primaryCyan)),
                      )
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  final scheduledDateTime = DateTime(
                    _bookingDate.year,
                    _bookingDate.month,
                    _bookingDate.day,
                    _bookingTime.hour,
                    _bookingTime.minute,
                  );
                  provider.bookVaccine(vaccine.name, scheduledDateTime);
                  Navigator.pop(context);
                  _showSuccessConfirmation(vaccine.name);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                child: Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSuccessConfirmation(String vaccineName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryTeal,
        content: Text('Appointment scheduled for $vaccineName!', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final vaccines = provider.vaccines;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Vaccination Tracker', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
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
              'Immunization Records',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            SizedBox(height: 8),
            Text(
              'Track your vaccine history, manage immunizations, and schedule booster slots.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            SizedBox(height: 24),

            // Vaccination Progress Metrics Card
            _buildMetricsCard(vaccines),

            SizedBox(height: 28),
            Text(
              'Active Doses Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            SizedBox(height: 16),

            // Doses List View
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: vaccines.length,
              itemBuilder: (context, idx) {
                final vac = vaccines[idx];
                final dateStr = vac.date != null ? '${vac.date!.day}/${vac.date!.month}/${vac.date!.year}' : null;

                Color tagColor;
                IconData statusIcon;
                switch (vac.status) {
                  case 'Taken':
                    tagColor = Colors.green;
                    statusIcon = Icons.check_circle_outline_rounded;
                    break;
                  case 'Scheduled':
                    tagColor = Colors.amber;
                    statusIcon = Icons.pending_actions_rounded;
                    break;
                  default:
                    tagColor = AppTheme.primaryCyan;
                    statusIcon = Icons.add_moderator_rounded;
                }

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    radius: 20,
                    borderColor: tagColor.withOpacity(0.15),
                    fillColor: tagColor.withOpacity(0.01),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: tagColor.withOpacity(0.1),
                          child: Icon(statusIcon, color: tagColor, size: 22),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vac.name,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                              ),
                              SizedBox(height: 4),
                              Text(
                                vac.status == 'Taken'
                                    ? 'Completed on $dateStr'
                                    : (vac.status == 'Scheduled' ? 'Appt: $dateStr' : 'Dose available for booking'),
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        if (vac.status == 'Available')
                          ElevatedButton(
                            onPressed: () => _showBookingDialog(context, provider, vac),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('BOOK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          )
                        else
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: tagColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              vac.status.toUpperCase(),
                              style: TextStyle(color: tagColor, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard(List<VaccineRecord> vaccines) {
    final completed = vaccines.where((v) => v.status == 'Taken').length;
    final total = vaccines.length;
    final progressVal = total > 0 ? completed / total : 0.0;

    return GlassCard(
      radius: 24,
      borderColor: AppTheme.primaryTeal.withOpacity(0.15),
      fillColor: AppTheme.primaryTeal.withOpacity(0.02),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('IMMUNIZATION INDEX', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppTheme.primaryCyan, letterSpacing: 1.2)),
                SizedBox(height: 8),
                Text(
                  '$completed of $total Doses Completed',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressVal,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan),
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progressVal,
                  strokeWidth: 6,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                ),
              ),
              Text(
                '${(progressVal * 100).toInt()}%',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
              )
            ],
          )
        ],
      ),
    );
  }
}
