import 'dart:io';
import 'package:flutter/material.dart';
import 'package:knight_pdf/core/utils/constants.dart';
import 'package:knight_pdf/services/pdf_api_service.dart';
import 'package:open_filex/open_filex.dart';
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

  Future<void> _createPdf() async {
    setState(() {
      _isCreating = true;
    });

    try {
      final imageProvider = context.read<app.ImageProvider>();
      final imagePaths = imageProvider.selectedImages.map((img) => img.path).toList();

      if (imagePaths.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one image.")),
        );
        return;
      }

      final pdfPath = await _pdfService.createPdfFromImages(imagePaths);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("PDF created successfully!"),
          action: SnackBarAction(
            label: "OPEN",
            onPressed: () {
              OpenFilex.open(pdfPath);
            },
          ),
        ),
      );

      // Optionally, navigate back or clear images
      imageProvider.clearImages();
      if(mounted) Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create PDF: $e")),
      );
    } finally {
      if(mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<app.ImageProvider>(
      builder: (context, imageProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Images to PDF (${imageProvider.selectedImages.length})"),
            actions: [
              if (imageProvider.selectedImages.isNotEmpty && !_isCreating)
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: "Create PDF",
                  onPressed: _createPdf,
                ),
            ],
          ),
          body: Stack(
            children: [
              imageProvider.selectedImages.isEmpty
                  ? _buildEmptyState(context)
                  : _buildImageGrid(context, imageProvider),

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
          ),
          floatingActionButton: _isCreating ? null : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'camera_fab',
                onPressed: () => imageProvider.pickImageFromCamera(),
                label: const Text("Camera"),
                icon: const Icon(Icons.camera_alt),
              ),
              const SizedBox(width: 10),
              FloatingActionButton.extended(
                heroTag: 'gallery_fab',
                onPressed: () => imageProvider.pickImagesFromGallery(),
                label: const Text("Gallery"),
                icon: const Icon(Icons.photo_library),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_search, size: 100, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text("No images selected", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text("Add images from your gallery or camera.", style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, app.ImageProvider imageProvider) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 80), // Padding for FAB
      itemCount: imageProvider.selectedImages.length,
      onReorder: (oldIndex, newIndex) => imageProvider.reorderImages(oldIndex, newIndex),
      itemBuilder: (context, index) {
        final image = imageProvider.selectedImages[index];
        return Card(
          key: ValueKey(image.path),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          elevation: 3,
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(File(image.path), width: 60, height: 60, fit: BoxFit.cover),
            ),
            title: Text("Image ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(image.path.split('/').last, overflow: TextOverflow.ellipsis, maxLines: 1),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.delete, color: AppColors.primaryRed), onPressed: () => imageProvider.removeImage(index)),
                ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle)),
              ],
            ),
          ),
        );
      },
    );
  }
}