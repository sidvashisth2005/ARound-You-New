import 'package:flutter/material.dart';

/// A utility class for responsive design
class ResponsiveLayout {
  /// Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Check if the current screen size is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Check if the current screen size is tablet
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  /// Check if the current screen size is desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  /// Get a value based on the current screen size
  static T getValueForScreenType<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    // Return the appropriate value based on screen width
    if (width >= tabletBreakpoint) {
      return desktop ?? tablet ?? mobile;
    }
    if (width >= mobileBreakpoint) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// Get a responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return getValueForScreenType(
      context: context,
      mobile: const EdgeInsets.all(16.0),
      tablet: const EdgeInsets.all(24.0),
      desktop: const EdgeInsets.all(32.0),
    );
  }

  /// Get a responsive horizontal padding based on screen size
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    return getValueForScreenType(
      context: context,
      mobile: const EdgeInsets.symmetric(horizontal: 16.0),
      tablet: const EdgeInsets.symmetric(horizontal: 48.0),
      desktop: const EdgeInsets.symmetric(horizontal: 64.0),
    );
  }

  /// Get a responsive font size based on screen size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final scaleFactor = getValueForScreenType(
      context: context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
    return baseFontSize * scaleFactor;
  }

  /// Get a responsive width based on screen size percentage
  static double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  /// Get a responsive height based on screen size percentage
  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  /// A responsive widget that shows different widgets based on screen size
  static Widget builder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    // Return the appropriate widget based on screen width
    if (width >= tabletBreakpoint) {
      return desktop ?? tablet ?? mobile;
    }
    if (width >= mobileBreakpoint) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}

/// A widget that adapts its layout based on screen size
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints) mobileBuilder;
  final Widget Function(BuildContext, BoxConstraints)? tabletBuilder;
  final Widget Function(BuildContext, BoxConstraints)? desktopBuilder;

  const ResponsiveLayoutBuilder({
    Key? key,
    required this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= ResponsiveLayout.tabletBreakpoint) {
        return (desktopBuilder ?? tabletBuilder ?? mobileBuilder)(context, constraints);
      }
      if (constraints.maxWidth >= ResponsiveLayout.mobileBreakpoint) {
        return (tabletBuilder ?? mobileBuilder)(context, constraints);
      }
      return mobileBuilder(context, constraints);
    });
  }
}