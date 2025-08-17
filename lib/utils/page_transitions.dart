import 'package:flutter/material.dart';

class PageTransitions {
  // Smooth fade transition
  static PageRouteBuilder<T> fadeTransition<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  // Smooth slide transition from right
  static PageRouteBuilder<T> slideFromRight<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  // Smooth slide transition from bottom
  static PageRouteBuilder<T> slideFromBottom<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  // Smooth scale transition
  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutBack,
          ),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  // Hero transition with fade
  static PageRouteBuilder<T> heroTransition<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  // Custom transition with multiple effects
  static PageRouteBuilder<T> customTransition<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOutCubic,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: curve,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: curve,
            )),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: curve,
              )),
              child: child,
            ),
          ),
        );
      },
      transitionDuration: duration,
    );
  }
}

// Extension for easy access to transitions
extension PageTransitionExtension on Widget {
  Widget withFadeTransition(BuildContext context, {Duration? duration}) {
    return PageTransitions.fadeTransition(
      child: this,
      duration: duration ?? const Duration(milliseconds: 300),
    ).pageBuilder(context, const AlwaysStoppedAnimation(1.0), const AlwaysStoppedAnimation(1.0));
  }

  Widget withSlideTransition(BuildContext context, {Duration? duration}) {
    return PageTransitions.slideFromRight(
      child: this,
      duration: duration ?? const Duration(milliseconds: 300),
    ).pageBuilder(context, const AlwaysStoppedAnimation(1.0), const AlwaysStoppedAnimation(1.0));
  }
}
