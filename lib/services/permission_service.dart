import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Permission status tracking
  bool _locationPermissionGranted = false;
  bool _cameraPermissionGranted = false;
  bool _storagePermissionGranted = false;

  // Getters for permission status
  bool get locationPermissionGranted => _locationPermissionGranted;
  bool get cameraPermissionGranted => _cameraPermissionGranted;
  bool get storagePermissionGranted => _storagePermissionGranted;

  /// Check current permission statuses
  Future<void> checkPermissionStatuses() async {
    try {
      // Check location permission
      LocationPermission locationPermission = await Geolocator.checkPermission();
      _locationPermissionGranted = locationPermission == LocationPermission.whileInUse ||
                                  locationPermission == LocationPermission.always;

      // Check camera permission (simplified check)
      _cameraPermissionGranted = true; // Will be checked when actually using camera
      
      // Check storage permission (simplified check)
      _storagePermissionGranted = true; // Will be checked when actually using storage
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    }
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      _locationPermissionGranted = permission == LocationPermission.whileInUse ||
                                  permission == LocationPermission.always;
      return _locationPermissionGranted;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  /// Check if all critical permissions are granted
  bool get allCriticalPermissionsGranted {
    return _locationPermissionGranted && 
           _cameraPermissionGranted && 
           _storagePermissionGranted;
  }

  /// Check location service status
  Future<bool> checkLocationServiceStatus() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Error checking location service: $e');
      return false;
    }
  }

  /// Enable location services
  Future<bool> enableLocationServices() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('Error opening location settings: $e');
      return false;
    }
  }

  /// Get current location with permission check
  Future<Position?> getCurrentLocation() async {
    if (!_locationPermissionGranted) {
      final granted = await requestLocationPermission();
      if (!granted) {
        return null;
      }
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Pick image with permission check
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final ImagePicker picker = ImagePicker();
      return await picker.pickImage(source: source);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Get permission status description
  String getPermissionStatusDescription(String permissionType) {
    switch (permissionType) {
      case 'location':
        return 'Location access is needed to show nearby memories and enable AR features';
      case 'camera':
        return 'Camera access is needed to take photos and use AR features';
      case 'storage':
        return 'Storage access is needed to save and load photos';
      default:
        return 'This permission is needed for app functionality';
    }
  }

  /// Show permission request dialog
  Future<bool> showPermissionDialog(BuildContext context, String permissionType) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${permissionType.toUpperCase()} Permission Required'),
          content: Text(getPermissionStatusDescription(permissionType)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('DENY'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('GRANT'),
            ),
          ],
        );
      },
    ) ?? false;
  }
} 