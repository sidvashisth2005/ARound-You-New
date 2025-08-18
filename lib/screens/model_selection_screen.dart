import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/theme/theme.dart';
import 'package:around_you/services/ar_service.dart';
import 'package:around_you/widgets/glassmorphic_card.dart';

class ModelSelectionScreen extends StatefulWidget {
  final String memoryType;
  final String? memoryText;
  final String? mediaFile;

  const ModelSelectionScreen({
    super.key,
    required this.memoryType,
    this.memoryText,
    this.mediaFile,
  });

  @override
  State<ModelSelectionScreen> createState() => _ModelSelectionScreenState();
}

class _ModelSelectionScreenState extends State<ModelSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  String? _selectedModelId;
  final ARService _arService = ARService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _selectDefaultModel();
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

  void _selectDefaultModel() {
    final model = _arService.getModelByMemoryType(widget.memoryType);
    if (model != null) {
      setState(() {
        _selectedModelId = model.id;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _continueToDetails() {
    if (_selectedModelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a 3D model first')),
      );
      return;
    }

    context.push('/create-memory-details', extra: {
      'memoryType': widget.memoryType,
      'memoryText': widget.memoryText,
      'mediaFile': widget.mediaFile,
      'modelId': _selectedModelId,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableModels = _arService.getAvailableModels();
    
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
            'Select 3D Model',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 100),
          
          // Header Section
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
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
                      'Choose Your 3D Model',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a 3D model that best represents your ${widget.memoryType} memory',
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
          
          // Models Grid
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: availableModels.length,
                itemBuilder: (context, index) {
                  final model = availableModels[index];
                  final isSelected = _selectedModelId == model.id;
                  
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 0.3 + (index * 0.1)),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _slideController,
                      curve: Curves.easeOutCubic,
                    )),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedModelId = model.id;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? theme.colorScheme.primary.withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected 
                              ? theme.colorScheme.primary
                              : Colors.white.withOpacity(0.1),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected 
                            ? AppTheme.premiumShadows
                            : AppTheme.subtleShadows,
                        ),
                        child: Column(
                          children: [
                            // Model Preview
                            Expanded(
                              flex: 3,
                              child: Container(
                                margin: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                    ? theme.colorScheme.primary.withOpacity(0.1)
                                    : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected 
                                      ? theme.colorScheme.primary.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    _getModelIcon(model.id),
                                    size: 48,
                                    color: isSelected 
                                      ? theme.colorScheme.primary
                                      : Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                            
                            // Model Info
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      model.name,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      model.description,
                                      style: TextStyle(
                                        color: isSelected 
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                          ? theme.colorScheme.primary.withOpacity(0.3)
                                          : Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        model.category,
                                        style: TextStyle(
                                          color: isSelected 
                                            ? theme.colorScheme.primary
                                            : Colors.white.withOpacity(0.7),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Selection Indicator
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Continue Button
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continueToDetails,
                  style: AppTheme.primaryButtonStyle,
                  child: const Text(
                    'Continue to Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

  IconData _getModelIcon(String modelId) {
    switch (modelId) {
      case 'photo':
        return Icons.photo_library;
      case 'video':
        return Icons.videocam;
      case 'text':
        return Icons.text_fields;
      case 'audio':
        return Icons.music_note;
      default:
        return Icons.view_in_ar;
    }
  }
}
