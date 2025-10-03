import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/constants.dart';
import '../../providers/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        leading: const Icon(Icons.dashboard_customize), // Replaced custom icon for now
        actions: [
          // Dark Mode Toggle
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme(!themeProvider.isDarkMode);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Recently Used (Placeholder for now)
            _buildSectionTitle(context, "Recently Used Features"),
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  _buildToolCard(context, Icons.image, "Images\nto PDF", () {}),
                  _buildToolCard(context, Icons.text_fields, "Text\nto PDF", () {}),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Create New PDF Section
            _buildSectionTitle(context, "Create a new PDF"),
            Card(
              elevation: 4,
              // Using a slight red tint for the main container like mockup
              color: themeProvider.isDarkMode ? null : AppColors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildToolIconBtn(context, Icons.image_outlined, "Images to PDF", () {
                          // TODO: Navigate to Image to PDF
                        }),
                        _buildToolIconBtn(context, Icons.text_fields_outlined, "Text to PDF", () {}),
                        _buildToolIconBtn(context, Icons.qr_code, "QR & Barcodes", () {}),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildToolIconBtn(context, Icons.table_chart_outlined, "Excel to PDF", () {}),
                        _buildToolIconBtn(context, Icons.web, "Web to PDF", () {}),
                        const SizedBox(width: 70), // Spacer for alignment
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. View & Modify
            _buildSectionTitle(context, "View & Modify PDFs"),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildToolIconBtn(context, Icons.folder_open, "View Files", () {}),
                        _buildToolIconBtn(context, Icons.history, "History", () {}),
                        _buildToolIconBtn(context, Icons.merge_type, "Merge PDF", () {}),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildToolIconBtn(context, Icons.call_split, "Split PDF", () {}),
                        _buildToolIconBtn(context, Icons.lock_outline, "Protect PDF", () {}),
                        _buildToolIconBtn(context, Icons.water_drop_outlined, "Watermark", () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // The square cards seen in "Recently Used"
  Widget _buildToolCard(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryRed, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // The icon/text buttons inside the large white cards
  Widget _buildToolIconBtn(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryRed, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12
              ),
            ),
          ],
        ),
      ),
    );
  }
}