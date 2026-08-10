import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/services/services.dart';
import 'screens/auth/role_selection_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicateProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    AppTheme.updateThemeMode(provider.themeMode == ThemeMode.dark);

    return MaterialApp(
      title: 'SmartMed Portal',
      debugShowCheckedModeBanner: false,
      themeMode: provider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: MobileViewFrame(child: RoleSelectionScreen()),
    );
  }
}
