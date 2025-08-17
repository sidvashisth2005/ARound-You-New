import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:around_you/services/location_service.dart';
import 'package:around_you/services/ar_service.dart';
import 'package:around_you/services/auth_service.dart';
import 'package:around_you/services/cloudinary_service.dart';
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
  String? _selectedModelId;
  File? _selectedMediaFile;
  String? _currentLocation;
  bool _isLoading = false;
  bool _isCreatingMemory = false;

  @override
  void initState() {
    super.initState();
    _selectedMemoryType = widget.memoryType ?? 'text';
    _loadLocationData();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking media: $e')),
      );
    }
  }

  Future<void> _createMemory() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a memory description')),
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

      // Create AR memory with selected model if provided
      final success = await _arService.createARMemory(
        memoryType: _selectedMemoryType,
        title: _textController.text.trim(),
        description: _textController.text.trim(),
        coordinates: coordinates,
        userId: userInfo['userId']!,
        userName: userInfo['name']!,
        mediaFile: _selectedMediaFile,
        textContent: _selectedMemoryType == 'text' ? _textController.text.trim() : null,
        modelId: _selectedModelId,
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

    context.push('/ar-memory', extra: {
      'memoryType': _selectedMemoryType,
      'memoryText': _textController.text.trim(),
      'mediaFile': _selectedMediaFile,
      'modelId': _selectedModelId,
    });
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
        title: const Text(
          'Create Memory',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  
                  // Memory Type Selector
                  _buildMemoryTypeSelector(),
                  
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
                ],
              ),
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
      height: 80,
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: memoryTypes.map((type) {
            final isSelected = _selectedMemoryType == type['type'] as String;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMemoryType = type['type'] as String;
                  _selectedMediaFile = null; // Clear selected media when changing type
                });
                _openModelSelector();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      type['icon'] as IconData,
                      color: isSelected 
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    type['label'] as String,
                    style: TextStyle(
                      color: isSelected 
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontSize: 10,
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

  void _openModelSelector() {
    final available = _arService.getAvailableModels();
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
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: available.length,
                itemBuilder: (context, index) {
                  final model = available[index];
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
                      child: Center(
                        child: Text(
                          model.name.substring(0, 1),
                          style: const TextStyle(color: Colors.white),
                        ),
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
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
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
            const SizedBox(height: 12),
          ],
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
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Media picker for photo/video/audio
        if (_selectedMemoryType != 'text') ...[
          if (_selectedMediaFile != null) ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _selectedMemoryType == 'photo'
                    ? Image.file(
                        _selectedMediaFile!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey.withOpacity(0.3),
                        child: Center(
                          child: Icon(
                            _selectedMemoryType == 'video' ? Icons.videocam : Icons.mic,
                            size: 64,
                            color: Colors.white.withOpacity(0.7),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Text input
        Container(
          width: double.infinity,
          height: 120,
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _textController,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: _selectedMemoryType == 'text' 
                    ? 'Write your memory...'
                    : 'Add a description...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
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
      height: 80,
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Current Location',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentLocation ?? 'Loading...',
                    style: const TextStyle(
                      color: Colors.white,
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
      height: 120,
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.view_in_ar,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'AR Placement',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Place your memory in the AR world using 3D models',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showARMemoryScreen,
                icon: const Icon(Icons.view_in_ar),
                label: const Text('Place in AR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
            onPressed: _isCreatingMemory ? null : _showARMemoryScreen,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
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
                    'Continue to AR',
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
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Camera', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Gallery', style: TextStyle(color: Colors.white)),
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