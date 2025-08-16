import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/widgets/custom_bottom_nav.dart';
import 'package:around_you/services/permission_service.dart';
import 'package:flutter/services.dart' show rootBundle;

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco
    zoom: 14.0,
  );
  
  String? _mapStyle;
  CameraPosition? _initialPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Load map style
      final styleString = await rootBundle.loadString('assets/map_style.json');
      setState(() {
        _mapStyle = styleString;
      });

      // Get current location
      await _getCurrentLocation();
      
      // Load sample markers
      _loadSampleMarkers();
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize map: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permissionService = PermissionService();
      
      // Check if location permission is granted
      if (!permissionService.locationPermissionGranted) {
        final granted = await permissionService.requestLocationPermission();
        if (!granted) {
          setState(() {
            _errorMessage = 'Location permission is required to show your position on the map.';
            _isLoading = false;
          });
          return;
        }
      }

      // Check if location services are enabled
      final locationEnabled = await permissionService.checkLocationServiceStatus();
      if (!locationEnabled) {
        setState(() {
          _errorMessage = 'Please enable location services to see your position on the map.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      final position = await permissionService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _initialPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.0,
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _initialPosition = _defaultPosition;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location: $e';
        _initialPosition = _defaultPosition;
        _isLoading = false;
      });
    }
  }

  void _loadSampleMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('memory1'),
        position: const LatLng(37.7749, -122.4194),
        infoWindow: const InfoWindow(
          title: 'First Memory!', 
          snippet: 'A cool place in San Francisco.',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        onTap: () => _showMemoryDetails('memory1'),
      ),
      Marker(
        markerId: const MarkerId('user1'),
        position: const LatLng(37.7800, -122.4224),
        infoWindow: const InfoWindow(
          title: 'UrbanExplorer22', 
          snippet: 'Online now - 0.3 km away',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
        onTap: () => _showUserProfile('user1'),
      ),
    };
  }

  void _showMemoryDetails(String memoryId) {
    context.push('/memory/$memoryId');
  }

  void _showUserProfile(String userId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing profile of user $userId'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _refreshLocation() async {
    setState(() {
      _isLoading = true;
    });
    await _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Loading map...',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Map Error',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _refreshLocation,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition ?? _defaultPosition,
            markers: _markers,
            style: _mapStyle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              // Map controller is available if needed for future features
            },
          ),
          
          // Search Bar
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showSearchDialog(context),
                        child: Text(
                          'Search for memories or people...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.primary),
                      onPressed: () => context.push('/notifications'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Location Refresh Button
          Positioned(
            top: 130,
            right: 15,
            child: SafeArea(
              child: FloatingActionButton.small(
                onPressed: _refreshLocation,
                backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
                child: Icon(Icons.my_location, color: theme.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-memory'),
        backgroundColor: theme.colorScheme.secondary,
        elevation: 10,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNav(
        onItemTapped: (index) {
          switch (index) {
            case 0: break; // Already home
            case 1: context.push('/discover'); break;
            case 2: context.push('/achievements'); break;
            case 3: context.push('/profile'); break;
          }
        },
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search Memories'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Memory search coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Search People'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('People search coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.place),
              title: const Text('Search Places'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Place search coming soon!')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
