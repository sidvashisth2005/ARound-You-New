import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';

class MapPreloadService {
  static final MapPreloadService _instance = MapPreloadService._internal();
  factory MapPreloadService() => _instance;
  MapPreloadService._internal();

  String? _cachedMapStyle;
  Position? _cachedPosition;
  bool _loading = false;

  String? get mapStyle => _cachedMapStyle;
  Position? get position => _cachedPosition;

  Future<void> warmUp() async {
    if (_loading) return;
    _loading = true;
    try {
      // Preload map style
      _cachedMapStyle ??= await rootBundle.loadString('assets/map_style.json');

      // Preload location (best-effort)
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          _cachedPosition ??= await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
          );
        }
      }
    } catch (_) {
      // Best-effort warm up. Ignore failures
    } finally {
      _loading = false;
    }
  }
}