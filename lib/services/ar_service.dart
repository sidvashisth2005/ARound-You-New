import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:around_you/services/cloudinary_service.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:math' as math;

class ARService {
  static final ARService _instance = ARService._internal();
  factory ARService() => _instance;
  ARService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  // Available 3D models mapped to memory types
  final Map<String, AR3DModel> _availableModels = {
    'photo': const AR3DModel(
      id: 'photo',
      name: 'Photo Frame',
      description: 'Display your photos in AR',
      modelPath: 'assets/models/photo_frame.glb',
      thumbnailPath: 'assets/thumbnails/photo_frame.png',
      category: 'Media',
    ),
    'video': const AR3DModel(
      id: 'video',
      name: 'Video Player',
      description: 'Play videos in AR',
      modelPath: 'assets/models/video_frame.glb',
      thumbnailPath: 'assets/thumbnails/video_frame.png',
      category: 'Media',
    ),
    'text': const AR3DModel(
      id: 'text',
      name: 'Text Display',
      description: 'Show text messages in AR',
      modelPath: 'assets/models/text_display.glb',
      thumbnailPath: 'assets/thumbnails/text_display.png',
      category: 'Text',
    ),
    'audio': const AR3DModel(
      id: 'audio',
      name: 'Audio Player',
      description: 'Play audio in AR',
      modelPath: 'assets/models/audio_player.glb',
      thumbnailPath: 'assets/thumbnails/audio_player.png',
      category: 'Audio',
    ),
  };

  /// Initialize camera for AR functionality
  Future<bool> initializeCamera() async {
    try {
      if (_isInitialized && isCameraReady) return true;
      
      // Dispose existing camera if any
      if (_cameraController != null) {
        await disposeCamera();
      }
      
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('❌ No cameras available');
        return false;
      }

      // Use back camera for AR
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      _isInitialized = true;
      
      debugPrint('✅ Camera initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error initializing camera: $e');
      // Cleanup on error
      await disposeCamera();
      return false;
    }
  }

  /// Get camera controller safely
  CameraController? get cameraController {
    if (isCameraReady) {
      return _cameraController;
    }
    debugPrint('⚠️ Camera controller not ready');
    return null;
  }

  /// Get camera controller with health check
  Future<CameraController?> getCameraControllerSafe() async {
    if (await ensureCameraHealth()) {
      return _cameraController;
    }
    return null;
  }

  /// Check if camera is initialized
  bool get isInitialized => _isInitialized;

  /// Check if camera is ready for use
  bool get isCameraReady => _isInitialized && _cameraController != null && _cameraController!.value.isInitialized;

  /// Get camera preview widget
  Widget? getCameraPreview() {
    if (!isCameraReady) {
      debugPrint('❌ Camera not ready for preview');
      return null;
    }
    
    return CameraPreview(_cameraController!);
  }

  /// Dispose camera resources
  Future<void> disposeCamera() async {
    try {
      if (_cameraController != null) {
        if (_cameraController!.value.isInitialized) {
          await _cameraController!.dispose();
        }
        _cameraController = null;
      }
      _isInitialized = false;
      _cameras = null;
      debugPrint('✅ Camera disposed successfully');
    } catch (e) {
      debugPrint('❌ Error disposing camera: $e');
    }
  }

  /// Cleanup all resources
  Future<void> cleanup() async {
    await disposeCamera();
    debugPrint('✅ AR Service cleaned up');
  }

  /// Take a photo for AR memory
  Future<File?> takePhoto() async {
    try {
      if (!isCameraReady) {
        debugPrint('❌ Camera not ready for taking photo');
        return null;
      }

      final image = await _cameraController!.takePicture();
      return File(image.path);
    } catch (e) {
      debugPrint('❌ Error taking photo: $e');
      return null;
    }
  }

  /// Get available models
  List<AR3DModel> getAvailableModels() {
    return _availableModels.values.toList();
  }

  /// Get model by memory type
  AR3DModel? getModelByMemoryType(String memoryType) {
    return _availableModels[memoryType.toLowerCase()];
  }

  /// Create and store AR memory in Firestore
  Future<bool> createARMemory({
    required String memoryType,
    required String title,
    required String description,
    required LatLng coordinates,
    required String userId,
    required String userName,
    File? mediaFile,
    String? mediaUrl,
    String? textContent,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      debugPrint('Creating AR memory: $memoryType at ${coordinates.latitude}, ${coordinates.longitude}');

      // Get the appropriate 3D model
      final model = getModelByMemoryType(memoryType);
      if (model == null) {
        debugPrint('❌ No 3D model found for memory type: $memoryType');
        return false;
      }

      // Upload media if provided
      String? uploadedMediaUrl = mediaUrl;
      if (mediaFile != null) {
        switch (memoryType.toLowerCase()) {
          case 'photo':
            uploadedMediaUrl = await _cloudinaryService.uploadImage(mediaFile);
            break;
          case 'video':
            uploadedMediaUrl = await _cloudinaryService.uploadVideo(mediaFile);
            break;
          case 'audio':
            uploadedMediaUrl = await _cloudinaryService.uploadAudio(mediaFile);
            break;
        }
      }

      // Create AR memory document
      final arMemoryData = {
        'memoryType': memoryType.toLowerCase(),
        'title': title,
        'description': description,
        'coordinates': GeoPoint(coordinates.latitude, coordinates.longitude),
        'userId': userId,
        'userName': userName,
        'modelId': model.id,
        'modelPath': model.modelPath,
        'mediaUrl': uploadedMediaUrl,
        'textContent': textContent,
        'additionalData': additionalData ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'viewCount': 0,
        'likeCount': 0,
      };

      // Store in Firestore
      await _firestore.collection('ar_memories').add(arMemoryData);

      debugPrint('✅ AR memory created successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating AR memory: $e');
      return false;
    }
  }

  /// Get AR memories near a location
  Future<List<ARMemory>> getNearbyARMemories({
    required LatLng center,
    double radiusInKm = 5.0,
    int limit = 50,
  }) async {
    try {
      debugPrint('Fetching AR memories near ${center.latitude}, ${center.longitude}');

      // Calculate bounding box for efficient querying
      final bounds = _calculateBoundingBox(center, radiusInKm);

      final querySnapshot = await _firestore
          .collection('ar_memories')
          .where('isActive', isEqualTo: true)
          .where('coordinates', isGreaterThanOrEqualTo: GeoPoint(bounds['south']!, bounds['west']!))
          .where('coordinates', isLessThanOrEqualTo: GeoPoint(bounds['north']!, bounds['east']!))
          .orderBy('coordinates')
          .limit(limit)
          .get();

      final memories = <ARMemory>[];
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final coordinates = data['coordinates'] as GeoPoint;
        final memoryLocation = LatLng(coordinates.latitude, coordinates.longitude);
        
        // Calculate actual distance and filter
        final distance = Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          coordinates.latitude,
          coordinates.longitude,
        ) / 1000; // Convert to kilometers

        if (distance <= radiusInKm) {
          memories.add(ARMemory.fromFirestore(doc));
        }
      }

      // Sort by distance
      memories.sort((a, b) {
        final distanceA = Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          a.coordinates.latitude,
          a.coordinates.longitude,
        );
        final distanceB = Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          b.coordinates.latitude,
          b.coordinates.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      debugPrint('✅ Found ${memories.length} AR memories nearby');
      return memories;
    } catch (e) {
      debugPrint('❌ Error fetching nearby AR memories: $e');
      return [];
    }
  }

  /// Get AR memories by user
  Future<List<ARMemory>> getUserARMemories(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('ar_memories')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => ARMemory.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching user AR memories: $e');
      return [];
    }
  }

  /// Update AR memory
  Future<bool> updateARMemory({
    required String memoryId,
    String? title,
    String? description,
    String? mediaUrl,
    String? textContent,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (mediaUrl != null) updateData['mediaUrl'] = mediaUrl;
      if (textContent != null) updateData['textContent'] = textContent;
      if (additionalData != null) updateData['additionalData'] = additionalData;

      await _firestore.collection('ar_memories').doc(memoryId).update(updateData);
      debugPrint('✅ AR memory updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating AR memory: $e');
      return false;
    }
  }

  /// Delete AR memory
  Future<bool> deleteARMemory(String memoryId) async {
    try {
      await _firestore.collection('ar_memories').doc(memoryId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ AR memory deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting AR memory: $e');
      return false;
    }
  }

  /// Increment view count
  Future<void> incrementViewCount(String memoryId) async {
    try {
      await _firestore.collection('ar_memories').doc(memoryId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('❌ Error incrementing view count: $e');
    }
  }

  /// Like/unlike AR memory
  Future<bool> toggleLike(String memoryId, String userId) async {
    try {
      final docRef = _firestore.collection('ar_memories').doc(memoryId);
      final likeRef = docRef.collection('likes').doc(userId);

      final likeDoc = await likeRef.get();
      if (likeDoc.exists) {
        // Unlike
        await likeRef.delete();
        await docRef.update({
          'likeCount': FieldValue.increment(-1),
        });
        debugPrint('✅ AR memory unliked');
        return false;
      } else {
        // Like
        await likeRef.set({
          'userId': userId,
          'likedAt': FieldValue.serverTimestamp(),
        });
        await docRef.update({
          'likeCount': FieldValue.increment(1),
        });
        debugPrint('✅ AR memory liked');
        return true;
      }
    } catch (e) {
      debugPrint('❌ Error toggling like: $e');
      return false;
    }
  }

  /// Check if user liked a memory
  Future<bool> isLikedByUser(String memoryId, String userId) async {
    try {
      final likeDoc = await _firestore
          .collection('ar_memories')
          .doc(memoryId)
          .collection('likes')
          .doc(userId)
          .get();
      return likeDoc.exists;
    } catch (e) {
      debugPrint('❌ Error checking like status: $e');
      return false;
    }
  }

  /// Calculate bounding box for efficient querying
  Map<String, double> _calculateBoundingBox(LatLng center, double radiusInKm) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final double latDelta = radiusInKm / earthRadius * (180 / math.pi);
    final double lonDelta = radiusInKm / earthRadius * (180 / math.pi) / math.cos(center.latitude * math.pi / 180);

    return {
      'north': center.latitude + latDelta,
      'south': center.latitude - latDelta,
      'east': center.longitude + lonDelta,
      'west': center.longitude - lonDelta,
    };
  }

  /// Get real-time updates of nearby AR memories
  Stream<List<ARMemory>> getNearbyARMemoriesStream({
    required LatLng center,
    double radiusInKm = 5.0,
  }) {
    final bounds = _calculateBoundingBox(center, radiusInKm);

    return _firestore
        .collection('ar_memories')
        .where('isActive', isEqualTo: true)
        .where('coordinates', isGreaterThanOrEqualTo: GeoPoint(bounds['south']!, bounds['west']!))
        .where('coordinates', isLessThanOrEqualTo: GeoPoint(bounds['north']!, bounds['east']!))
        .orderBy('coordinates')
        .snapshots()
        .map((snapshot) {
      final memories = <ARMemory>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final coordinates = data['coordinates'] as GeoPoint;
        final memoryLocation = LatLng(coordinates.latitude, coordinates.longitude);
        
        final distance = Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          coordinates.latitude,
          coordinates.longitude,
        ) / 1000;

        if (distance <= radiusInKm) {
          memories.add(ARMemory.fromFirestore(doc));
        }
      }

      memories.sort((a, b) {
        final distanceA = Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          a.coordinates.latitude,
          a.coordinates.longitude,
        );
        final distanceB = Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          b.coordinates.latitude,
          b.coordinates.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      return memories;
    });
  }

  /// Handle camera errors and attempt recovery
  Future<bool> handleCameraError() async {
    try {
      debugPrint('🔄 Attempting to recover from camera error...');
      await disposeCamera();
      await Future.delayed(const Duration(seconds: 1)); // Wait before retry
      return await initializeCamera();
    } catch (e) {
      debugPrint('❌ Failed to recover from camera error: $e');
      return false;
    }
  }

  /// Handle camera errors with multiple recovery attempts
  Future<bool> handleCameraErrorWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('🔄 Camera recovery attempt $attempt/$maxRetries...');
        await disposeCamera();
        await Future.delayed(Duration(seconds: attempt)); // Progressive delay
        
        if (await initializeCamera()) {
          debugPrint('✅ Camera recovered successfully on attempt $attempt');
          return true;
        }
      } catch (e) {
        debugPrint('❌ Camera recovery attempt $attempt failed: $e');
      }
    }
    
    debugPrint('❌ Failed to recover camera after $maxRetries attempts');
    return false;
  }

  /// Check camera health and reinitialize if needed
  Future<bool> ensureCameraHealth() async {
    if (!isCameraReady) {
      debugPrint('🔄 Camera not healthy, reinitializing...');
      return await initializeCamera();
    }
    return true;
  }

  /// Handle app lifecycle changes
  Future<void> onAppLifecycleChanged(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        debugPrint('📱 App going to background, disposing camera...');
        await disposeCamera();
        break;
      case AppLifecycleState.resumed:
        debugPrint('📱 App resumed, reinitializing camera...');
        await initializeCamera();
        break;
      default:
        break;
    }
  }

  /// Pause camera (for temporary suspension)
  Future<void> pauseCamera() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController!.pausePreview();
        debugPrint('⏸️ Camera paused');
      } catch (e) {
        debugPrint('❌ Error pausing camera: $e');
      }
    }
  }

  /// Resume camera (after pause)
  Future<void> resumeCamera() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController!.resumePreview();
        debugPrint('▶️ Camera resumed');
      } catch (e) {
        debugPrint('❌ Error resuming camera: $e');
      }
    }
  }

  /// Check camera permissions and handle accordingly
  Future<bool> checkCameraPermissions() async {
    try {
      // This would typically integrate with your permission service
      // For now, we'll assume permissions are granted if we can access cameras
      final cameras = await availableCameras();
      return cameras.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Camera permission check failed: $e');
      return false;
    }
  }

  /// Initialize camera with permission check
  Future<bool> initializeCameraWithPermissions() async {
    if (!await checkCameraPermissions()) {
      debugPrint('❌ Camera permissions not granted');
      return false;
    }
    return await initializeCamera();
  }

  /// Get detailed camera status for debugging
  Map<String, dynamic> getCameraStatus() {
    return {
      'isInitialized': _isInitialized,
      'hasCameraController': _cameraController != null,
      'isCameraReady': isCameraReady,
      'cameraCount': _cameras?.length ?? 0,
      'cameraState': _cameraController?.value.toString() ?? 'null',
    };
  }

  /// Log camera status for debugging
  void logCameraStatus() {
    final status = getCameraStatus();
    debugPrint('📷 Camera Status: $status');
  }

  /// Validate camera setup
  Future<bool> validateCameraSetup() async {
    try {
      logCameraStatus();
      
      if (!_isInitialized) {
        debugPrint('❌ Camera not initialized');
        return false;
      }
      
      if (_cameraController == null) {
        debugPrint('❌ Camera controller is null');
        return false;
      }
      
      if (!_cameraController!.value.isInitialized) {
        debugPrint('❌ Camera controller not initialized');
        return false;
      }
      
      debugPrint('✅ Camera setup is valid');
      return true;
    } catch (e) {
      debugPrint('❌ Camera validation failed: $e');
      return false;
    }
  }

  /// Monitor camera state changes
  void addCameraStateListener(VoidCallback listener) {
    _cameraController?.addListener(listener);
  }

  /// Remove camera state listener
  void removeCameraStateListener(VoidCallback listener) {
    _cameraController?.removeListener(listener);
  }
}

/// AR 3D Model class
class AR3DModel {
  final String id;
  final String name;
  final String description;
  final String modelPath;
  final String thumbnailPath;
  final String category;

  const AR3DModel({
    required this.id,
    required this.name,
    required this.description,
    required this.modelPath,
    required this.thumbnailPath,
    required this.category,
  });
}

/// AR Memory class representing a memory placed in AR
class ARMemory {
  final String id;
  final String memoryType;
  final String title;
  final String description;
  final LatLng coordinates;
  final String userId;
  final String userName;
  final String modelId;
  final String modelPath;
  final String? mediaUrl;
  final String? textContent;
  final Map<String, dynamic> additionalData;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int viewCount;
  final int likeCount;

  ARMemory({
    required this.id,
    required this.memoryType,
    required this.title,
    required this.description,
    required this.coordinates,
    required this.userId,
    required this.userName,
    required this.modelId,
    required this.modelPath,
    this.mediaUrl,
    this.textContent,
    required this.additionalData,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.viewCount,
    required this.likeCount,
  });

  factory ARMemory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final coordinates = data['coordinates'] as GeoPoint;
    
    return ARMemory(
      id: doc.id,
      memoryType: data['memoryType'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      coordinates: LatLng(coordinates.latitude, coordinates.longitude),
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      modelId: data['modelId'] ?? '',
      modelPath: data['modelPath'] ?? '',
      mediaUrl: data['mediaUrl'],
      textContent: data['textContent'],
      additionalData: Map<String, dynamic>.from(data['additionalData'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      viewCount: data['viewCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memoryType': memoryType,
      'title': title,
      'description': description,
      'coordinates': GeoPoint(coordinates.latitude, coordinates.longitude),
      'userId': userId,
      'userName': userName,
      'modelId': modelId,
      'modelPath': modelPath,
      'mediaUrl': mediaUrl,
      'textContent': textContent,
      'additionalData': additionalData,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'viewCount': viewCount,
      'likeCount': likeCount,
    };
  }
}
