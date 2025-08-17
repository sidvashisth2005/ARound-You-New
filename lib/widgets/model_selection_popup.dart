import 'package:flutter/material.dart';
import 'package:around_you/theme/theme.dart';
import 'package:around_you/services/ar_service.dart';

class ModelSelectionPopup extends StatefulWidget {
  final String selectedMemoryType;
  final Function(AR3DModel) onModelSelected;

  const ModelSelectionPopup({
    super.key,
    required this.selectedMemoryType,
    required this.onModelSelected,
  });

  @override
  State<ModelSelectionPopup> createState() => _ModelSelectionPopupState();
}

class _ModelSelectionPopupState extends State<ModelSelectionPopup>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  AR3DModel? _selectedModel;
  final ARService _arService = ARService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _selectedModel = _arService.getModelByMemoryType(widget.selectedMemoryType);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableModels = _arService.getAvailableModels();
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              gradient: AppTheme.premiumGradient,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppTheme.lightBlue.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: AppTheme.premiumShadows,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
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
                                Icons.view_in_ar,
                                color: AppTheme.accentGold,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Choose Your 3D Model',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select the perfect 3D model for your ${widget.selectedMemoryType} memory',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryDark.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Model Selection
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: availableModels.map((model) {
                        final isSelected = _selectedModel?.id == model.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildModelOption(model, isSelected),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: AppTheme.outlineButtonStyle.copyWith(
                            side: MaterialStateProperty.all(
                              BorderSide(color: AppTheme.primaryDark, width: 2),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedModel != null
                              ? () {
                                  widget.onModelSelected(_selectedModel!);
                                  Navigator.of(context).pop();
                                }
                              : null,
                          style: AppTheme.primaryButtonStyle,
                          child: const Text('Continue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModelOption(AR3DModel model, bool isSelected) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            _selectedModel = model;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryDark.withValues(alpha: 0.1)
                : AppTheme.pureWhite.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryDark
                  : AppTheme.lightBlue.withValues(alpha: 0.3),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected 
                ? AppTheme.cardShadows
                : AppTheme.subtleShadows,
          ),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryDark.withValues(alpha: 0.1)
                      : AppTheme.warmCream,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryDark
                        : AppTheme.lightBlue.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    model.thumbnailPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.view_in_ar,
                        color: isSelected 
                            ? AppTheme.primaryDark
                            : AppTheme.secondaryBlue,
                        size: 24,
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Model Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSelected 
                            ? AppTheme.primaryDark
                            : AppTheme.primaryDark,
                        fontWeight: isSelected 
                            ? FontWeight.bold
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      model.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected 
                            ? AppTheme.primaryDark.withValues(alpha: 0.8)
                            : AppTheme.primaryDark.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        model.category,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.secondaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selection Indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryDark
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryDark
                        : AppTheme.lightBlue.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: AppTheme.pureWhite,
                        size: 16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}