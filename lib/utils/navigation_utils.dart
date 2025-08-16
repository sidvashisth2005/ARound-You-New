import 'package:flutter/material.dart';
import '../widgets/page_transition.dart';

class NavigationUtils {
  /// Navigate to a new screen with a transition animation
  static Future<T?> navigateTo<T>(
    BuildContext context,
    Widget screen, {
    PageTransitionType transitionType = PageTransitionType.slideLeft,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    Alignment? alignment,
    bool replace = false,
  }) {
    final route = PageTransition(
      child: screen,
      type: transitionType,
      duration: duration,
      curve: curve,
      alignment: alignment,
    );

    if (replace) {
      return Navigator.pushReplacement(context, route as Route<T>);
    } else {
      return Navigator.push(context, route as Route<T>);
    }
  }

  /// Navigate to a named route with a transition animation
  static Future<T?> navigateToNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool replace = false,
  }) {
    if (replace) {
      return Navigator.pushReplacementNamed(
        context,
        routeName,
        arguments: arguments,
      );
    } else {
      return Navigator.pushNamed(
        context,
        routeName,
        arguments: arguments,
      );
    }
  }

  /// Pop the current screen with a transition animation
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  /// Pop until a specific route name
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, (route) {
      return route.settings.name == routeName;
    });
  }

  /// Clear the navigation stack and navigate to a named route
  static Future<T?> clearStackAndNavigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}