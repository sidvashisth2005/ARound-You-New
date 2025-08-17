import 'package:flutter/material.dart';

enum PageTransitionType {
  fade,
  scale,
  slideRight,
  slideLeft,
  slideUp,
  slideDown,
}

class PageTransition extends PageRouteBuilder {
  final Widget child;
  final PageTransitionType type;
  final Curve curve;
  final Alignment? alignment;
  final Duration duration;

  PageTransition({
    required this.child,
    this.type = PageTransitionType.fade,
    this.curve = Curves.easeInOut,
    this.alignment,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return child;
          },
          transitionDuration: duration,
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            switch (type) {
              case PageTransitionType.fade:
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              case PageTransitionType.scale:
                return ScaleTransition(
                  scale: animation,
                  alignment: alignment ?? Alignment.center,
                  child: child,
                );
              case PageTransitionType.slideRight:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              case PageTransitionType.slideLeft:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              case PageTransitionType.slideUp:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              case PageTransitionType.slideDown:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              default:
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
            }
          },
        );
}

class FadePageTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const FadePageTransition({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
}