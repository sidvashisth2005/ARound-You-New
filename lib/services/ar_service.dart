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
  bool _isARMode = false;

  // Available 3D models mapped to memory types
  final Map<String, AR3DModel> _availableModels = {
    'photo': const AR3DModel(
      id: 'photo',
      name: 'Photo Frame',
      description: 'Display your photos in AR',
      modelPath: 'assets/models/photo_frame.glb',
      thumbnailPath: 'assets/thumbnails/photo_frame.png',
      category: 'Media',
      scale: 1.0,
      rotation: 0.0,
    ),
    'video': const AR3DModel(
      id: 'video',
      name: 'Video Player',
      description: 'Play videos in AR',
      modelPath: 'assets/models/video_frame.glb',
      thumbnailPath: 'assets/thumbnails/video_frame.png',
      category: 'Media',
      scale: 1.0,
      rotation: 0.0,
    ),
    'text': const AR3DModel(
      id: 'text',
      name: 'Text Display',
      description: 'Show text messages in AR',
      modelPath: 'assets/models/text_display.glb',
      thumbnailPath: 'assets/thumbnails/text_display.png',
      category: 'Text',
      scale: 1.0,
      rotation: 0.0,
    ),
    'audio': const AR3DModel(
      id: 'audio',
      name: 'Audio Player',
      description: 'Play audio in AR',
      modelPath: 'assets/models/audio_player.glb',
      thumbnailPath: 'assets/thumbnails/audio_player.png',
      category: 'Audio',
      scale: 1.0,
      rotation: 0.0,
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

  /// Enable AR mode for 3D model placement
  Future<bool> enableARMode() async {
    try {
      if (!isCameraReady) {
        final initialized = await initializeCamera();
        if (!initialized) return false;
      }
      
      _isARMode = true;
      debugPrint('✅ AR mode enabled');
      return true;
    } catch (e) {
      debugPrint('❌ Error enabling AR mode: $e');
      return false;
    }
  }

  /// Disable AR mode
  void disableARMode() {
    _isARMode = false;
    debugPrint('✅ AR mode disabled');
  }

  /// Check if AR mode is active
  bool get isARModeActive => _isARMode;

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

  /// Get AR overlay widget with 3D model placement
  Widget? getAROverlay({
    required String modelId,
    required Function(LatLng) onModelPlaced,
    required Function() onPlacementCancelled,
  }) {
    if (!isARModeActive) {
      debugPrint('❌ AR mode not active');
      return null;
    }

    return ARPlacementOverlay(
      modelId: modelId,
      onModelPlaced: onModelPlaced,
      onPlacementCancelled: onPlacementCancelled,
    );
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
      _isARMode = false;
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

  /// Get model by id
  AR3DModel? getModelById(String modelId) {
    return _availableModels[modelId];
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
    String? modelId,
  }) async {
    try {
      debugPrint('Creating AR memory: $memoryType at ${coordinates.latitude}, ${coordinates.longitude}');

      // Get the appropriate 3D model
      AR3DModel? model;
      if (modelId != null) {
        model = getModelById(modelId);
      }
      model ??= getModelByMemoryType(memoryType);
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
        'placementData': {
          'scale': model.scale,
          'rotation': model.rotation,
          'position': {
            'x': 0.0,
            'y': 0.0,
            'z': 0.0,
          },
        },
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

      debugPrint('✅ Found ${memories.length} nearby AR memories');
      return memories;
    } catch (e) {
      debugPrint('❌ Error fetching nearby AR memories: $e');
      return [];
    }
  }

  /// Calculate bounding box for efficient geospatial queries
  Map<String, double> _calculateBoundingBox(LatLng center, double radiusInKm) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers
    
    final latDelta = radiusInKm / earthRadius * (180.0 / math.pi);
    final lonDelta = radiusInKm / (earthRadius * math.cos(center.latitude * math.pi / 180.0)) * (180.0 / math.pi);
    
    return {
      'north': center.latitude + latDelta,
      'south': center.latitude - latDelta,
      'east': center.longitude + lonDelta,
      'west': center.longitude - lonDelta,
    };
  }

  /// Ensure camera health and reinitialize if needed
  Future<bool> ensureCameraHealth() async {
    if (isCameraReady) return true;
    
    debugPrint('⚠️ Camera health check failed, reinitializing...');
    return await initializeCamera();
  }

  /// Get camera status information
  Map<String, dynamic> getCameraStatus() {
    return {
      'isInitialized': _isInitialized,
      'isCameraReady': isCameraReady,
      'isARMode': _isARMode,
      'cameraCount': _cameras?.length ?? 0,
      'currentResolution': 'High',
    };
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

/// AR Placement Overlay Widget
class ARPlacementOverlay extends StatefulWidget {
  final String modelId;
  final Function(LatLng) onModelPlaced;
  final Function() onPlacementCancelled;

  const ARPlacementOverlay({
    super.key,
    required this.modelId,
    required this.onModelPlaced,
    required this.onPlacementCancelled,
  });

  @override
  State<ARPlacementOverlay> createState() => _ARPlacementOverlayState();
}

class _ARPlacementOverlayState extends State<ARPlacementOverlay> {
  bool _isPlacing = false;
  Offset _placementPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // AR placement guide
        Positioned.fill(
          child: GestureDetector(
            onTapDown: (details) {
              setState(() {
                _placementPosition = details.localPosition;
                _isPlacing = true;
              });
            },
            onTapUp: (details) {
              if (_isPlacing) {
                // Convert screen position to world coordinates
                final worldPosition = _screenToWorldCoordinates(_placementPosition);
                widget.onModelPlaced(worldPosition);
              }
            },
            child: Container(
              color: Colors.transparent,
              child: CustomPaint(
                painter: ARPlacementPainter(
                  placementPosition: _placementPosition,
                  isPlacing: _isPlacing,
                ),
              ),
            ),
          ),
        ),
        
        // Placement controls
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: widget.onPlacementCancelled,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.8),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _isPlacing ? () {
                  final worldPosition = _screenToWorldCoordinates(_placementPosition);
                  widget.onModelPlaced(worldPosition);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.8),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Place Model'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  LatLng _screenToWorldCoordinates(Offset screenPosition) {
    // This is a simplified conversion - in a real AR app, you'd use ARCore/ARKit
    // For now, we'll return a default position
    return const LatLng(0.0, 0.0);
  }
}

/// Custom painter for AR placement visualization
class ARPlacementPainter extends CustomPainter {
  final Offset placementPosition;
  final bool isPlacing;

  ARPlacementPainter({
    required this.placementPosition,
    required this.isPlacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isPlacing) return;

    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw placement indicator
    canvas.drawCircle(placementPosition, 30, paint);
    canvas.drawCircle(placementPosition, 35, paint);
    
    // Draw crosshair
    canvas.drawLine(
      Offset(placementPosition.dx - 40, placementPosition.dy),
      Offset(placementPosition.dx + 40, placementPosition.dy),
      paint,
    );
    canvas.drawLine(
      Offset(placementPosition.dx, placementPosition.dy - 40),
      Offset(placementPosition.dx, placementPosition.dy + 40),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Enhanced AR 3D Model class
class AR3DModel {
  final String id;
  final String name;
  final String description;
  final String modelPath;
  final String thumbnailPath;
  final String category;
  final double scale;
  final double rotation;

  const AR3DModel({
    required this.id,
    required this.name,
    required this.description,
    required this.modelPath,
    required this.thumbnailPath,
    required this.category,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'modelPath': modelPath,
      'thumbnailPath': thumbnailPath,
      'category': category,
      'scale': scale,
      'rotation': rotation,
    };
  }

  factory AR3DModel.fromMap(Map<String, dynamic> map) {
    return AR3DModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      modelPath: map['modelPath'] ?? '',
      thumbnailPath: map['thumbnailPath'] ?? '',
      category: map['category'] ?? '',
      scale: (map['scale'] ?? 1.0).toDouble(),
      rotation: (map['rotation'] ?? 0.0).toDouble(),
    );
  }
}

/// Enhanced AR Memory class
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
  final Map<String, dynamic> placementData;

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
    required this.placementData,
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
      additionalData: data['additionalData'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? false,
      viewCount: data['viewCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      placementData: data['placementData'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memoryType': memoryType,
      'title': title,
      'description': description,
      'coordinates': coordinates,
      'userId': userId,
      'userName': userName,
      'modelId': modelId,
      'modelPath': modelPath,
      'mediaUrl': mediaUrl,
      'textContent': textContent,
      'additionalData': additionalData,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'placementData': placementData,
    };
  }
}
