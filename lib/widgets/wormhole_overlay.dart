import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WormholeOverlay extends StatefulWidget {
  final bool isVisible;
  final Duration fadeDuration;
  final String animationAssetPath; // Lottie JSON path
  final double size;

  const WormholeOverlay({
    super.key,
    required this.isVisible,
    required this.animationAssetPath,
    this.fadeDuration = const Duration(milliseconds: 600),
    this.size = 220,
  });

  @override
  State<WormholeOverlay> createState() => _WormholeOverlayState();
}

class _WormholeOverlayState extends State<WormholeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant WormholeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !_controller.isCompleted) {
      _controller.forward();
    } else if (!widget.isVisible && !_controller.isDismissed) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: true,
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Center(
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Lottie.asset(
                widget.animationAssetPath,
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}