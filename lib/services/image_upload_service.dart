import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// 📸 IMAGE UPLOAD SERVICE
///
/// এই service handle করে profile image upload:
/// - Pick image from camera or gallery
/// - Upload to Firebase Storage
/// - Get downloadable URL
/// - Compress and optimize images
///
/// Used in:
/// - lib/screens/home/profile_screen.dart (profile image upload)
class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  ///
  /// Returns: XFile with selected image or null if cancelled
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera
  ///
  /// Returns: XFile with captured image or null if cancelled
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error capturing image from camera: $e');
      return null;
    }
  }

  /// Upload profile image to Firebase Storage
  ///
  /// Parameters:
  /// - userId: User ID for folder organization
  /// - imageFile: XFile to upload
  ///
  /// Returns: Download URL string or null if failed
  ///
  /// Path structure: profile_images/{userId}/profile.jpg
  Future<String?> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      // Create reference to storage location
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage
          .ref()
          .child('profile_images')
          .child(userId)
          .child(fileName);

      // Upload file
      final UploadTask uploadTask;

      if (kIsWeb) {
        // For web, use bytes
        final bytes = await imageFile.readAsBytes();
        uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // For mobile/desktop, use file
        uploadTask = storageRef.putFile(
          File(imageFile.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('Profile image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  /// Delete old profile image from Firebase Storage
  ///
  /// Parameters:
  /// - imageUrl: Full download URL of the image to delete
  ///
  /// Call this before uploading a new image to prevent storage clutter
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      // Extract storage path from URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('Old profile image deleted successfully');
    } catch (e) {
      debugPrint('Error deleting old profile image: $e');
      // Don't throw - it's okay if deletion fails
    }
  }

  /// Show bottom sheet to choose image source
  ///
  /// Returns: Selected XFile or null if cancelled
  Future<XFile?> showImageSourceDialog({
    required Function() onCameraSelected,
    required Function() onGallerySelected,
  }) async {
    // This is a helper method - actual UI is in profile_screen.dart
    // Just keeping the logic here for reference
    return null;
  }
}
