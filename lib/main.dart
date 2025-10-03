import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/constants.dart';
import 'providers/theme_provider.dart';
import 'screens/home/home_screen.dart';

void main() {
  // Ensure Flutter bindings are initialized before specialized code
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // We will add more providers (like PDFProvider) here later
      ],
      child: const KnightPDFApp(),
    ),
  );
}

// Setup GoRouter configuration
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    // We will add routes for EditImage, ViewPDF etc. here
  ],
);

class KnightPDFApp extends StatelessWidget {
  const KnightPDFApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to theme changes
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      // Apply Themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      // Connect Router
      routerConfig: _router,
    );
  }
}