import 'dart:io';
import 'package:flutter/material.dart';
import 'package:knight_pdf/core/utils/constants.dart';
import 'package:provider/provider.dart';
import '../../providers/image_provider.dart' as app;

class ImageToPdfScreen extends StatelessWidget {
  const ImageToPdfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a consumer to listen to changes in the ImageProvider
    return Consumer<app.ImageProvider>(
      builder: (context, imageProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Images to PDF (${imageProvider.selectedImages.length})"),
            actions: [
              // 'Create PDF' button is only visible if there are images
              if (imageProvider.selectedImages.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: "Create PDF",
                  onPressed: () {
                    // TODO: Implement PDF creation logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("PDF creation coming soon!")),
                    );
                  },
                ),
            ],
          ),
          body: imageProvider.selectedImages.isEmpty
              ? _buildEmptyState(context, imageProvider)
              : _buildImageGrid(context, imageProvider),
          // Floating Action Buttons to add more images
          floatingActionButton: Row(
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

  // Widget to show when no images are selected
  Widget _buildEmptyState(BuildContext context, app.ImageProvider imageProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_search,
            size: 100,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            "No images selected",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            "Add images from your gallery or camera.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // Widget to display the grid of selected images
  Widget _buildImageGrid(BuildContext context, app.ImageProvider imageProvider) {
    // ReorderableListView is a powerful built-in widget for this purpose
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: imageProvider.selectedImages.length,
      onReorder: (oldIndex, newIndex) {
        imageProvider.reorderImages(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final image = imageProvider.selectedImages[index];
        // The key is crucial for ReorderableListView to work correctly
        return Card(
          key: ValueKey(image.path),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          elevation: 3,
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            // Leading shows the image thumbnail
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(image.path),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            // Title shows a count and part of the file name
            title: Text(
              "Image ${index + 1}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              image.path.split('/').last,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            // Trailing icons for deleting and reordering
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.primaryRed),
                  onPressed: () => imageProvider.removeImage(index),
                ),
                // The handle for dragging and reordering
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}