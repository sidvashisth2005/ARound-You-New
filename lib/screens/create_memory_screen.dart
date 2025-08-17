import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:around_you/services/location_service.dart';
import 'package:around_you/services/ar_service.dart';
import 'package:around_you/services/auth_service.dart';
import 'package:around_you/services/cloudinary_service.dart';
import 'package:around_you/widgets/model_selection_popup.dart';
import 'package:around_you/widgets/lottie_loading_screen.dart';
import 'package:around_you/theme/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

class CreateMemoryScreen extends StatefulWidget {
  final String? memoryType;

  const CreateMemoryScreen({super.key, this.memoryType});

  @override
  State<CreateMemoryScreen> createState() => _CreateMemoryScreenState();
}

class _CreateMemoryScreenState extends State<CreateMemoryScreen> {
  final TextEditingController _textController = TextEditingController();
  final LocationService _locationService = LocationService();
  final ARService _arService = ARService();
  final AuthService _authService = AuthService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  String _selectedMemoryType = 'text';
  File? _selectedMediaFile;
  String? _currentLocation;
  bool _isLoading = false;
  bool _isCreatingMemory = false;
  AR3DModel? _selected3DModel;
  bool _showModelSelection = false;

  @override
  void initState() {
    super.initState();
    _selectedMemoryType = widget.memoryType ?? 'text';
    _loadLocationData();
    _showModelSelectionPopup();
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

  void _showModelSelectionPopup() {
    setState(() {
      _showModelSelection = true;
    });
  }

  void _onModelSelected(AR3DModel model) {
    setState(() {
      _selected3DModel = model;
      _showModelSelection = false;
    });
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final picker = ImagePicker();
      XFile? pickedFile;

      switch (_selectedMemoryType) {
        case 'photo':
          pickedFile = await picker.pickImage(source: source);
          break;
        case 'video':
          pickedFile = await picker.pickVideo(source: source);
          break;
        case 'audio':
          // For audio, we'll use a placeholder for now
          // In a real app, you'd use a proper audio picker
          break;
      }

      if (pickedFile != null) {
        setState(() {
          _selectedMediaFile = File(pickedFile!.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking media: $e')),
        );
      }
    }
  }

  Future<void> _createMemory() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a memory description')),
      );
      return;
    }

    if (_selected3DModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a 3D model first')),
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to create memories')),
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

      // Create AR memory
      final success = await _arService.createARMemory(
        memoryType: _selectedMemoryType,
        title: _textController.text.trim(),
        description: _textController.text.trim(),
        coordinates: coordinates,
        userId: userInfo['userId']!,
        userName: userInfo['name']!,
        mediaFile: _selectedMediaFile,
        textContent: _selectedMemoryType == 'text' ? _textController.text.trim() : null,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Memory created successfully!')),
          );
          context.pop();
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

  void _showARMemoryScreen() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a memory description first')),
      );
      return;
    }

    if (_selected3DModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a 3D model first')),
      );
      return;
    }

    context.push('/ar-memory', extra: {
      'memoryType': _selectedMemoryType,
      'memoryText': _textController.text.trim(),
      'mediaFile': _selectedMediaFile,
      'selected3DModel': _selected3DModel,
    });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Memory',
          style: TextStyle(
            color: AppTheme.pureWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                          
                          // Memory Type Selector
                          _buildMemoryTypeSelector(),
                          
                          const SizedBox(height: 24),
                          
                          // 3D Model Selection Status
                          if (_selected3DModel != null) _buildModelSelectionStatus(),
                          
                          const SizedBox(height: 24),
                          
                          // Content Section
                          _buildContentSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Location Section
                          _buildLocationSection(),
                          
                          const SizedBox(height: 24),
                          
                          // AR Section
                          _buildARSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Action Buttons
                          _buildActionButtons(),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // 3D Model Selection Popup
                if (_showModelSelection)
                  ModelSelectionPopup(
                    selectedMemoryType: _selectedMemoryType,
                    onModelSelected: _onModelSelected,
                  ),
              ],
            ),
    );
  }

  Widget _buildModelSelectionStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.accentGold,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '3D Model Selected',
                  style: TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _selected3DModel?.name ?? '',
                  style: TextStyle(
                    color: AppTheme.accentGold.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showModelSelectionPopup,
            child: Text(
              'Change',
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

  Widget _buildMemoryTypeSelector() {
    final memoryTypes = [
      {'type': 'text', 'icon': Icons.text_fields, 'label': 'Text'},
      {'type': 'photo', 'icon': Icons.photo, 'label': 'Photo'},
      {'type': 'video', 'icon': Icons.videocam, 'label': 'Video'},
      {'type': 'audio', 'icon': Icons.mic, 'label': 'Audio'},
    ];

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightBlue.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: AppTheme.subtleShadows,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.spaceEvenly,
          children: memoryTypes.map((type) {
            final isSelected = _selectedMemoryType == type['type'] as String;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMemoryType = type['type'] as String;
                  _selectedMediaFile = null;
                  _selected3DModel = null;
                });
                _showModelSelectionPopup();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.primaryDark.withValues(alpha: 0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      type['icon'] as IconData,
                      color: isSelected 
                          ? AppTheme.pureWhite
                          : AppTheme.pureWhite.withValues(alpha: 0.7),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type['label'] as String,
                    style: TextStyle(
                      color: isSelected 
                          ? AppTheme.pureWhite
                          : AppTheme.pureWhite.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Memory Content',
          style: TextStyle(
            color: AppTheme.pureWhite.withValues(alpha: 0.9),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        // Media picker for photo/video/audio
        if (_selectedMemoryType != 'text') ...[
          if (_selectedMediaFile != null) ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.lightBlue.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: AppTheme.subtleShadows,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _selectedMemoryType == 'photo'
                    ? Image.file(
                        _selectedMediaFile!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppTheme.subtleGray.withValues(alpha: 0.3),
                        child: Center(
                          child: Icon(
                            _selectedMemoryType == 'video' ? Icons.videocam : Icons.mic,
                            size: 64,
                            color: AppTheme.pureWhite.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showMediaPickerDialog(),
              icon: Icon(_selectedMemoryType == 'photo' ? Icons.add_a_photo : 
                        _selectedMemoryType == 'video' ? Icons.videocam : Icons.mic),
              label: Text(_selectedMediaFile == null 
                  ? 'Add ${_selectedMemoryType.toUpperCase()}' 
                  : 'Change ${_selectedMemoryType.toUpperCase()}'),
              style: AppTheme.secondaryButtonStyle.copyWith(
                backgroundColor: MaterialStateProperty.all(
                  AppTheme.secondaryBlue.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Text input
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 120),
          decoration: BoxDecoration(
            color: AppTheme.pureWhite.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightBlue.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: AppTheme.subtleShadows,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _textController,
              style: TextStyle(
                color: AppTheme.pureWhite,
                fontSize: 16,
              ),
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: _selectedMemoryType == 'text' 
                    ? 'Write your memory...'
                    : 'Add a description...',
                hintStyle: TextStyle(
                  color: AppTheme.pureWhite.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightBlue.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: AppTheme.subtleShadows,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: AppTheme.accentGold,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Current Location',
                    style: TextStyle(
                      color: AppTheme.pureWhite.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentLocation ?? 'Loading...',
                    style: TextStyle(
                      color: AppTheme.pureWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Widget _buildARSection() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightBlue.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: AppTheme.subtleShadows,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.view_in_ar,
                  color: AppTheme.accentGold,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'AR Placement',
                  style: TextStyle(
                    color: AppTheme.pureWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Place your memory in the AR world using 3D models',
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showARMemoryScreen,
                icon: const Icon(Icons.view_in_ar),
                label: const Text('Place in AR'),
                style: AppTheme.primaryButtonStyle.copyWith(
                  backgroundColor: MaterialStateProperty.all(
                    _selected3DModel != null 
                        ? AppTheme.primaryDark
                        : AppTheme.subtleGray,
                  ),
                ),
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
            onPressed: (_isCreatingMemory || _selected3DModel == null) ? null : _createMemory,
            style: AppTheme.primaryButtonStyle,
            child: _isCreatingMemory
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.pureWhite),
                    ),
                  )
                : const Text(
                    'Create Memory',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: AppTheme.outlineButtonStyle.copyWith(
              foregroundColor: MaterialStateProperty.all(AppTheme.pureWhite),
              side: MaterialStateProperty.all(
                BorderSide(color: AppTheme.pureWhite.withValues(alpha: 0.3)),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  void _showMediaPickerDialog() {
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
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.pureWhite),
              title: const Text('Camera', style: TextStyle(color: AppTheme.pureWhite)),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.pureWhite),
              title: const Text('Gallery', style: TextStyle(color: AppTheme.pureWhite)),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} 