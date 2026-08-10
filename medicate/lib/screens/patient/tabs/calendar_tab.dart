import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/services/services.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  DateTime _selectedDate = DateTime.now();
  DateTime _calendarMonth = DateTime.now();
  String _selectedDept = 'Cardiology';
  String? _selectedDoctor;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  final _departments = ['Cardiology', 'Neurology', 'Diagnostics', 'Pediatrics', 'General Practice'];

  void _bookAppointment(BuildContext context, MedicateProvider provider) {
    final doctors = provider.doctors.where((d) =>
        d.specialty.toLowerCase().contains(_selectedDept.toLowerCase()) ||
        _selectedDept == 'General Practice').toList();
    final doctorName = _selectedDoctor ?? (doctors.isNotEmpty ? doctors[0].name : 'Dr. Reed Richards');
    final apptDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
    );
    provider.bookAppointment(doctorName, _selectedDept, apptDateTime);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Appointment booked with $doctorName on ${DateFormat('MMM d').format(_selectedDate)} at ${_selectedTime.format(context)}',
        style: GoogleFonts.poppins(fontSize: 13),
      ),
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showBookingSheet(BuildContext context, MedicateProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 20),
              Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.primaryOrange.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.event_available_rounded, color: AppTheme.primaryOrange, size: 22)),
                const SizedBox(width: 12),
                Text('Book Appointment', style: AppTextStyles.heading3()),
              ]),
              const SizedBox(height: 20),

              // Department
              Text('Department', style: AppTextStyles.labelLarge()),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.isDark ? const Color(0xFF0F172A) : AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDept,
                    isExpanded: true,
                    dropdownColor: AppTheme.cardColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    borderRadius: BorderRadius.circular(14),
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
                    style: AppTextStyles.bodyMedium(color: AppTheme.textPrimary),
                    items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) { setBS(() { _selectedDept = v!; _selectedDoctor = null; }); },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date & Time row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final p = await showDatePicker(
                          context: ctx,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (p != null) setBS(() => _selectedDate = p);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.isDark ? const Color(0xFF0F172A) : AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(children: [
                          Icon(Icons.calendar_today_rounded, color: AppTheme.primaryOrange, size: 18),
                          const SizedBox(width: 10),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Date', style: AppTextStyles.caption()),
                            Text(DateFormat('MMM d, yyyy').format(_selectedDate), style: AppTextStyles.labelLarge()),
                          ]),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final p = await showTimePicker(context: ctx, initialTime: _selectedTime);
                        if (p != null) setBS(() => _selectedTime = p);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.isDark ? const Color(0xFF0F172A) : AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(children: [
                          Icon(Icons.access_time_rounded, color: AppTheme.primaryOrange, size: 18),
                          const SizedBox(width: 10),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Time', style: AppTextStyles.caption()),
                            Text(_selectedTime.format(ctx), style: AppTextStyles.labelLarge()),
                          ]),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _bookAppointment(context, provider),
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                  label: Text('Confirm Booking', style: AppTextStyles.buttonText()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.calendar_month_rounded, color: AppTheme.primaryOrange, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Calendar', style: AppTextStyles.heading2()),
                        Text('${provider.appointments.length} appointments', style: AppTextStyles.bodySmall()),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Mini calendar
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: AppTheme.cardDecoration,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Month nav
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1)),
                            icon: Icon(Icons.chevron_left_rounded, color: AppTheme.textSecondary),
                            padding: EdgeInsets.zero,
                          ),
                          Expanded(
                            child: Text(
                              DateFormat('MMMM yyyy').format(_calendarMonth),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.heading4(),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1)),
                            icon: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Day headers
                      Row(
                        children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'].map((d) =>
                          Expanded(child: Center(child: Text(d, style: AppTextStyles.caption())))
                        ).toList(),
                      ),
                      const SizedBox(height: 8),
                      // Calendar grid
                      _buildCalendarGrid(provider),
                    ],
                  ),
                ),
              ),
            ),

            // Appointments list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: SectionHeader(
                  title: 'Appointments',
                  subtitle: 'Upcoming & recent',
                ),
              ),
            ),

            if (provider.appointments.isEmpty)
              SliverToBoxAdapter(
                child: EmptyStateWidget(
                  icon: Icons.event_outlined,
                  title: 'No Appointments',
                  subtitle: 'Book your first appointment below',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final appt = provider.appointments[i];
                      return FadeInSlide(
                        delay: Duration(milliseconds: i * 60),
                        child: _AppointmentCard(
                          appointment: appt,
                          onCancel: () => provider.updateAppointmentStatus(appt.id, 'Cancelled'),
                        ),
                      );
                    },
                    childCount: provider.appointments.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookingSheet(context, provider),
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Book Appointment', style: AppTextStyles.buttonText()),
      ),
    );
  }

  Widget _buildCalendarGrid(MedicateProvider provider) {
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final daysInMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday; // 1=Mon, 7=Sun

    // Appointment dates this month
    final apptDates = provider.appointments
        .where((a) => a.dateTime.month == _calendarMonth.month && a.dateTime.year == _calendarMonth.year)
        .map((a) => a.dateTime.day)
        .toSet();

    final cells = <Widget>[];
    for (int i = 1; i < startWeekday; i++) cells.add(const SizedBox.shrink());
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_calendarMonth.year, _calendarMonth.month, day);
      final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month && date.year == _selectedDate.year;
      final isToday = date.day == DateTime.now().day && date.month == DateTime.now().month && date.year == DateTime.now().year;
      final hasAppt = apptDates.contains(day);

      cells.add(GestureDetector(
        onTap: () => setState(() => _selectedDate = date),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryOrange
                    : isToday
                        ? AppTheme.primaryOrange.withOpacity(0.15)
                        : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday && !isSelected ? Border.all(color: AppTheme.primaryOrange, width: 1.5) : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
            if (hasAppt)
              Positioned(
                bottom: 2,
                child: Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? Colors.white : AppTheme.primaryOrange)),
              ),
          ],
        ),
      ));
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1,
      children: cells,
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onCancel;

  const _AppointmentCard({required this.appointment, required this.onCancel});

  Color get _statusColor {
    switch (appointment.status) {
      case 'Approved': return AppTheme.success;
      case 'Cancelled': return AppTheme.error;
      case 'Completed': return AppTheme.info;
      default: return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${appointment.dateTime.day}',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryOrange),
                ),
                Text(
                  DateFormat('MMM').format(appointment.dateTime),
                  style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.primaryOrange),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.doctorName, style: AppTextStyles.labelLarge(), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(
                  '${appointment.department} • ${DateFormat('hh:mm a').format(appointment.dateTime)}',
                  style: AppTextStyles.bodySmall(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  appointment.status,
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor),
                ),
              ),
              if (appointment.status == 'Pending') ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onCancel,
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.error, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
