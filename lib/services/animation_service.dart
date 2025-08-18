import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimationService {
  static const String _basePath = 'assets/animations/';
  
  // Animation file paths
  static const String animationWhileLaunching = 'assets/animations/Animation while launching.json';
  static const String animationAfterCreatingMemory = 'assets/animations/Animation after creating memory.json';
  static const String intermediateLoading = 'assets/animations/Intermidiate Loading.json';
  static const String wormhole = 'assets/animations/wormhole.json';

  // Get animation widget with custom configuration
  static Widget getAnimation({
    required String animationPath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool repeat = true,
  }) {
    return Lottie.asset(
      animationPath,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
    );
  }

  // Launch animation (used in splash/loading screens)
  static Widget getLaunchAnimation({
    double size = 200,
  }) {
    return getAnimation(
      animationPath: animationWhileLaunching,
      width: size,
      height: size,
    );
  }

  // Memory creation success animation
  static Widget getMemoryCreationAnimation({
    double size = 150,
  }) {
    return getAnimation(
      animationPath: animationAfterCreatingMemory,
      width: size,
      height: size,
    );
  }

  // Intermediate loading animation
  static Widget getIntermediateLoadingAnimation({
    double size = 100,
  }) {
    return getAnimation(
      animationPath: intermediateLoading,
      width: size,
      height: size,
    );
  }

  // Wormhole animation for AR
  static Widget getWormholeAnimation({
    double size = 240,
  }) {
    return getAnimation(
      animationPath: wormhole,
      width: size,
      height: size,
    );
  }

  // Animated container with entrance effect
  static Widget getAnimatedContainer({
    required Widget child,
    required bool isVisible,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
    Offset beginOffset = const Offset(0, 0.3),
    Offset endOffset = Offset.zero,
    double beginOpacity = 0.0,
    double endOpacity = 1.0,
  }) {
    return AnimatedSlide(
      duration: duration,
      curve: curve,
      offset: isVisible ? endOffset : beginOffset,
      child: AnimatedOpacity(
        duration: duration,
        curve: curve,
        opacity: isVisible ? endOpacity : beginOpacity,
        child: child,
      ),
    );
  }

  // Pulse animation for interactive elements
  static Widget getPulseAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: minScale, end: maxScale),
      duration: duration,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }

  // Shake animation for error states
  static Widget getShakeAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -5.0, end: 5.0),
      duration: duration,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  // Fade in animation
  static Widget getFadeInAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeIn,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: child,
    );
  }

  // Scale in animation
  static Widget getScaleInAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }
}
