import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class HealthAnalyticsScreen extends StatelessWidget {
  const HealthAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor,
        elevation: 0,
        title: Text(
          'Health Analytics',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: AppTheme.primaryBlue),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 80, color: AppTheme.primaryPurple),
            const SizedBox(height: 16),
            Text(
              'Health Analytics',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
