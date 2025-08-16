import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';
import '../utils/responsive_layout.dart';

class AnimatedFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final bool enabled;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool enableSuggestions;
  final bool autocorrect;
  final List<TextInputFormatter>? inputFormatters;

  const AnimatedFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.contentPadding,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.inputFormatters,
  });

  @override
  State<AnimatedFormField> createState() => _AnimatedFormFieldState();
}

class _AnimatedFormFieldState extends State<AnimatedFormField> with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _animationController = AnimationController(
      vsync: this,
      duration: DesignSystem.animationDurationShort,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignSystem.animationCurveMedium,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignSystem.animationCurveMedium,
    ));
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      _animationController.forward();
      HapticFeedback.lightImpact();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onFieldSubmitted,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        enableSuggestions: widget.enableSuggestions,
        autocorrect: widget.autocorrect,
        inputFormatters: widget.inputFormatters,
        style: TextStyle(
          color: DesignSystem.colorText,
          fontWeight: FontWeight.w500,
          fontSize: ResponsiveLayout.getResponsiveFontSize(context, 16),
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          contentPadding: widget.contentPadding ?? ResponsiveLayout.getValueForScreenType(
            context: context,
            mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            tablet: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            desktop: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          ),
          prefixIcon: AnimatedOpacity(
            opacity: _isFocused ? 1.0 : 0.7,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              widget.prefixIcon,
              color: _isFocused 
                ? DesignSystem.colorPrimary 
                : DesignSystem.colorSecondary,
            ),
          ),
          suffixIcon: widget.suffixIcon != null
              ? IconButton(
                  icon: Icon(
                    widget.suffixIcon,
                    color: _isFocused 
                      ? DesignSystem.colorPrimary 
                      : DesignSystem.colorSecondary,
                  ),
                  onPressed: widget.onSuffixIconPressed,
                )
              : null,
          filled: true,
          fillColor: _isFocused 
            ? DesignSystem.colorBackgroundLight.withOpacity(0.5) 
            : DesignSystem.colorBackgroundLight.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            borderSide: BorderSide(
              color: DesignSystem.colorBorder.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            borderSide: BorderSide(
              color: DesignSystem.colorPrimary,
              width: 2.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            borderSide: BorderSide(
              color: DesignSystem.colorError,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            borderSide: BorderSide(
              color: DesignSystem.colorError,
              width: 2.0,
            ),
          ),
          labelStyle: TextStyle(
            color: _isFocused 
              ? DesignSystem.colorPrimary 
              : DesignSystem.colorSecondary,
            fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
            fontSize: ResponsiveLayout.getResponsiveFontSize(context, 16),
          ),
          hintStyle: TextStyle(
            color: DesignSystem.colorTextLight,
            fontWeight: FontWeight.w400,
            fontSize: ResponsiveLayout.getResponsiveFontSize(context, 15),
          ),
          errorStyle: TextStyle(
            color: DesignSystem.colorError,
            fontWeight: FontWeight.w500,
            fontSize: ResponsiveLayout.getResponsiveFontSize(context, 12),
          ),
        ),
        validator: (value) {
          final error = widget.validator?.call(value);
          setState(() {
            _hasError = error != null;
            _errorText = error;
          });
          return error;
        },
      ),
    );
  }
}