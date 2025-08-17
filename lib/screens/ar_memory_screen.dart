import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/services/ar_service.dart';
import 'package:around_you/services/location_service.dart';
import 'package:around_you/services/auth_service.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

class ARMemoryScreen extends StatefulWidget {
  final String? memoryType;
  final String? memoryText;
  final File? mediaFile;

  const ARMemoryScreen({
    super.key,
    this.memoryType,
    this.memoryText,
    this.mediaFile,
  });

  @override
  State<ARMemoryScreen> createState() => _ARMemoryScreenState();
}

class _ARMemoryScreenState extends State<ARMemoryScreen> with TickerProviderStateMixin {
  final ARService _arService = ARService();
  final LocationService _locationService = LocationService();
  final AuthService _authService = AuthService();

  late AnimationController _pulseAnimation;
  late AnimationController _fadeAnimation;
  late Animation<double> _pulseAnimationValue;
  late Animation<double> _fadeAnimationValue;

  String _selectedModelId = '';
  bool _isPlacingModel = false;
  bool _isModelPlaced = false;
  String? _currentLocation;
  List<ARMemory> _nearbyMemories = [];
  bool _isLoadingMemories = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadLocationData();
    _loadNearbyMemories();
    _selectDefaultModel();
  }

  void _initializeAnimations() {
    _pulseAnimation = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimationValue = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseAnimation,
      curve: Curves.easeInOut,
    ));

    _fadeAnimationValue = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimation,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation.repeat(reverse: true);
    _fadeAnimation.forward();
  }

  Future<void> _loadLocationData() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final address = await _locationService.getAddressFromCoordinates(
          LatLng(position.latitude, position.longitude),
        );
        setState(() {
          _currentLocation = address ?? '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (e) {
      debugPrint('Error loading location: $e');
    }
  }

  Future<void> _loadNearbyMemories() async {
    setState(() {
      _isLoadingMemories = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final memories = await _arService.getNearbyARMemories(
          center: LatLng(position.latitude, position.longitude),
          radiusInKm: 1.0, // Show memories within 1km
        );
        setState(() {
          _nearbyMemories = memories;
        });
      }
    } catch (e) {
      debugPrint('Error loading nearby memories: $e');
    } finally {
      setState(() {
        _isLoadingMemories = false;
      });
    }
  }

  void _selectDefaultModel() {
    final memoryType = widget.memoryType ?? 'text';
    final model = _arService.getModelByMemoryType(memoryType);
    if (model != null) {
      setState(() {
        _selectedModelId = model.id;
      });
    }
  }

  Future<void> _placeModel() async {
    if (_selectedModelId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a 3D model first')),
      );
      return;
    }

    setState(() {
      _isPlacingModel = true;
    });

    try {
      // Get current user info
      final userInfo = await _authService.getUserInfo();
      if (userInfo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to place memories')),
        );
        return;
      }

      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get your location')),
        );
        return;
      }

      final coordinates = LatLng(position.latitude, position.longitude);

      // Create AR memory in Firestore
      final success = await _arService.createARMemory(
        memoryType: widget.memoryType ?? 'text',
        title: widget.memoryText ?? 'AR Memory',
        description: widget.memoryText ?? 'AR Memory',
        coordinates: coordinates,
        userId: userInfo['userId']!,
        userName: userInfo['name']!,
        mediaFile: widget.mediaFile,
        textContent: widget.memoryText,
      );

      if (success) {
        setState(() {
          _isModelPlaced = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Memory placed successfully in AR world!')),
          );
          
          // Show success dialog
          _showSuccessDialog();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to place memory')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error placing model: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing model: $e')),
        );
      }
    } finally {
      setState(() {
        _isPlacingModel = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: const Text(
          'Memory Placed! 🎉',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Your ${widget.memoryType ?? 'memory'} has been placed in the AR world!',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Other users nearby can now see and interact with your memory.',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop(); // Go back to previous screen
            },
            child: const Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showModelSelector() {
    final availableModels = _arService.getAvailableModels();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select 3D Model',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: availableModels.length,
                itemBuilder: (context, index) {
                  final model = availableModels[index];
                  final isSelected = _selectedModelId == model.id;
                  
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getModelIcon(model.id),
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                      ),
                    ),
                    title: Text(
                      model.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      model.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected 
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedModelId = model.id;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _getModelIcon(String modelId) {
    switch (modelId) {
      case 'photo':
        return Icons.photo;
      case 'video':
        return Icons.videocam;
      case 'text':
        return Icons.text_fields;
      case 'audio':
        return Icons.mic;
      default:
        return Icons.view_in_ar;
    }
  }

  @override
  void dispose() {
    _pulseAnimation.dispose();
    _fadeAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AR Memory Placement',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // AR Camera View (Mock)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.purple.withOpacity(0.3),
                  Colors.orange.withOpacity(0.3),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimationValue,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimationValue.value,
                        child: Icon(
                          Icons.camera_alt,
                          size: 100,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'AR Camera View',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Point camera at a flat surface',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Memory Info Card
                  if (widget.memoryText != null || widget.mediaFile != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (widget.mediaFile != null) ...[
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: widget.memoryType == 'photo'
                                    ? Image.file(
                                        widget.mediaFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey.withOpacity(0.3),
                                        child: Icon(
                                          widget.memoryType == 'video' ? Icons.videocam : Icons.mic,
                                          color: Colors.white.withOpacity(0.7),
                                          size: 32,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (widget.memoryText != null)
                            Text(
                              widget.memoryText!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                    Colors.black,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Model Selector Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _showModelSelector,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                _getModelIcon(_selectedModelId),
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedModelId.isNotEmpty 
                                      ? 'Selected: ${_selectedModelId.toUpperCase()} Model'
                                      : 'Select 3D Model',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Place Model Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isPlacingModel || _isModelPlaced ? null : _placeModel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isModelPlaced 
                            ? Colors.green 
                            : Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isPlacingModel
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _isModelPlaced ? 'Memory Placed! ✅' : 'Place in AR World',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Nearby Memories Info
                  if (_nearbyMemories.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_nearbyMemories.length} memories nearby',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: const Text(
          'AR Memory Placement',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How it works:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• Select a 3D model that matches your memory type\n'
              '• Point your camera at a flat surface\n'
              '• Tap "Place in AR World" to position your memory\n'
              '• Your memory will be visible to other users nearby\n'
              '• Memories are stored with real GPS coordinates',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
