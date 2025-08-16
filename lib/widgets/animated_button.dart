import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';
import '../utils/responsive_layout.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool isLoading;
  final Color? loadingColor;
  final double? width;
  final double? height;
  final bool enableHapticFeedback;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final bool isPrimary;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final OutlinedBorder? shape;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.isLoading = false,
    this.loadingColor,
    this.width,
    this.height,
    this.enableHapticFeedback = true,
    this.animationDuration,
    this.animationCurve,
    this.isPrimary = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.padding,
    this.shape,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration ?? DesignSystem.durationFast,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve ?? DesignSystem.curveStandard,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
      
      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = ElevatedButton.styleFrom(
      backgroundColor: widget.backgroundColor ?? 
        (widget.isPrimary ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary),
      foregroundColor: widget.foregroundColor ?? 
        (widget.isPrimary ? Colors.white : Theme.of(context).colorScheme.primary),
      shape: widget.shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
      ),
      padding: widget.padding ?? EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.getValueForScreenType(
          context: context,
          mobile: 24.0,
          tablet: 28.0,
          desktop: 32.0,
        ),
        vertical: ResponsiveLayout.getValueForScreenType(
          context: context,
          mobile: 16.0,
          tablet: 18.0,
          desktop: 20.0,
        ),
      ),
      elevation: widget.elevation ?? (_isPressed ? 2 : 4),
      shadowColor: widget.isPrimary ? 
        Theme.of(context).colorScheme.primary.withOpacity(0.3) : 
        Theme.of(context).colorScheme.secondary.withOpacity(0.3),
    );

    final buttonStyle = widget.style ?? defaultStyle;
    final loadingColor = widget.loadingColor ?? 
      (widget.isPrimary ? Colors.white : Theme.of(context).colorScheme.primary);

    return AnimatedBuilder(
      animation: _animationController,
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
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : () {
              if (widget.enableHapticFeedback) {
                HapticFeedback.mediumImpact();
              }
              widget.onPressed?.call();
            },
            style: buttonStyle,
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[  
                        Icon(
                          widget.icon,
                          color: buttonStyle.foregroundColor?.resolve({}),
                          size: ResponsiveLayout.getResponsiveFontSize(context, 18),
                        ),
                        SizedBox(width: DesignSystem.spacingS),
                      ],
                      widget.child,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}