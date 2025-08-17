import 'package:flutter/material.dart';
import 'dart:ui';

class GlassmorphicContainer extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final double borderRadius;
  final double blur;
  final double border;

  const GlassmorphicContainer({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.borderRadius = 20,
    this.blur = 10,
    this.border = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.15),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              width: border,
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
