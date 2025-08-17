import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/services/ar_service.dart';
import 'package:around_you/services/location_service.dart';
import 'package:around_you/services/auth_service.dart';
import 'package:around_you/widgets/wormhole_animation.dart';
import 'package:around_you/theme/theme.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

class ARMemoryScreen extends StatefulWidget {
  final String? memoryType;
  final String? memoryText;
  final File? mediaFile;
  final AR3DModel? selected3DModel;

  const ARMemoryScreen({
    super.key,
    this.memoryType,
    this.memoryText,
    this.mediaFile,
    this.selected3DModel,
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
  bool _showWormhole = false;
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
    _activateWormhole();
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

  void _activateWormhole() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showWormhole = true;
        });
      }
    });
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
    if (widget.selected3DModel != null) {
      setState(() {
        _selectedModelId = widget.selected3DModel!.id;
      });
    } else {
      final memoryType = widget.memoryType ?? 'text';
      final model = _arService.getModelByMemoryType(memoryType);
      if (model != null) {
        setState(() {
          _selectedModelId = model.id;
        });
      }
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to place memories')),
          );
        }
        return;
      }

      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to get your location')),
          );
        }
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
        backgroundColor: AppTheme.primaryDark.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Memory Placed! 🎉',
          style: TextStyle(
            color: AppTheme.pureWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.accentGold,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your ${widget.memoryType ?? 'memory'} has been placed in the AR world!',
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Other users nearby can now see and interact with your memory.',
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.6),
                fontSize: 12,
              ),
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
            child: Text(
              'Continue',
              style: TextStyle(
                color: AppTheme.accentGold,
                fontWeight: FontWeight.w600,
              ),
            ),
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
          color: AppTheme.primaryDark.withValues(alpha: 0.95),
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
                color: AppTheme.pureWhite.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select 3D Model',
              style: TextStyle(
                color: AppTheme.pureWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
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
                            ? AppTheme.accentGold.withValues(alpha: 0.2)
                            : AppTheme.pureWhite.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? AppTheme.accentGold
                              : AppTheme.lightBlue.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          model.thumbnailPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.view_in_ar,
                              color: isSelected 
                                  ? AppTheme.accentGold
                                  : AppTheme.pureWhite.withValues(alpha: 0.7),
                              size: 24,
                            );
                          },
                        ),
                      ),
                    ),
                    title: Text(
                      model.name,
                      style: TextStyle(
                        color: AppTheme.pureWhite,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      model.description,
                      style: TextStyle(
                        color: AppTheme.pureWhite.withValues(alpha: 0.7),
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: AppTheme.accentGold,
                          )
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

  @override
  void dispose() {
    _pulseAnimation.dispose();
    _fadeAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AR Memory Placement',
          style: TextStyle(
            color: AppTheme.pureWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.pureWhite),
            onPressed: _showModelSelector,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // AR Camera Preview Area
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.lightBlue.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: AppTheme.premiumShadows,
                    ),
                    child: Stack(
                      children: [
                        // Camera preview placeholder
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 64,
                                color: AppTheme.pureWhite.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'AR Camera View',
                                style: TextStyle(
                                  color: AppTheme.pureWhite.withValues(alpha: 0.5),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Wormhole Animation
                        if (_showWormhole)
                          Center(
                            child: WormholeAnimation(
                              isActive: true,
                              onTap: _isModelPlaced ? null : _placeModel,
                              size: 200,
                            ),
                          ),
                        
                        // Success overlay
                        if (_isModelPlaced)
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppTheme.pureWhite,
                                    size: 64,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Memory Placed!',
                                    style: TextStyle(
                                      color: AppTheme.pureWhite,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Control Panel
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: AppTheme.lightBlue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Info
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppTheme.accentGold,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _currentLocation ?? 'Loading location...',
                              style: TextStyle(
                                color: AppTheme.pureWhite.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Model Info
                      if (_selectedModelId.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.view_in_ar,
                              color: AppTheme.accentGold,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Selected: ${_arService.getModelByMemoryType(widget.memoryType ?? 'text')?.name ?? 'Unknown Model'}',
                                style: TextStyle(
                                  color: AppTheme.pureWhite.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isModelPlaced ? null : _showModelSelector,
                              icon: const Icon(Icons.swap_horiz),
                              label: const Text('Change Model'),
                              style: AppTheme.outlineButtonStyle.copyWith(
                                foregroundColor: MaterialStateProperty.all(AppTheme.pureWhite),
                                side: MaterialStateProperty.all(
                                  BorderSide(color: AppTheme.pureWhite.withValues(alpha: 0.3)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: (_isPlacingModel || _isModelPlaced) ? null : _placeModel,
                              icon: _isPlacingModel
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.pureWhite),
                                      ),
                                    )
                                  : const Icon(Icons.place),
                              label: Text(_isModelPlaced ? 'Placed' : 'Place Memory'),
                              style: AppTheme.primaryButtonStyle.copyWith(
                                backgroundColor: MaterialStateProperty.all(
                                  _isModelPlaced 
                                      ? AppTheme.accentGold
                                      : AppTheme.primaryDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Nearby Memories Info
                      if (_nearbyMemories.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.secondaryBlue.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.explore,
                                color: AppTheme.secondaryBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${_nearbyMemories.length} memories nearby',
                                  style: TextStyle(
                                    color: AppTheme.secondaryBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
