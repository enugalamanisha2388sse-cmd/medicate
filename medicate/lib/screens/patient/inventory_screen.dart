import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor,
        elevation: 0,
        title: Text(
          'Inventory',
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
            Icon(Icons.inventory_2_rounded, size: 80, color: AppTheme.primaryGreen),
            const SizedBox(height: 16),
            Text(
              'Medicine Inventory',
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
