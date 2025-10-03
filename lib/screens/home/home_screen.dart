import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knight_pdf/providers/image_provider.dart' as app;
import 'package:knight_pdf/services/pdf_api_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../../core/utils/constants.dart';
import '../../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PdfApiService _pdfService = PdfApiService();

  Future<void> _convertExcelToPdf() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      // Pop loading dialog if user cancels picker
      if (result == null) {
        if(mounted) Navigator.of(context).pop();
        return;
      }

      final filePath = result.files.single.path!;
      final pdfPath = await _pdfService.createPdfFromExcel(filePath);

      if (!mounted) return;
      Navigator.of(context).pop(); // Pop loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Excel converted to PDF!"),
        action: SnackBarAction(label: "OPEN", onPressed: () => OpenFilex.open(pdfPath)),
      ));
    } catch (e) {
      if(mounted) Navigator.of(context).pop(); // Pop loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to convert: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Your build method from Part 3, but with updated button logic)
    // ... I'll provide the full build method here for clarity.
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar( /* ... */ ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, "Recently Used Features"),
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  _buildToolCard(context, Icons.image, "Images\nto PDF", () {
                    context.read<app.ImageProvider>().clearImages();
                    context.push('/images-to-pdf');
                  }),
                  _buildToolCard(context, Icons.text_fields, "Text\nto PDF", () {
                    context.push('/text-to-pdf'); // <-- CONNECT NAVIGATION
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle(context, "Create a new PDF"),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildToolIconBtn(context, Icons.image_outlined, "Images to PDF", () {
                          context.read<app.ImageProvider>().clearImages();
                          context.push('/images-to-pdf');
                        }),
                        _buildToolIconBtn(context, Icons.text_fields_outlined, "Text to PDF", () {
                          context.push('/text-to-pdf'); // <-- CONNECT NAVIGATION
                        }),
                        _buildToolIconBtn(context, Icons.qr_code, "QR & Barcodes", () {}),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildToolIconBtn(context, Icons.table_chart_outlined, "Excel to PDF", _convertExcelToPdf), // <-- CONNECT LOGIC
                        _buildToolIconBtn(context, Icons.web, "Web to PDF", () {}),
                        const SizedBox(width: 80),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle(context, "View & Modify PDFs"),
            Card( /* ... */ ),
          ],
        ),
      ),
    );
  }
  // --- Helper Widgets (No changes here) ---
  Widget _buildSectionTitle(BuildContext context, String title) { return Padding(padding: const EdgeInsets.only(bottom: 8.0, left: 4.0), child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))); }
  Widget _buildToolCard(BuildContext context, IconData icon, String label, VoidCallback onTap) { return AspectRatio(aspectRatio: 1, child: Card(margin: const EdgeInsets.only(right: 12), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: AppColors.primaryRed, size: 30), const SizedBox(height: 8), Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11))])))); }
  Widget _buildToolIconBtn(BuildContext context, IconData icon, String label, VoidCallback onTap) { return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: Container(width: 80, padding: const EdgeInsets.all(8.0), child: Column(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primaryRed.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: AppColors.primaryRed, size: 28)), const SizedBox(height: 8), Text(label, textAlign: TextAlign.center, maxLines: 2, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, fontSize: 12))]))); }
}