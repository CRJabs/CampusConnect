import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageUploader {
  // 1. Single Image Upload (Used for Avatars, Headers, and Carousel Banners)
  static Future<String?> pickAndUploadSingle(
      BuildContext context, String storagePath) async {
    final ImagePicker picker = ImagePicker();

    // Pick & Compress
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (image == null) return null;

    // Strict 50MB Limit Check
    int fileBytes = await image.length();
    if (fileBytes > 50 * 1024 * 1024) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Upload failed. Image exceeds the 50MB limit.')));
      }
      return null;
    }

    // Upload to Firebase
    try {
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      if (kIsWeb) {
        final data = await image.readAsBytes();
        await storageRef.putData(
            data, SettableMetadata(contentType: 'image/jpeg'));
      }
      return await storageRef.getDownloadURL();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload Error: $e')));
      }
      return null;
    }
  }

  // 2. Multi-Image Picker (Used for Posts) - Returns valid, compressed files under 50MB
  static Future<List<XFile>> pickMultipleValidImages(
      BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> selectedImages = await picker.pickMultiImage(
      imageQuality: 70, // Slightly higher compression for multi-uploads
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (selectedImages.isEmpty) return [];

    List<XFile> validImages = [];
    bool oversizedSkipped = false;

    // Filter out massive files
    for (var img in selectedImages) {
      int bytes = await img.length();
      if (bytes <= 50 * 1024 * 1024) {
        validImages.add(img);
      } else {
        oversizedSkipped = true;
      }
    }

    if (oversizedSkipped && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Some images were skipped for exceeding the 50MB limit.')));
    }

    return validImages;
  }
}
