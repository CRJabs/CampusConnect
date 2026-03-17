import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageUploader {
  static Future<String?> pickAndUploadSingle(
      BuildContext context, String storagePath) async {
    final ImagePicker picker = ImagePicker();

    // --- 100% QUALITY RESTORED ---
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100, // Maximum visual quality
      maxWidth:
          1920, // Full HD constraint drops raw 12MB camera files down to ~1.5MB
      maxHeight: 1920,
    );

    if (image == null) return null;

    int fileBytes = await image.length();
    if (fileBytes > 50 * 1024 * 1024) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Upload failed. Image exceeds the 50MB limit.')));
      }
      return null;
    }

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

  static Future<List<XFile>> pickMultipleValidImages(
      BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    // --- 100% QUALITY RESTORED ---
    final List<XFile> selectedImages = await picker.pickMultiImage(
      imageQuality: 100, // Maximum visual quality
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (selectedImages.isEmpty) return [];

    List<XFile> validImages = [];
    bool oversizedSkipped = false;

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
