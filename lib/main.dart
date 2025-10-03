import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/constants.dart';
import 'providers/image_provider.dart' as app;
import 'providers/theme_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/images_to_pdf/image_to_pdf_screen.dart';
import 'screens/text_to_pdf/text_to_pdf_screen.dart'; // Import the new screen
import 'screens/view_files/view_files_screen.dart';

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

// Setup GoRouter configuration with all the app's routes
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
    GoRoute(
      path: '/view-files',
      builder: (context, state) => const ViewFilesScreen(),
    ),
    // Add the new route for the text editor
    GoRoute(
      path: '/text-to-pdf',
      builder: (context, state) => const TextToPdfScreen(),
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