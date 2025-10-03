import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/constants.dart';
import 'providers/image_provider.dart' as app;
import 'providers/theme_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/images_to_pdf/image_to_pdf_screen.dart';
import 'screens/view_files/view_files_screen.dart'; // <-- Import the new screen

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => app.ImageProvider()),
      ],
      child: const KnightPDFApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/images-to-pdf',
      builder: (context, state) => const ImageToPdfScreen(),
    ),
    // Add the new route for the file viewer
    GoRoute(
      path: '/view-files',
      builder: (context, state) => const ViewFilesScreen(),
    ),
  ],
);

class KnightPDFApp extends StatelessWidget {
  const KnightPDFApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}