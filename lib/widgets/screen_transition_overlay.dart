import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'loading_animation.dart';
import '../theme/theme.dart';

enum TransitionType {
  fade,
  slideUp,
  slideDown,
  scale,
}

class ScreenTransitionOverlay extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final TransitionType transitionType;
  final Duration duration;
  final VoidCallback? onTransitionComplete;

  const ScreenTransitionOverlay({
    Key? key,
    required this.child,
    this.isLoading = false,
    this.loadingMessage,
    this.transitionType = TransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.onTransitionComplete,
  }) : super(key: key);

  @override
  State<ScreenTransitionOverlay> createState() => _ScreenTransitionOverlayState();
}

class _ScreenTransitionOverlayState extends State<ScreenTransitionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.transitionType == TransitionType.slideUp
          ? const Offset(0.0, 0.1)
          : const Offset(0.0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Start the animation
    _controller.forward().then((_) {
      if (widget.onTransitionComplete != null) {
        widget.onTransitionComplete!();
      }
    });

    // Add haptic feedback when transition starts
    HapticFeedback.lightImpact();
  }

  @override
  void didUpdateWidget(ScreenTransitionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      // Add haptic feedback when loading state changes
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (widget.transitionType) {
      case TransitionType.fade:
        content = FadeTransition(
          opacity: _fadeAnimation,
          child: widget.child,
        );
        break;

      case TransitionType.slideUp:
      case TransitionType.slideDown:
        content = SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
        break;

      case TransitionType.scale:
        content = ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
        break;
    }

    return Stack(
      children: [
        content,
        if (widget.isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: LoadingAnimation(
                type: LoadingAnimationType.circular,
                message: widget.loadingMessage,
                showBackground: true,
                color: AppTheme.accentGold,
              ),
            ),
          ),
      ],
    );
  }
}