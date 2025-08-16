import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';

enum LoadingAnimationType {
  circular,
  pulse,
  dots,
  shimmer,
}

class LoadingAnimation extends StatefulWidget {
  final LoadingAnimationType type;
  final Color? color;
  final double size;
  final String? message;
  final bool showBackground;
  final Duration duration;

  const LoadingAnimation({
    Key? key,
    this.type = LoadingAnimationType.circular,
    this.color,
    this.size = 40.0,
    this.message,
    this.showBackground = false,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    _controller.repeat(reverse: widget.type == LoadingAnimationType.pulse);
    
    // Add haptic feedback when loading starts
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;

    Widget loadingWidget;

    switch (widget.type) {
      case LoadingAnimationType.circular:
        loadingWidget = RotationTransition(
          turns: _rotationAnimation,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 3,
          ),
        );
        break;

      case LoadingAnimationType.pulse:
        loadingWidget = AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
        break;

      case LoadingAnimationType.dots:
        loadingWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (index) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delay = index * 0.2;
                final progress = (_controller.value + delay) % 1.0;
                final scale = 0.5 + (progress < 0.5 ? progress : 1.0 - progress);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: widget.size * 0.3 * scale,
                  height: widget.size * 0.3 * scale,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ),
        );
        break;

      case LoadingAnimationType.shimmer:
        loadingWidget = AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: widget.size * 2,
              height: widget.size * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size * 0.3),
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.6),
                    color.withOpacity(0.3),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment(-1.0 + _controller.value * 2, 0.0),
                  end: Alignment(1.0 + _controller.value * 2, 0.0),
                ),
              ),
            );
          },
        );
        break;
    }

    Widget result = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Center(child: loadingWidget),
        ),
        if (widget.message != null) ...[  
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (widget.showBackground) {
      result = Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.subtleShadows,
        ),
        child: result,
      );
    }

    return result;
  }
}