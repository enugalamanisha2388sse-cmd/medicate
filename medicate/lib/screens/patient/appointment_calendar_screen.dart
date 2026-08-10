import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';
import 'gate_pass_screen.dart';

class AppointmentCalendarScreen extends StatefulWidget {
  final String? initialDoctor;
  final String? initialDepartment;
  AppointmentCalendarScreen({super.key, this.initialDoctor, this.initialDepartment});

  @override
  State<AppointmentCalendarScreen> createState() =>
      _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState extends State<AppointmentCalendarScreen> {
  String _selectedDept = 'General Diagnostics';
  String? _selectedDoctor;
  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  String? _selectedTime;

  final Map<String, Map<String, dynamic>> _doctorDetails = {
    'Dr. Sarah Connor': {
      'specialty': 'Cardiologist',
      'experience': '15+ Years',
      'rating': '4.9',
      'fee': '₹500',
      'bio':
          'Senior Cardiologist with 15+ years of diagnostic experience. Specializes in heart valve repairs and coronary artery diseases.',
    },
    'Dr. Reed Richards': {
      'specialty': 'General Diagnostics',
      'experience': '20+ Years',
      'rating': '4.8',
      'fee': '₹400',
      'bio':
          'Director of Advanced Medical Diagnostics. Developer of holographic biometrics trackers and telemetry networks.',
    },
    'Dr. Stephen Strange': {
      'specialty': 'Neurology & Neuro-surgery',
      'experience': '12+ Years',
      'rating': '4.9',
      'fee': '₹600',
      'bio':
          'Acclaimed neurosurgeon with expertise in cognitive mapping, nerve recovery, and complex brain surgeries.',
    },
    'Dr. Bruce Banner': {
      'specialty': 'Pediatrics & Biochemistry',
      'experience': '10+ Years',
      'rating': '4.7',
      'fee': '₹350',
      'bio':
          'Expert pediatrician and cellular biophysicist. Specializes in child genetics, growth telemetry, and hormone treatments.',
    },
  };

  final List<String> _departments = [
    'General Diagnostics',
    'Cardiology',
    'Neurology',
    'Pediatrics',
  ];

  final Map<String, List<String>> _deptDoctors = {
    'General Diagnostics': ['Dr. Reed Richards', 'Dr. Sarah Connor'],
    'Cardiology': ['Dr. Sarah Connor'],
    'Neurology': ['Dr. Stephen Strange'],
    'Pediatrics': ['Dr. Bruce Banner', 'Dr. Reed Richards'],
  };

  final List<String> _timeSlots = [
    '09:00 AM',
    '10:30 AM',
    '11:45 AM',
    '02:00 PM',
    '03:30 PM',
    '04:45 PM',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialDepartment != null && widget.initialDepartment!.isNotEmpty) {
      _selectedDept = widget.initialDepartment!;
    }
    if (widget.initialDoctor != null && widget.initialDoctor!.isNotEmpty) {
      _selectedDoctor = widget.initialDoctor;
      if (widget.initialDepartment == null) {
        for (var entry in _deptDoctors.entries) {
          if (entry.value.contains(widget.initialDoctor)) {
            _selectedDept = entry.key;
            break;
          }
        }
      }
    } else {
      _selectedDoctor = _deptDoctors[_selectedDept]?.first;
    }
  }

  void _book(MedicateProvider provider) {
    if (_selectedDoctor == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select doctor, date and time slot.'),
        ),
      );
      return;
    }

    // Parse hour and minute
    final timeParts = _selectedTime!.split(' ');
    final hm = timeParts[0].split(':');
    int hour = int.parse(hm[0]);
    final min = int.parse(hm[1]);
    if (timeParts[1] == 'PM' && hour < 12) hour += 12;
    if (timeParts[1] == 'AM' && hour == 12) hour = 0;

    final bookingDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      min,
    );

    provider.bookAppointment(_selectedDoctor!, _selectedDept, bookingDateTime);
    _showSuccessDialog();
    setState(() {
      _selectedTime = null;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.primaryTeal.withOpacity(0.3)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryTeal.withOpacity(0.1),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryCyan,
                size: 64,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Booking Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your appointment with $_selectedDoctor has been registered and is pending approval.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'OKAY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final myBookings = provider.appointments
        .where((a) => a.patientId == provider.currentUser?.id)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Book Appointment',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule Consult',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 16),

            // 1. Department Selection (Horizontal Pills)
            Text(
              'Select Department',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _departments.length,
                itemBuilder: (context, idx) {
                  final dept = _departments[idx];
                  final isSel = _selectedDept == dept;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDept = dept;
                        _selectedDoctor = _deptDoctors[dept]?.first;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppTheme.primaryTeal
                            : AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel
                              ? AppTheme.primaryCyan
                              : AppTheme.borderCard,
                        ),
                      ),
                      child: Text(
                        dept,
                        style: TextStyle(
                          color: isSel ? Colors.white : AppTheme.textSecondary,
                          fontWeight: isSel
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24),

            // 2. Choose Medical Officer detailed cards list
            Text(
              'Choose Medical Officer',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 12),
            Column(
              children: (_deptDoctors[_selectedDept] ?? []).map((String doc) {
                final details =
                    _doctorDetails[doc] ??
                    {
                      'specialty': 'General Medical Officer',
                      'experience': '8+ Years',
                      'rating': '4.8',
                      'fee': '₹300',
                      'bio':
                          'Certified clinical practitioner specializing in diagnostic procedures.',
                    };
                final isSel = _selectedDoctor == doc;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDoctor = doc;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      radius: 18,
                      borderColor: isSel
                          ? AppTheme.primaryTeal
                          : AppTheme.borderCard,
                      fillColor: isSel
                          ? AppTheme.primaryTeal.withOpacity(0.04)
                          : Color(0x0AFFFFFF),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppTheme.primaryTeal.withOpacity(
                              0.1,
                            ),
                            child: Icon(
                              Icons.person,
                              color: isSel
                                  ? AppTheme.primaryCyan
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${details['specialty']} • ${details['experience']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 12,
                                    ),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        details['rating'],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.amber,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        'Fee: ${details['fee']}',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppTheme.primaryCyan,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              TextButton(
                                onPressed: () => _showDoctorDetailsBottomSheet(
                                  context,
                                  doc,
                                  details,
                                ),
                                child: Text(
                                  'INFO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryCyan,
                                  ),
                                ),
                              ),
                              if (isSel)
                                Icon(
                                  Icons.check_circle,
                                  color: AppTheme.primaryTeal,
                                  size: 20,
                                )
                              else
                                Icon(
                                  Icons.circle_outlined,
                                  color: AppTheme.borderCard,
                                  size: 20,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24),

            // 3. Horizontal Calendar Day Selector
            Text(
              'Select Date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 10),
            _buildHorizontalCalendar(),
            SizedBox(height: 24),

            // 4. Time Slot Grid
            Text(
              'Select Time Slot',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemCount: _timeSlots.length,
              itemBuilder: (context, idx) {
                final slot = _timeSlots[idx];
                final isSel = _selectedTime == slot;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = slot;
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppTheme.primaryCyan.withOpacity(0.2)
                          : AppTheme.cardColor,
                      border: Border.all(
                        color: isSel
                            ? AppTheme.primaryCyan
                            : AppTheme.borderCard,
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      slot,
                      style: TextStyle(
                        color: isSel
                            ? AppTheme.primaryCyan
                            : AppTheme.textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 32),

            // Booking Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _book(provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'CONFIRM APPOINTMENT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            SizedBox(height: 40),

            // 5. My Booked Appointments Section
            Text(
              'My Appointments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            if (myBookings.isEmpty)
              GlassCard(
                radius: 16,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'No appointments booked yet.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: myBookings.length,
                itemBuilder: (context, index) {
                  final booking = myBookings[index];
                  final formattedDate =
                      '${booking.dateTime.day}/${booking.dateTime.month}/${booking.dateTime.year}';
                  final formattedTime =
                      '${booking.dateTime.hour.toString().padLeft(2, '0')}:${booking.dateTime.minute.toString().padLeft(2, '0')}';

                  Color statusColor;
                  switch (booking.status) {
                    case 'Pending':
                      statusColor = Colors.orange;
                      break;
                    case 'Approved':
                      statusColor = Colors.green;
                      break;
                    default:
                      statusColor = AppTheme.textSecondary;
                  }

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      radius: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.doctorName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${booking.department} • $formattedDate @ $formattedTime',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  booking.status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              if (booking.status == 'Approved') ...[
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          GatePassScreen(appointment: booking),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryTeal,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'VIEW PASS',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
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

  Widget _buildHorizontalCalendar() {
    return SizedBox(
      height: 75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Next 2 weeks
        itemBuilder: (context, idx) {
          final date = DateTime.now().add(Duration(days: idx + 1));
          final isSel =
              _selectedDate.day == date.day &&
              _selectedDate.month == date.month;
          final dayName = _getDayName(date.weekday);
          final dayNum = date.day.toString();

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 12),
              width: 55,
              decoration: BoxDecoration(
                color: isSel ? AppTheme.primaryTeal : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSel ? AppTheme.primaryCyan : AppTheme.borderCard,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isSel ? Colors.white70 : AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    dayNum,
                    style: TextStyle(
                      color: isSel ? Colors.white : AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'MON';
      case 2:
        return 'TUE';
      case 3:
        return 'WED';
      case 4:
        return 'THU';
      case 5:
        return 'FRI';
      case 6:
        return 'SAT';
      default:
        return 'SUN';
    }
  }

  void _showDoctorDetailsBottomSheet(
    BuildContext context,
    String name,
    Map<String, dynamic> details,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GlassCard(
          radius: 30,
          borderColor: AppTheme.primaryTeal.withOpacity(0.3),
          fillColor: AppTheme.background.withOpacity(0.98),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryTeal.withOpacity(0.15),
                      child: Icon(
                        Icons.person,
                        color: AppTheme.primaryCyan,
                        size: 36,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          details['specialty'],
                          style: TextStyle(
                            color: AppTheme.primaryCyan,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  'BIOGRAPHY SUMMARY',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  details['bio'],
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                Divider(color: AppTheme.borderCard, height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDocStat('Experience', details['experience']),
                    _buildDocStat('Rating', '${details['rating']} ⭐'),
                    _buildDocStat('Consult Fee', details['fee']),
                  ],
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedDoctor = name;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'SELECT DOCTOR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
