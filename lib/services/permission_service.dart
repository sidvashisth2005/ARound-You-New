import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Required permissions for the app
  final List<Permission> _requiredPermissions = [
    Permission.location,
    Permission.camera,
    Permission.microphone,
    Permission.storage,
    Permission.photos,
    Permission.notification,
  ];

  /// Check and request all required permissions
  Future<Map<Permission, PermissionStatus>> checkPermissionStatuses() async {
    Map<Permission, PermissionStatus> statuses = {};
    
    for (Permission permission in _requiredPermissions) {
      statuses[permission] = await permission.status;
    }
    
    return statuses;
  }

  /// Request all required permissions
  Future<Map<Permission, PermissionStatus>> requestPermissions() async {
    Map<Permission, PermissionStatus> results = {};
    
    for (Permission permission in _requiredPermissions) {
      results[permission] = await permission.request();
    }
    
    return results;
  }

  /// Check if all required permissions are granted
  Future<bool> areAllPermissionsGranted() async {
    final statuses = await checkPermissionStatuses();
    
    for (Permission permission in _requiredPermissions) {
      if (statuses[permission] != PermissionStatus.granted) {
        return false;
      }
    }
    
    return true;
  }

  /// Check location permission specifically
  Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status == PermissionStatus.granted;
  }

  /// Request location permission and enable location services
  Future<bool> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Request to enable location services
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) {
          return false;
        }
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Open app settings to enable location permission
        await openAppSettings();
        return false;
      }

      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  /// Check camera permission
  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  /// Check microphone permission
  Future<bool> isMicrophonePermissionGranted() async {
    final status = await Permission.microphone.status;
    return status == PermissionStatus.granted;
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  /// Check storage permission
  Future<bool> isStoragePermissionGranted() async {
    final status = await Permission.storage.status;
    return status == PermissionStatus.granted;
  }

  /// Request storage permission
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }

  /// Check photos permission
  Future<bool> isPhotosPermissionGranted() async {
    final status = await Permission.photos.status;
    return status == PermissionStatus.granted;
  }

  /// Request photos permission
  Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.request();
    return status == PermissionStatus.granted;
  }

  /// Check notification permission
  Future<bool> isNotificationPermissionGranted() async {
    final status = await Permission.notification.status;
    return status == PermissionStatus.granted;
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status == PermissionStatus.granted;
  }

  /// Get current location with permission check
  Future<Position?> getCurrentLocation() async {
    try {
      // Check location permission first
      if (!await isLocationPermissionGranted()) {
        final granted = await requestLocationPermission();
        if (!granted) {
          return null;
        }
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Show permission explanation dialog
  Future<bool> showPermissionExplanationDialog(
    BuildContext context,
    String title,
    String message,
    String permissionName,
  ) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Show settings dialog when permissions are permanently denied
  Future<void> showSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          title: const Text(
            'Permissions Required',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'This app needs access to location, camera, and other permissions to function properly. '
            'Please enable them in your device settings.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Initialize all permissions on app startup
  Future<void> initializePermissions() async {
    try {
      // Request all permissions
      final results = await requestPermissions();
      
      // Check if any permissions were denied
      bool hasDeniedPermissions = false;
      for (Permission permission in _requiredPermissions) {
               if (results[permission] == PermissionStatus.denied ||
           results[permission] == PermissionStatus.permanentlyDenied) {
          hasDeniedPermissions = true;
          break;
        }
      }
      
      if (hasDeniedPermissions) {
        debugPrint('Some permissions were denied');
      }
      
      // Enable location services if location permission is granted
      if (results[Permission.location] == PermissionStatus.granted) {
        await _enableLocationServices();
      }
      
    } catch (e) {
      debugPrint('Error initializing permissions: $e');
    }
  }

  /// Enable location services
  Future<void> _enableLocationServices() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try to enable location services
        await Geolocator.openLocationSettings();
      }
    } catch (e) {
      debugPrint('Error enabling location services: $e');
    }
  }

  /// Get permission status for a specific permission
  Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    return await permission.status;
  }

  /// Check if a specific permission is permanently denied
  Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status == PermissionStatus.permanentlyDenied;
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
} 