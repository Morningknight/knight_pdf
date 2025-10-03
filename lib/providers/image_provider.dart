import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Represents a single image with its file path
class AppImage {
  final String path;
  AppImage({required this.path});
}

class ImageProvider with ChangeNotifier {
  final List<AppImage> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  List<AppImage> get selectedImages => _selectedImages;

  // Clear all selected images
  void clearImages() {
    _selectedImages.clear();
    notifyListeners();
  }

  // Pick multiple images from the gallery
  Future<void> pickImagesFromGallery() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      imageQuality: 80, // Compress a bit on selection
    );
    if (pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        _selectedImages.add(AppImage(path: file.path));
      }
      notifyListeners();
    }
  }

  // Capture an image from the camera
  Future<void> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      _selectedImages.add(AppImage(path: pickedFile.path));
      notifyListeners();
    }
  }

  // Remove a specific image from the list
  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  // Reorder images in the list (for drag-and-drop)
  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final AppImage item = _selectedImages.removeAt(oldIndex);
    _selectedImages.insert(newIndex, item);
    notifyListeners();
  }
}