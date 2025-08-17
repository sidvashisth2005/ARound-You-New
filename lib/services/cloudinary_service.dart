import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  // Replace these with your actual Cloudinary credentials
  static const String _cloudName = 'decbyhxrz';
  static const String _uploadPreset = 'around_you_uploads';
  
  late CloudinaryPublic _cloudinary;

  void initialize() {
    _cloudinary = CloudinaryPublic(
      _cloudName,
      _uploadPreset,
      cache: false,
    );
  }

  /// Upload an image file to Cloudinary
  Future<String?> uploadImage(File imageFile, {String? folder}) async {
    try {
      if (kDebugMode) {
        print('🖼️ Uploading image to Cloudinary...');
      }

      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: folder ?? 'around_you',
        ),
      );

      if (kDebugMode) {
        print('✅ Image uploaded successfully: ${response.secureUrl}');
      }

      return response.secureUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to upload image: $e');
      }
      rethrow;
    }
  }

  /// Upload multiple images to Cloudinary
  Future<List<String>> uploadMultipleImages(List<File> imageFiles, {String? folder}) async {
    List<String> uploadedUrls = [];
    
    for (File imageFile in imageFiles) {
      try {
        String? url = await uploadImage(imageFile, folder: folder);
        if (url != null) {
          uploadedUrls.add(url);
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to upload image: $e');
        }
        // Continue with other images even if one fails
      }
    }
    
    return uploadedUrls;
  }

  /// Delete an image from Cloudinary (if you have admin access)
  Future<bool> deleteImage(String publicId) async {
    try {
      // Note: This requires admin access to Cloudinary
      // You might need to implement this through your backend
      if (kDebugMode) {
        print('🗑️ Deleting image: $publicId');
      }
      
      // For now, just return true as a placeholder
      // Implement actual deletion logic when you have backend access
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to delete image: $e');
      }
      return false;
    }
  }

  /// Get optimized image URL with transformations
  String getOptimizedImageUrl(String originalUrl, {
    int? width,
    int? height,
    String? quality,
    String? format,
  }) {
    if (!originalUrl.contains('cloudinary.com')) {
      return originalUrl;
    }

    String baseUrl = originalUrl.split('/upload/')[0];
    String imagePath = originalUrl.split('/upload/')[1];
    
    List<String> transformations = [];
    
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (quality != null) transformations.add('q_$quality');
    if (format != null) transformations.add('f_$format');
    
    String transformationString = transformations.isNotEmpty 
      ? transformations.join(',') + '/'
      : '';
    
    return '$baseUrl/upload/$transformationString$imagePath';
  }

  /// Get thumbnail URL for an image
  String getThumbnailUrl(String originalUrl, {int size = 150}) {
    return getOptimizedImageUrl(
      originalUrl,
      width: size,
      height: size,
      quality: '80',
      format: 'auto',
    );
  }

  /// Get profile picture URL with optimal size
  String getProfilePictureUrl(String originalUrl, {int size = 200}) {
    return getOptimizedImageUrl(
      originalUrl,
      width: size,
      height: size,
      quality: '90',
      format: 'auto',
    );
  }

  /// Get memory image URL with optimal size
  String getMemoryImageUrl(String originalUrl, {int size = 800}) {
    return getOptimizedImageUrl(
      originalUrl,
      width: size,
      quality: '85',
      format: 'auto',
    );
  }
}

// Extension for easy access
extension CloudinaryExtension on File {
  Future<String?> uploadToCloudinary({String? folder}) async {
    return await CloudinaryService().uploadImage(this, folder: folder);
  }
}
