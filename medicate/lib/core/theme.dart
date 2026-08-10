import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math';

// ============================================================
// APP THEME — SmartMed Premium Healthcare
// Material 3 | Poppins Font | Blue & White Healthcare Theme
// ============================================================

class AppTheme {
  static bool _isDark = false;
  static bool get isDark => _isDark;

  static void updateThemeMode(bool isDark) {
    _isDark = isDark;
  }

  // ── Brand Colors ──────────────────────────────────────────
  static const Color _primaryBlueLight   = Color(0xFF2563EB);
  static const Color _primaryBlueDark    = Color(0xFF3B82F6);
  static const Color _primaryDarkBlue    = Color(0xFF1D4ED8);
  static const Color _lightBlue          = Color(0xFFDBEAFE);
  static const Color _secondaryBgLight   = Color(0xFFEFF6FF);
  static const Color _secondaryBgDark    = Color(0xFF1E293B);

  static const Color _bgLight   = Color(0xFFF8FAFC);
  static const Color _bgDark    = Color(0xFF0F172A);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _cardDark  = Color(0xFF1E293B);

  static const Color _textPrimaryLight   = Color(0xFF1E293B);
  static const Color _textPrimaryDark    = Color(0xFFF8FAFC);
  static const Color _textSecondaryLight = Color(0xFF64748B);
  static const Color _textSecondaryDark  = Color(0xFF94A3B8);
  static const Color _textHint           = Color(0xFF94A3B8);

  static const Color _borderLight = Color(0xFFE2E8F0);
  static const Color _borderDark  = Color(0xFF334155);
  static const Color _divider     = Color(0xFFCBD5E1);

  static const Color _success  = Color(0xFF22C55E);
  static const Color _warning  = Color(0xFFF59E0B);
  static const Color _error    = Color(0xFFEF4444);
  static const Color _info     = Color(0xFF0EA5E9);
  static const Color _indigo   = Color(0xFF4F46E5);
  static const Color _purple   = Color(0xFF8B5CF6);
  static const Color _green    = Color(0xFF16A34A);
  static const Color _orange   = Color(0xFFF97316);

  // ── Dynamic Color Getters ─────────────────────────────────
  static Color get primaryBlue    => _isDark ? _primaryBlueDark    : _primaryBlueLight;
  static Color get primaryDarkBlue => _primaryDarkBlue;
  static Color get lightBlue      => _lightBlue;
  static Color get background     => _isDark ? _bgDark             : _bgLight;
  static Color get cardColor      => _isDark ? _cardDark           : _cardLight;
  static Color get secondaryBg    => _isDark ? _secondaryBgDark    : _secondaryBgLight;
  static Color get textPrimary    => _isDark ? _textPrimaryDark    : _textPrimaryLight;
  static Color get textSecondary  => _isDark ? _textSecondaryDark  : _textSecondaryLight;
  static Color get textHint       => _textHint;
  static Color get border         => _isDark ? _borderDark         : _borderLight;
  static Color get divider        => _divider;
  static Color get success        => _success;
  static Color get warning        => _warning;
  static Color get error          => _error;
  static Color get info           => _info;
  static Color get primaryIndigo  => _indigo;
  static Color get primaryPurple  => _purple;
  static Color get primaryGreen   => _green;
  static Color get primaryOrange  => _orange;

  // Legacy aliases (for backward compat)
  static Color get primaryTeal    => primaryBlue;
  static Color get primaryCyan    => _info;
  static Color get borderCard     => border;
  static Color get mainBackground => background;
  static Color get cardBackground => cardColor;

  // ── Nav Icon Colors ───────────────────────────────────────
  static Color navIconColor(int index, int selected) {
    if (index != selected) return textSecondary;
    const colors = [
      _primaryBlueLight,
      _green,
      _purple,
      _orange,
      _indigo,
    ];
    return colors[index < colors.length ? index : 0];
  }

  // ── Gradients ─────────────────────────────────────────────
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [_primaryBlueLight, _primaryBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get tealCyanGradient => LinearGradient(
    colors: [primaryBlue, _info],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get indigoPurpleGradient => const LinearGradient(
    colors: [_indigo, _purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get successGradient => const LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get warningGradient => const LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get darkCardGradient => LinearGradient(
    colors: _isDark
        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
        : [const Color(0xFFFFFFFF), const Color(0xFFEFF6FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get headerGradient => LinearGradient(
    colors: _isDark
        ? [const Color(0xFF1E3A5F), const Color(0xFF0F172A)]
        : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Light Theme ───────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: _primaryBlueLight,
        onPrimary: Colors.white,
        primaryContainer: _lightBlue,
        onPrimaryContainer: _primaryDarkBlue,
        secondary: _indigo,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFE0E7FF),
        onSecondaryContainer: _indigo,
        tertiary: _purple,
        onTertiary: Colors.white,
        tertiaryContainer: const Color(0xFFEDE9FE),
        onTertiaryContainer: _purple,
        error: _error,
        onError: Colors.white,
        errorContainer: const Color(0xFFFEE2E2),
        onErrorContainer: _error,
        surface: _cardLight,
        onSurface: _textPrimaryLight,
        surfaceContainerHighest: _bgLight,
        onSurfaceVariant: _textSecondaryLight,
        outline: _borderLight,
        outlineVariant: _divider,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: _bgDark,
        onInverseSurface: _textPrimaryDark,
        inversePrimary: _primaryBlueDark,
      ),
      scaffoldBackgroundColor: _bgLight,
      cardColor: _cardLight,
      dividerColor: _divider,
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: _textPrimaryLight,
        displayColor: _textPrimaryLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _cardLight,
        foregroundColor: _textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _textPrimaryLight,
        ),
        iconTheme: const IconThemeData(color: _textPrimaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlueLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryBlueLight,
          side: const BorderSide(color: _primaryBlueLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _bgLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryBlueLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: _textSecondaryLight, fontSize: 14),
        hintStyle: GoogleFonts.poppins(color: _textHint, fontSize: 14),
        prefixIconColor: _primaryBlueLight,
      ),
      cardTheme: CardThemeData(
        color: _cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _bgLight,
        selectedColor: _lightBlue,
        labelStyle: GoogleFonts.poppins(fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: _borderLight),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _cardLight,
        indicatorColor: _lightBlue,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primaryBlueLight, size: 24);
          }
          return IconThemeData(color: _textSecondaryLight, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _primaryBlueLight,
            );
          }
          return GoogleFonts.poppins(
            fontSize: 11,
            color: _textSecondaryLight,
          );
        }),
        elevation: 0,
        height: 72,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _cardDark,
        contentTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _textPrimaryLight,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryBlueLight,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? _primaryBlueLight : Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? _lightBlue : _borderLight),
      ),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: _primaryBlueDark,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFF1E3A5F),
        onPrimaryContainer: _lightBlue,
        secondary: const Color(0xFF818CF8),
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFF1E2040),
        onSecondaryContainer: const Color(0xFFC7D2FE),
        tertiary: const Color(0xFFA78BFA),
        onTertiary: Colors.white,
        tertiaryContainer: const Color(0xFF2D1B69),
        onTertiaryContainer: const Color(0xFFEDE9FE),
        error: const Color(0xFFF87171),
        onError: Colors.white,
        errorContainer: const Color(0xFF450A0A),
        onErrorContainer: const Color(0xFFFECACA),
        surface: _cardDark,
        onSurface: _textPrimaryDark,
        surfaceContainerHighest: _bgDark,
        onSurfaceVariant: _textSecondaryDark,
        outline: _borderDark,
        outlineVariant: const Color(0xFF1E293B),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: _bgLight,
        onInverseSurface: _textPrimaryLight,
        inversePrimary: _primaryBlueLight,
      ),
      scaffoldBackgroundColor: _bgDark,
      cardColor: _cardDark,
      dividerColor: _borderDark,
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: _textPrimaryDark,
        displayColor: _textPrimaryDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _cardDark,
        foregroundColor: _textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _textPrimaryDark,
        ),
        iconTheme: const IconThemeData(color: _textPrimaryDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlueDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryBlueDark,
          side: const BorderSide(color: _primaryBlueDark, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F172A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryBlueDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF87171)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: _textSecondaryDark, fontSize: 14),
        hintStyle: GoogleFonts.poppins(color: _textHint, fontSize: 14),
        prefixIconColor: _primaryBlueDark,
      ),
      cardTheme: CardThemeData(
        color: _cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _bgDark,
        selectedColor: const Color(0xFF1E3A5F),
        labelStyle: GoogleFonts.poppins(fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: _borderDark),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _cardDark,
        indicatorColor: const Color(0xFF1E3A5F),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primaryBlueDark, size: 24);
          }
          return const IconThemeData(color: _textSecondaryDark, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _primaryBlueDark,
            );
          }
          return GoogleFonts.poppins(
            fontSize: 11,
            color: _textSecondaryDark,
          );
        }),
        elevation: 0,
        height: 72,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _cardLight,
        contentTextStyle: GoogleFonts.poppins(color: _textPrimaryLight, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _textPrimaryDark,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryBlueDark,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? _primaryBlueDark : Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? const Color(0xFF1E3A5F)
                : _borderDark),
      ),
    );
  }

  // ── Decoration Helpers ────────────────────────────────────
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: border, width: 1),
    boxShadow: _isDark
        ? []
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
  );

  static BoxDecoration get cardDecorationElevated => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: border, width: 1),
    boxShadow: [
      BoxShadow(
        color: (_isDark ? Colors.black : Colors.black).withOpacity(_isDark ? 0.3 : 0.08),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration primaryCardDecoration({double radius = 20}) => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: primaryBlue.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get glassDecoration => BoxDecoration(
    color: cardColor.withOpacity(_isDark ? 0.08 : 0.72),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: _isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.06),
      width: 1.2,
    ),
    boxShadow: _isDark
        ? []
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
  );

  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Color? iconColor,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: iconColor ?? primaryBlue),
      suffixIcon: suffixIcon,
      labelStyle: GoogleFonts.poppins(color: textSecondary, fontSize: 14),
      hintStyle: GoogleFonts.poppins(color: textHint, fontSize: 13),
      filled: true,
      fillColor: _isDark ? const Color(0xFF0F172A) : _bgLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _error, width: 2),
      ),
    );
  }
}

// ── Text Styles ──────────────────────────────────────────────
class AppTextStyles {
  static TextStyle heading1({Color? color}) => GoogleFonts.poppins(
    fontSize: 28, fontWeight: FontWeight.w700, color: color ?? AppTheme.textPrimary, height: 1.2,
  );

  static TextStyle heading2({Color? color}) => GoogleFonts.poppins(
    fontSize: 22, fontWeight: FontWeight.w700, color: color ?? AppTheme.textPrimary, height: 1.3,
  );

  static TextStyle heading3({Color? color}) => GoogleFonts.poppins(
    fontSize: 18, fontWeight: FontWeight.w600, color: color ?? AppTheme.textPrimary, height: 1.3,
  );

  static TextStyle heading4({Color? color}) => GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w600, color: color ?? AppTheme.textPrimary, height: 1.4,
  );

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.poppins(
    fontSize: 15, fontWeight: FontWeight.w400, color: color ?? AppTheme.textPrimary, height: 1.5,
  );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w400, color: color ?? AppTheme.textSecondary, height: 1.5,
  );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.poppins(
    fontSize: 12, fontWeight: FontWeight.w400, color: color ?? AppTheme.textSecondary, height: 1.4,
  );

  static TextStyle labelLarge({Color? color}) => GoogleFonts.poppins(
    fontSize: 13, fontWeight: FontWeight.w600, color: color ?? AppTheme.textPrimary,
  );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.poppins(
    fontSize: 11, fontWeight: FontWeight.w500, color: color ?? AppTheme.textSecondary,
  );

  static TextStyle caption({Color? color}) => GoogleFonts.poppins(
    fontSize: 11, fontWeight: FontWeight.w400, color: color ?? AppTheme.textSecondary, height: 1.4,
  );

  static TextStyle buttonText({Color? color}) => GoogleFonts.poppins(
    fontSize: 15, fontWeight: FontWeight.w600, color: color ?? Colors.white,
  );
}

// ── Reusable Widget Components ───────────────────────────────

/// Premium card with soft shadow and rounded corners
class SmartMedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool elevated;

  const SmartMedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 20,
    this.color,
    this.gradient,
    this.onTap,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppTheme.cardColor) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: gradient == null
            ? Border.all(color: AppTheme.border, width: 1)
            : null,
        boxShadow: AppTheme.isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(elevated ? 0.10 : 0.05),
                  blurRadius: elevated ? 24 : 16,
                  offset: Offset(0, elevated ? 8 : 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Status Badge (Success / Warning / Error / Info)
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({super.key, required this.label, required this.color, this.icon});

  factory StatusBadge.success(String label) =>
      StatusBadge(label: label, color: AppTheme.success, icon: Icons.check_circle_rounded);

  factory StatusBadge.warning(String label) =>
      StatusBadge(label: label, color: AppTheme.warning, icon: Icons.warning_amber_rounded);

  factory StatusBadge.error(String label) =>
      StatusBadge(label: label, color: AppTheme.error, icon: Icons.cancel_rounded);

  factory StatusBadge.info(String label) =>
      StatusBadge(label: label, color: AppTheme.info, icon: Icons.info_rounded);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

/// App section header with optional "See All" action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.heading3()),
              if (subtitle != null)
                Text(subtitle!, style: AppTextStyles.bodySmall()),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              actionLabel!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
      ],
    );
  }
}

/// Search bar widget
class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.bodyMedium(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium(color: AppTheme.textHint),
          prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 22),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 18),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 20),
            Text(title, style: AppTextStyles.heading4(), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: AppTextStyles.bodySmall(), textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Glassmorphic Card (legacy compat)
class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final Color borderColor;
  final Color fillColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.radius = 20.0,
    this.blur = 10.0,
    this.borderColor = const Color(0x1AFFFFFF),
    this.fillColor = const Color(0x14FFFFFF),
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark;
    final resolvedFillColor = fillColor == const Color(0x14FFFFFF)
        ? (isDark ? const Color(0x14FFFFFF) : const Color(0xCCFFFFFF))
        : fillColor;
    final resolvedBorderColor = borderColor == const Color(0x1AFFFFFF)
        ? (isDark ? const Color(0x1AFFFFFF) : const Color(0x1A000000))
        : borderColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: resolvedFillColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: resolvedBorderColor, width: 1.2),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Fade + Slide entrance animation
class FadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double slideOffset;
  final Curve curve;
  final Duration delay;

  const FadeInSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.slideOffset = 30.0,
    this.curve = Curves.easeOutCubic,
    this.delay = Duration.zero,
  });

  @override
  State<FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _slideAnimation = Tween<double>(begin: widget.slideOffset, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
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
      builder: (context, child) => Opacity(
        opacity: _fadeAnimation.value,
        child: Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Pulsing animated circle (for SOS / alerts)
class PulsingCircle extends StatefulWidget {
  final Color color;
  final double size;
  final Widget child;

  const PulsingCircle({super.key, required this.color, required this.size, required this.child});

  @override
  State<PulsingCircle> createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<PulsingCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _animation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.size * _animation.value,
              height: widget.size * _animation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.2 * (1 - (_animation.value - 1) / 0.4)),
              ),
            ),
            child!,
          ],
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
        child: widget.child,
      ),
    );
  }
}

// ── Mobile Preview Frame ─────────────────────────────────────
class MobileViewFrame extends StatelessWidget {
  final Widget child;
  const MobileViewFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 480) return child;

    return Scaffold(
      backgroundColor: const Color(0xFF060A10),
      body: Center(
        child: Container(
          width: 430,
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(44),
            border: Border.all(color: const Color(0xFF1E293B), width: 10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.25),
                blurRadius: 40,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ── Dynamic Animated Background ──────────────────────────────
class StarNode {
  double x, y, size, speed;
  StarNode({required this.x, required this.y, required this.size, required this.speed});
}

class NeonBlobPainter extends CustomPainter {
  final double progress;
  NeonBlobPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..color = AppTheme.primaryBlue.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    final p2 = Paint()
      ..color = AppTheme.primaryIndigo.withOpacity(0.07)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);
    final p3 = Paint()
      ..color = AppTheme.primaryPurple.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    canvas.drawCircle(
      Offset(size.width * 0.2 + 50 * sin(progress * 2 * pi), size.height * 0.3 + 60 * cos(progress * 2 * pi)),
      120, p1,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8 + 60 * cos(progress * 2 * pi + 1), size.height * 0.7 + 50 * sin(progress * 2 * pi + 1)),
      140, p2,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5 + 40 * sin(progress * 2 * pi + 2), size.height * 0.5 + 40 * cos(progress * 2 * pi + 2)),
      100, p3,
    );
  }

  @override
  bool shouldRepaint(NeonBlobPainter old) => old.progress != progress;
}

class DynamicBackground extends StatefulWidget {
  final Widget child;
  const DynamicBackground({super.key, required this.child});

  @override
  State<DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<DynamicBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<StarNode> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
    final rng = Random();
    _stars = List.generate(20, (_) => StarNode(
      x: rng.nextDouble() * 450,
      y: rng.nextDouble() * 900,
      size: 0.8 + rng.nextDouble() * 1.5,
      speed: 0.06 + rng.nextDouble() * 0.12,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppTheme.background),
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomPaint(
            size: Size.infinite,
            painter: NeonBlobPainter(_controller.value),
          ),
        ),
        widget.child,
      ],
    );
  }
}
