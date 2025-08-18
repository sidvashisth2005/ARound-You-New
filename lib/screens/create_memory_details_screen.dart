import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/theme/theme.dart';
import 'package:around_you/services/location_service.dart';
import 'package:around_you/services/ar_service.dart';
import 'package:around_you/services/auth_service.dart';
import 'package:around_you/services/cloudinary_service.dart';
import 'package:around_you/services/animation_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

class CreateMemoryDetailsScreen extends StatefulWidget {
  final String memoryType;
  final String? memoryText;
  final String? mediaFile;
  final String modelId;

  const CreateMemoryDetailsScreen({
    super.key,
    required this.memoryType,
    this.memoryText,
    this.mediaFile,
    required this.modelId,
  });

  @override
  State<CreateMemoryDetailsScreen> createState() => _CreateMemoryDetailsScreenState();
}

class _CreateMemoryDetailsScreenState extends State<CreateMemoryDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  
  final LocationService _locationService = LocationService();
  final ARService _arService = ARService();
  final AuthService _authService = AuthService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  File? _selectedMediaFile;
  String? _currentLocation;
  List<String> _tags = [];
  bool _isPublic = true;
  bool _isLoading = false;
  bool _isCreatingMemory = false;
  bool _showSuccessAnimation = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadLocationData();
    _initializeFields();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _initializeFields() {
    if (widget.memoryText != null) {
      _titleController.text = widget.memoryText!;
      _descriptionController.text = widget.memoryText!;
    }
    
    // Add default tags based on memory type
    switch (widget.memoryType.toLowerCase()) {
      case 'photo':
        _tags = ['Photography', 'Memory'];
        break;
      case 'video':
        _tags = ['Video', 'Memory'];
        break;
      case 'text':
        _tags = ['Text', 'Memory'];
        break;
      case 'audio':
        _tags = ['Audio', 'Memory'];
        break;
    }
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

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final picker = ImagePicker();
      XFile? pickedFile;

      switch (widget.memoryType) {
        case 'photo':
          pickedFile = await picker.pickImage(source: source);
          break;
        case 'video':
          pickedFile = await picker.pickVideo(source: source);
          break;
        case 'audio':
          // For audio, we'll use a placeholder for now
          break;
      }

      if (pickedFile != null) {
        setState(() {
          _selectedMediaFile = File(pickedFile!.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking media: $e')),
      );
    }
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      _tagsController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _createMemory() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a memory title')),
      );
      return;
    }

    setState(() {
      _isCreatingMemory = true;
    });

    try {
      // Get current user info
      final userInfo = await _authService.getUserInfo();
      if (userInfo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to create memories')),
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

      // Create AR memory
      final success = await _arService.createARMemory(
        memoryType: widget.memoryType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        coordinates: coordinates,
        userId: userInfo['userId']!,
        userName: userInfo['name']!,
        mediaFile: _selectedMediaFile,
        textContent: widget.memoryType == 'text' ? _titleController.text.trim() : null,
        modelId: widget.modelId,
        additionalData: {
          'tags': _tags,
          'isPublic': _isPublic,
          'locationName': _currentLocation,
        },
      );

      if (success) {
        if (mounted) {
          // Show success animation
          setState(() {
            _showSuccessAnimation = true;
          });
          
          // Wait for animation to complete before navigating
          await Future.delayed(const Duration(seconds: 3));
          
          if (mounted) {
            // Navigate to AR placement screen
            context.push('/ar-memory', extra: {
              'memoryType': widget.memoryType,
              'memoryText': _titleController.text.trim(),
              'mediaFile': _selectedMediaFile,
              'modelId': widget.modelId,
              'title': _titleController.text.trim(),
              'description': _descriptionController.text.trim(),
              'tags': _tags,
            });
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create memory')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error creating memory: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating memory: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingMemory = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: const Text(
            'Memory Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 100),
                      
                      // Header Section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(20),
                            decoration: AppTheme.glassPanelDecoration,
                            child: Column(
                              children: [
                                Icon(
                                  _getMemoryTypeIcon(widget.memoryType),
                                  size: 48,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Complete Your Memory',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add details to make your ${widget.memoryType} memory special',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Title Input
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildInputField(
                            'Memory Title',
                            _titleController,
                            Icons.title,
                            hintText: 'Give your memory a meaningful title...',
                            maxLines: 1,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description Input
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildInputField(
                            'Description',
                            _descriptionController,
                            Icons.description,
                            hintText: 'Describe your memory in detail...',
                            maxLines: 4,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Media Section (if applicable)
                      if (widget.memoryType != 'text') ...[
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildMediaSection(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Tags Section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildTagsSection(),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Privacy Settings
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildPrivacySection(),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Location Section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildLocationSection(),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildActionButtons(),
                        ),
                      ),
                    ],
                  ),
                ),
          
          // Success Animation Overlay
          if (_showSuccessAnimation)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimationService.getMemoryCreationAnimation(size: 150),
                    const SizedBox(height: 24),
                    const Text(
                      'Memory Created Successfully!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Redirecting to AR placement...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
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

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? hintText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: AppTheme.elegantCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Container(
      decoration: AppTheme.elegantCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getMemoryTypeIcon(widget.memoryType),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.memoryType.toUpperCase()} Content',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_selectedMediaFile != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: widget.memoryType == 'photo'
                      ? Image.file(
                          _selectedMediaFile!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey.withOpacity(0.3),
                          child: Center(
                            child: Icon(
                              _getMemoryTypeIcon(widget.memoryType),
                              size: 64,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickMedia(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickMedia(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Container(
      decoration: AppTheme.elegantCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tag, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tags',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Tags Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagsController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a tag...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _addTag(_tagsController.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Tags Display
            if (_tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _removeTag(tag),
                        child: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Container(
      decoration: AppTheme.elegantCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.privacy_tip, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Privacy Settings',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Switch(
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPublic ? 'Public Memory' : 'Private Memory',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _isPublic 
                            ? 'Other users can see and interact with your memory'
                            : 'Only you can see this memory',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
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
    );
  }

  Widget _buildLocationSection() {
    return Container(
      decoration: AppTheme.elegantCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.my_location,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _currentLocation ?? 'Loading location...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isCreatingMemory ? null : _createMemory,
            style: AppTheme.primaryButtonStyle,
            child: _isCreatingMemory
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Create Memory',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: AppTheme.outlineButtonStyle.copyWith(
              foregroundColor: MaterialStateProperty.all(Colors.white),
              side: MaterialStateProperty.all(const BorderSide(color: Colors.white30)),
            ),
            child: const Text('Back'),
          ),
        ),
      ],
    );
  }

  IconData _getMemoryTypeIcon(String memoryType) {
    switch (memoryType.toLowerCase()) {
      case 'photo':
        return Icons.photo;
      case 'video':
        return Icons.videocam;
      case 'text':
        return Icons.text_fields;
      case 'audio':
        return Icons.mic;
      default:
        return Icons.memory;
    }
  }
}
