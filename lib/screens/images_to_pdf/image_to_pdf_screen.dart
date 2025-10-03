import 'dart:io';
import 'package:flutter/material.dart';
import 'package:knight_pdf/core/utils/constants.dart';
import 'package:knight_pdf/services/pdf_api_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import '../../providers/image_provider.dart' as app;

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  bool _isCreating = false;
  final PdfApiService _pdfService = PdfApiService();

  // --- State for PDF Options (password and quality removed) ---
  PdfPageFormat _pageFormat = PdfPageFormat.a4;
  ImageScaleType _scaleType = ImageScaleType.fit;

  Future<void> _createPdf() async {
    setState(() { _isCreating = true; });
    if (!mounted) return;

    try {
      final imageProvider = context.read<app.ImageProvider>();
      final imagePaths = imageProvider.selectedImages.map((img) => img.path).toList();

      if (imagePaths.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select at least one image.")));
        return;
      }

      // Create simplified options object
      final options = PdfCreationOptions(
        pageFormat: _pageFormat,
        scaleType: _scaleType,
      );

      final pdfPath = await _pdfService.createPdfFromImages(imagePaths: imagePaths, options: options);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("PDF created successfully!"),
        action: SnackBarAction(label: "OPEN", onPressed: () => OpenFilex.open(pdfPath)),
      ));

      imageProvider.clearImages();
      Navigator.of(context).pop();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to create PDF: $e")));
    } finally {
      if(mounted) { setState(() { _isCreating = false; }); }
    }
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Wrap(
                runSpacing: 16,
                children: [
                  Text("Additional Options", style: Theme.of(context).textTheme.headlineSmall),

                  // --- PASSWORD AND COMPRESSION UI REMOVED ---

                  DropdownButtonFormField<PdfPageFormat>(
                    value: _pageFormat,
                    decoration: const InputDecoration(labelText: "Page Size", border: OutlineInputBorder(), prefixIcon: Icon(Icons.aspect_ratio)),
                    items: const [
                      DropdownMenuItem(value: PdfPageFormat.a3, child: Text("A3")),
                      DropdownMenuItem(value: PdfPageFormat.a4, child: Text("A4 (Default)")),
                      DropdownMenuItem(value: PdfPageFormat.a5, child: Text("A5")),
                      DropdownMenuItem(value: PdfPageFormat.letter, child: Text("Letter")),
                      DropdownMenuItem(value: PdfPageFormat.legal, child: Text("Legal")),
                    ],
                    onChanged: (value) => setSheetState(() => setState(() => _pageFormat = value ?? PdfPageFormat.a4)),
                  ),

                  DropdownButtonFormField<ImageScaleType>(
                    value: _scaleType,
                    decoration: const InputDecoration(labelText: "Image Scale Type", border: OutlineInputBorder(), prefixIcon: Icon(Icons.photo_size_select_large)),
                    items: const [
                      DropdownMenuItem(value: ImageScaleType.fit, child: Text("Fit to Page")),
                      DropdownMenuItem(value: ImageScaleType.fill, child: Text("Fill Page (Stretch)")),
                    ],
                    onChanged: (value) => setSheetState(() => setState(() => _scaleType = value ?? ImageScaleType.fit)),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Done"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This build method and the helper widgets have no changes.
    return Scaffold(
      appBar: AppBar(
        title: Text("Images to PDF (${context.watch<app.ImageProvider>().selectedImages.length})"),
        actions: [
          if (context.watch<app.ImageProvider>().selectedImages.isNotEmpty && !_isCreating)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: "Create PDF",
              onPressed: _createPdf,
            ),
        ],
      ),
      body: Consumer<app.ImageProvider>(
          builder: (context, imageProvider, child) {
            return Stack(
              children: [
                imageProvider.selectedImages.isEmpty ? _buildEmptyState() : _buildImageGrid(imageProvider),
                if (_isCreating)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text("Creating PDF...", style: TextStyle(color: Colors.white, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }
      ),
      floatingActionButton: _isCreating ? null : Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'options_fab',
            onPressed: _showOptionsSheet,
            child: const Icon(Icons.settings),
            tooltip: "PDF Options",
          ),
          const SizedBox(width: 10),
          FloatingActionButton.extended(
            heroTag: 'camera_fab',
            onPressed: () => context.read<app.ImageProvider>().pickImageFromCamera(),
            label: const Text("Camera"),
            icon: const Icon(Icons.camera_alt),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.extended(
            heroTag: 'gallery_fab',
            onPressed: () => context.read<app.ImageProvider>().pickImagesFromGallery(),
            label: const Text("Gallery"),
            icon: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() { return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Icon(Icons.image_search,size: 100,color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),), const SizedBox(height: 20), Text("No images selected",style: Theme.of(context).textTheme.headlineSmall,), const SizedBox(height: 10), Text("Add images from your gallery or camera.", style: Theme.of(context).textTheme.bodyMedium,)])); }
  Widget _buildImageGrid(app.ImageProvider imageProvider) { return ReorderableListView.builder(padding: const EdgeInsets.fromLTRB(8, 8, 8, 96), itemCount: imageProvider.selectedImages.length,onReorder: (oldIndex, newIndex) => imageProvider.reorderImages(oldIndex, newIndex),itemBuilder: (context, index) {final image = imageProvider.selectedImages[index]; return Card(key: ValueKey(image.path),margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),elevation: 3,child: ListTile(contentPadding: const EdgeInsets.all(10),leading: ClipRRect(borderRadius: BorderRadius.circular(8.0),child: Image.file(File(image.path), width: 60, height: 60, fit: BoxFit.cover)),title: Text("Image ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),subtitle: Text(image.path.split('/').last,overflow: TextOverflow.ellipsis,maxLines: 1,),trailing: Row(mainAxisSize: MainAxisSize.min,children: [IconButton(icon: const Icon(Icons.delete, color: AppColors.primaryRed),onPressed: () => imageProvider.removeImage(index),),ReorderableDragStartListener(index: index,child: const Icon(Icons.drag_handle),), ],),),);},); }
}