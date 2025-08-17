import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/services/permission_service.dart';
import 'package:around_you/theme/theme.dart';
import 'package:around_you/services/map_preload_service.dart';
import 'package:around_you/extensions/color_extensions.dart';
import 'package:around_you/services/location_service.dart';
import 'package:around_you/services/ar_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _cameraController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _slideAnimation;
  
  final PermissionService _permissionService = PermissionService();
  final LocationService _locationService = LocationService();
  final ARService _arService = ARService();
  
  bool _isLoading = true;
  bool _isCameraActive = false;
  String _currentLocation = 'Loading...';
  int _nearbyMemoriesCount = 0;

  @override
  void initState() {
    super.initState();
    MapPreloadService().warmUp();
    _initializeAnimations();
    _initializeCamera();
  }

  void _initializeAnimations() {
    _cameraController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutBack,
    ));

    _cameraController.forward();
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    try {
      await _permissionService.checkPermissionStatuses();
      await _loadLocationData();
      
      // Initialize AR camera
      final cameraInitialized = await _arService.initializeCamera();
      if (cameraInitialized) {
        setState(() {
          _isCameraActive = true;
        });
      }
      
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize camera: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loadLocationData() async {
    try {
      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final address = await _locationService.getAddressFromCoordinates(
          LatLng(position.latitude, position.longitude),
        );
        setState(() {
          _currentLocation = address ?? '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        });
      }

      // Get nearby users count
      final nearbyUsers = await _locationService.getNearbyUsers();
      setState(() {
        _nearbyMemoriesCount = nearbyUsers.length;
      });
    } catch (e) {
      debugPrint('Error loading location data: $e');
      setState(() {
        _currentLocation = 'Location unavailable';
        _nearbyMemoriesCount = 0;
      });
    }
  }

  void _showCreateModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCreateModal(),
    );
  }

  Widget _buildCreateModal() {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryDark.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: Border.all(
              color: AppTheme.accentGold.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.add_circle_outline,
                              color: AppTheme.accentGold,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create New Memory',
                      style: TextStyle(
                        color: AppTheme.pureWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the type of content you want to create',
                      style: TextStyle(
                        color: AppTheme.pureWhite.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Content types
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildContentTypeOption(
                      context,
                      'Text',
                      'Share your thoughts and memories',
                      Icons.text_fields,
                      AppTheme.primaryDark,
                      () => _handleContentTypeSelection('text'),
                    ),
                    const SizedBox(height: 16),
                    _buildContentTypeOption(
                      context,
                      'Photo',
                      'Capture and share moments',
                      Icons.camera_alt,
                      AppTheme.secondaryBlue,
                      () => _handleContentTypeSelection('photo'),
                    ),
                    const SizedBox(height: 16),
                    _buildContentTypeOption(
                      context,
                      'Video',
                      'Record and share experiences',
                      Icons.videocam,
                      AppTheme.accentGold,
                      () => _handleContentTypeSelection('video'),
                    ),
                    const SizedBox(height: 16),
                    _buildContentTypeOption(
                      context,
                      'Audio',
                      'Share voice messages and sounds',
                      Icons.mic,
                      AppTheme.premiumBlue,
                      () => _handleContentTypeSelection('audio'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentTypeOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.pureWhite.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: AppTheme.subtleShadows,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.pureWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: AppTheme.pureWhite.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.pureWhite.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContentTypeSelection(String contentType) {
    Navigator.pop(context);
    
    // Navigate to appropriate creation screen based on content type
    switch (contentType) {
      case 'text':
        context.push('/create-memory?type=text');
        break;
      case 'photo':
        context.push('/create-memory?type=photo');
        break;
      case 'video':
        context.push('/create-memory?type=video');
        break;
      case 'audio':
        context.push('/create-memory?type=audio');
        break;
    }
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive 
            ? AppTheme.primaryDark.withValues(alpha: 0.15)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive 
              ? AppTheme.primaryDark.withValues(alpha: 0.3)
              : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Icon(
                icon,
                color: isActive 
                  ? AppTheme.primaryDark
                  : AppTheme.pureWhite.withValues(alpha: 0.7),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive 
                  ? AppTheme.primaryDark
                  : AppTheme.pureWhite.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'Around You',
            style: TextStyle(
              color: AppTheme.pureWhite,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: AppTheme.pureWhite,
              ),
              onPressed: () => context.push('/notifications'),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Background gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                ),
                
                // Main content
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: screenSize.height - MediaQuery.of(context).padding.top - 100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 100),
                          
                          // Welcome Section
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppTheme.pureWhite.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: AppTheme.lightBlue.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: AppTheme.premiumShadows,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        AnimatedBuilder(
                                          animation: _pulseAnimation,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: _pulseAnimation.value,
                                              child: Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentGold.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Icon(
                                                  Icons.explore,
                                                  color: AppTheme.accentGold,
                                                  size: 32,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Welcome Back!',
                                                style: TextStyle(
                                                  color: AppTheme.pureWhite,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Discover memories around you',
                                                style: TextStyle(
                                                  color: AppTheme.pureWhite.withValues(alpha: 0.7),
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Quick Actions
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quick Actions',
                                  style: TextStyle(
                                    color: AppTheme.pureWhite,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildActionCard(
                                        'Create Memory',
                                        'Share your experiences',
                                        Icons.add_circle_outline,
                                        AppTheme.accentGold,
                                        _showCreateModal,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildActionCard(
                                        'Explore AR',
                                        'View nearby memories',
                                        Icons.view_in_ar,
                                        AppTheme.premiumBlue,
                                        () => context.push('/around'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Location & Stats
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.pureWhite.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.lightBlue.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: AppTheme.subtleShadows,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Location',
                                    style: TextStyle(
                                      color: AppTheme.pureWhite,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: AppTheme.accentGold,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _currentLocation,
                                          style: TextStyle(
                                            color: AppTheme.pureWhite.withValues(alpha: 0.9),
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.people,
                                        color: AppTheme.secondaryBlue,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '$_nearbyMemoriesCount memories nearby',
                                        style: TextStyle(
                                          color: AppTheme.pureWhite.withValues(alpha: 0.9),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FadeTransition(
        opacity: _fadeAnimation,
        child: FloatingActionButton.extended(
          onPressed: _showCreateModal,
          backgroundColor: AppTheme.accentGold,
          foregroundColor: AppTheme.primaryDark,
          icon: const Icon(Icons.add),
          label: const Text('Create'),
          elevation: 8,
        ),
      ),
      bottomNavigationBar: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.pureWhite.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: AppTheme.premiumShadows,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context, Icons.home, 'Home', true, () {}),
                  _buildNavItem(context, Icons.explore, 'Around', false, () => context.push('/around')),
                  _buildNavItem(context, Icons.chat, 'Chat', false, () => context.push('/chat')),
                  _buildNavItem(context, Icons.emoji_events, 'Achievements', false, () => context.push('/achievements')),
                  _buildNavItem(context, Icons.person, 'Profile', false, () => context.push('/profile')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.pureWhite.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: AppTheme.subtleShadows,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.pureWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppTheme.pureWhite.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}