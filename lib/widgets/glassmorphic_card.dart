import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import 'glassmorphic_container.dart';

class GlassmorphicCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  // Removed opacity parameter as it's not supported in GlassmorphicContainer
  final Color? borderColor;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final bool hasAnimation;
  final bool enableHapticFeedback;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final double? width;
  final double? height;

  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.blur = 10,
    // Removed opacity parameter as it's not supported in GlassmorphicContainer
    this.borderColor,
    this.backgroundColor,
    this.boxShadow,
    this.gradient,
    this.hasAnimation = true,
    this.enableHapticFeedback = true,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 200),
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<GlassmorphicCard> createState() => _GlassmorphicCardState();
}

class _GlassmorphicCardState extends State<GlassmorphicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _animationController.reverse();
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final defaultBorderColor = widget.borderColor ?? 
        theme.colorScheme.primary.withOpacity(0.2);
    
    final defaultBackgroundColor = widget.backgroundColor ?? 
        theme.colorScheme.surface.withOpacity(0.7);
    
    final defaultBoxShadow = widget.boxShadow ?? 
      (Theme.of(context).cardTheme.shadowColor != null ? [
        BoxShadow(
          color: Theme.of(context).cardTheme.shadowColor!,
          blurRadius: 8,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        )
      ] : null);
    
    final defaultGradient = widget.gradient ?? 
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface.withOpacity(0.8),
            theme.colorScheme.surface.withOpacity(0.6),
          ],
        );

    Widget content = GlassmorphicContainer(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      borderRadius: widget.borderRadius,
      blur: widget.blur,
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: defaultBackgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: defaultBorderColor),
          boxShadow: defaultBoxShadow,
          gradient: defaultGradient,
        ),
        child: widget.child,
      ),
    );
    
    // No need for SizedBox wrapping since width and height are directly set on GlassmorphicContainer

    if (widget.onTap != null) {
      content = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: content,
        ),
      );
    }

    return content;
  }
}