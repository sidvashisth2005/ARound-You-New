import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'permission_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final PermissionService _permissionService = PermissionService();
  Position? _currentPosition;
  bool _isLocationEnabled = false;
  bool _isInitialized = false;
  Stream<Position>? _locationStream;

  // Mock nearby users data - in real app this would come from Firebase
  final List<Map<String, dynamic>> _mockNearbyUsers = [
    {
      'id': 'user1',
      'name': 'Sarah Chen',
      'avatar': '👩‍💼',
      'distance': 0.2,
      'status': 'online',
      'lastSeen': '2 min ago',
      'interests': ['Photography', 'Coffee', 'Art'],
      'isOnline': true,
      'location': const LatLng(37.7749, -122.4194),
      'lastUpdated': DateTime.now().subtract(const Duration(minutes: 2)),
    },
    {
      'id': 'user2',
      'name': 'Mike Rodriguez',
      'avatar': '👨‍🎨',
      'distance': 0.5,
      'status': 'online',
      'lastSeen': '5 min ago',
      'interests': ['Music', 'Travel', 'Food'],
      'isOnline': true,
      'location': const LatLng(37.7849, -122.4094),
      'lastUpdated': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'id': 'user3',
      'name': 'Emma Thompson',
      'avatar': '👩‍🎓',
      'distance': 0.8,
      'status': 'away',
      'lastSeen': '15 min ago',
      'interests': ['Reading', 'Yoga', 'Nature'],
      'isOnline': false,
      'location': const LatLng(37.7649, -122.4294),
      'lastUpdated': DateTime.now().subtract(const Duration(minutes: 15)),
    },
    {
      'id': 'user4',
      'name': 'Alex Kim',
      'avatar': '👨‍💻',
      'distance': 1.2,
      'status': 'online',
      'lastSeen': '1 min ago',
      'interests': ['Technology', 'Gaming', 'Fitness'],
      'isOnline': true,
      'location': const LatLng(37.7549, -122.4394),
      'lastUpdated': DateTime.now().subtract(const Duration(minutes: 1)),
    },
    {
      'id': 'user5',
      'name': 'Lisa Park',
      'avatar': '👩‍🍳',
      'distance': 1.5,
      'status': 'away',
      'lastSeen': '25 min ago',
      'interests': ['Cooking', 'Gardening', 'Pets'],
      'isOnline': false,
      'location': const LatLng(37.7449, -122.4494),
      'lastUpdated': DateTime.now().subtract(const Duration(minutes: 25)),
    },
  ];

  /// Initialize location service - starts background processing immediately
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      debugPrint('📍 Initializing location service...');
      
      // Check and request location permission
      final hasPermission = await _permissionService.isLocationPermissionGranted();
      if (!hasPermission) {
        debugPrint('📍 Requesting location permission...');
        final granted = await _permissionService.requestLocationPermission();
        if (!granted) {
          debugPrint('❌ Location permission denied');
          return false;
        }
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location services disabled');
        // Don't open settings automatically, just return false
        return false;
      }

      _isLocationEnabled = true;
      _isInitialized = true;
      
      // Start background location processing
      _startBackgroundLocationProcessing();
      
      debugPrint('✅ Location service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error initializing location service: $e');
      return false;
    }
  }

  /// Start background location processing
  void _startBackgroundLocationProcessing() async {
    try {
      // Get initial location
      await _getInitialLocation();
      
      // Start location stream for continuous updates
      _startLocationStream();
    } catch (e) {
      debugPrint('❌ Error in background location processing: $e');
    }
  }

  /// Get initial location with better error handling
  Future<void> _getInitialLocation() async {
    try {
      debugPrint('📍 Getting initial location...');
      
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15), // Increased timeout
      );
      
      debugPrint('✅ Initial location obtained: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
    } catch (e) {
      debugPrint('❌ Error getting initial location: $e');
      
      // Try with lower accuracy if high accuracy fails
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );
        debugPrint('✅ Location obtained with medium accuracy');
      } catch (e2) {
        debugPrint('❌ Failed to get location with medium accuracy: $e2');
      }
    }
  }

  /// Start location stream for continuous updates
  void _startLocationStream() {
    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _locationStream = Geolocator.getPositionStream(locationSettings: locationSettings);
      
      // Listen to location updates
      _locationStream?.listen(
        (Position position) {
          _currentPosition = position;
          debugPrint('📍 Location updated: ${position.latitude}, ${position.longitude}');
        },
        onError: (error) {
          debugPrint('❌ Location stream error: $error');
        },
      );
      
      debugPrint('✅ Location stream started');
    } catch (e) {
      debugPrint('❌ Error starting location stream: $e');
    }
  }

  /// Get current location with cached result
  Future<Position?> getCurrentLocation() async {
    try {
      // If we have a recent cached position, return it
      if (_currentPosition != null) {
        final timeSinceLastUpdate = DateTime.now().difference(_currentPosition!.timestamp!);
        if (timeSinceLastUpdate.inMinutes < 5) {
          debugPrint('📍 Returning cached location');
          return _currentPosition;
        }
      }

      // If not initialized, initialize first
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) {
          return null;
        }
      }

      // If we still don't have a position, try to get one
      if (_currentPosition == null) {
        await _getInitialLocation();
      }

      return _currentPosition;
    } catch (e) {
      debugPrint('❌ Error getting current location: $e');
      return null;
    }
  }

  /// Get last known location
  Position? get lastKnownLocation => _currentPosition;

  /// Check if location is enabled
  bool get isLocationEnabled => _isLocationEnabled;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Get nearby users based on current location
  Future<List<Map<String, dynamic>>> getNearbyUsers({double radiusInKm = 5.0}) async {
    try {
      final currentLocation = await getCurrentLocation();
      if (currentLocation == null) {
        debugPrint('❌ No current location available for nearby users');
        return [];
      }

      final currentLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
      
      // Filter users within the specified radius
      final nearbyUsers = _mockNearbyUsers.where((user) {
        final userLatLng = user['location'] as LatLng;
        final distance = _calculateDistance(currentLatLng, userLatLng);
        return distance <= radiusInKm;
      }).toList();

      // Sort by distance
      nearbyUsers.sort((a, b) {
        final distanceA = _calculateDistance(currentLatLng, a['location'] as LatLng);
        final distanceB = _calculateDistance(currentLatLng, b['location'] as LatLng);
        return distanceA.compareTo(distanceB);
      });

      // Update distances based on current location
      for (var user in nearbyUsers) {
        final userLatLng = user['location'] as LatLng;
        final distance = _calculateDistance(currentLatLng, userLatLng);
        user['distance'] = distance;
      }

      debugPrint('📍 Found ${nearbyUsers.length} nearby users');
      return nearbyUsers;
    } catch (e) {
      debugPrint('❌ Error getting nearby users: $e');
      return [];
    }
  }

  /// Calculate distance between two points
  double _calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    ) / 1000; // Convert to kilometers
  }

  /// Get user's current location as LatLng
  Future<LatLng?> getCurrentLatLng() async {
    final position = await getCurrentLocation();
    if (position != null) {
      return LatLng(position.latitude, position.longitude);
    }
    return null;
  }

  /// Start location updates
  Stream<Position>? startLocationUpdates() {
    return _locationStream;
  }

  /// Stop location updates
  void stopLocationUpdates() {
    // Stream will automatically close when not listened to
  }

  /// Get location permission status
  Future<bool> hasLocationPermission() async {
    return await _permissionService.isLocationPermissionGranted();
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    return await _permissionService.requestLocationPermission();
  }

  /// Get formatted address from coordinates (simplified)
  Future<String?> getAddressFromCoordinates(LatLng coordinates) async {
    try {
      // For now, return a simple formatted string
      // In a real app, you'd use a geocoding service
      return '${coordinates.latitude.toStringAsFixed(4)}, ${coordinates.longitude.toStringAsFixed(4)}';
    } catch (e) {
      debugPrint('❌ Error getting address: $e');
      return null;
    }
  }

  /// Get distance between two points in a human-readable format
  String getFormattedDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()}m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceInKm.round()}km';
    }
  }

  /// Check if location is within a certain radius
  bool isWithinRadius(LatLng center, LatLng point, double radiusInKm) {
    final distance = _calculateDistance(center, point);
    return distance <= radiusInKm;
  }

  /// Get mock user by ID
  Map<String, dynamic>? getMockUserById(String userId) {
    try {
      return _mockNearbyUsers.firstWhere((user) => user['id'] == userId);
    } catch (e) {
      return null;
    }
  }

  /// Update mock user location
  void updateMockUserLocation(String userId, LatLng newLocation) {
    try {
      final userIndex = _mockNearbyUsers.indexWhere((user) => user['id'] == userId);
      if (userIndex != -1) {
        _mockNearbyUsers[userIndex]['location'] = newLocation;
        _mockNearbyUsers[userIndex]['lastUpdated'] = DateTime.now();
      }
    } catch (e) {
      debugPrint('❌ Error updating mock user location: $e');
    }
  }

  /// Get all mock users
  List<Map<String, dynamic>> getAllMockUsers() {
    return List.from(_mockNearbyUsers);
  }

  /// Add a new mock user
  void addMockUser(Map<String, dynamic> user) {
    _mockNearbyUsers.add(user);
  }

  /// Remove a mock user
  void removeMockUser(String userId) {
    _mockNearbyUsers.removeWhere((user) => user['id'] == userId);
  }
}
