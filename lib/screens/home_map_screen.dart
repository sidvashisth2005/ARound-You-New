import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/widgets/custom_bottom_nav.dart';
import 'package:flutter/services.dart' show rootBundle;

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // Example: San Francisco
    zoom: 14.0,
  );
  
  String? _mapStyle;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    // Load the custom map style from assets
    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyle = string;
      _mapController?.setMapStyle(_mapStyle);
    });
  }

  // TODO: Populate this set with markers from Firestore
  final Set<Marker> _markers = {
    Marker(
      markerId: const MarkerId('memory1'),
      position: const LatLng(37.7749, -122.4194),
      infoWindow: const InfoWindow(title: 'First Memory!', snippet: 'A cool place.'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
    ),
     Marker(
      markerId: const MarkerId('user1'),
      position: const LatLng(37.7800, -122.4224),
      infoWindow: const InfoWindow(title: 'UrbanExplorer22'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_mapStyle != null) {
                controller.setMapStyle(_mapStyle);
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: SafeArea(
              child: Container(
                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                 decoration: BoxDecoration(
                   color: theme.colorScheme.surface.withOpacity(0.85),
                   borderRadius: BorderRadius.circular(30),
                   border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5))
                 ),
                 child: Row(
                   children: [
                     Icon(Icons.search, color: theme.colorScheme.primary),
                     const SizedBox(width: 10),
                     Expanded(child: Text('Search for memories or people...', style: theme.textTheme.bodyMedium)),
                     IconButton(
                       icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.primary),
                       onPressed: () => context.push('/notifications'),
                     )
                   ],
                 ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-memory'),
        backgroundColor: theme.colorScheme.secondary,
        child: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
        elevation: 10,
        shape: const CircleBorder(),
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
}
