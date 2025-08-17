import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_form_field.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/loading_animation.dart';

/// AroundYou Design System
/// A unified collection of UI components and styles for consistent design across the app
class DesignSystem {
  // Typography
  static TextStyle get headingLarge => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get headingMedium => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      );

  static TextStyle get headingSmall => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.1,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.1,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.1,
      );

  static TextStyle get caption => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.2,
      );

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;
  static const double radiusCircular = 100.0;

  // Elevation
  static List<BoxShadow> get elevationLow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevationMedium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevationHigh => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  
  // Animation Curves
  static const Curve animationCurveMedium = Curves.easeInOut;
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  
  // Colors
  static const Color colorPrimary = Color(0xFF3F51B5);
  static const Color colorSecondary = Color(0xFF2196F3);
  static const Color colorText = Color(0xFF212121);
  static const Color colorTextLight = Color(0xFF757575);
  static const Color colorError = Color(0xFFE53935);
  static const Color colorBackgroundLight = Color(0xFFF5F5F5);
  static const Color colorBorder = Color(0xFFE0E0E0);

  // Animation Curves
  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.easeOutCubic;
  static const Curve curveDecelerate = Curves.decelerate;
  static const Curve curveAccelerate = Curves.easeIn;
  static const Curve curveElastic = Curves.elasticOut;

  // Factory methods for common components
  static AnimatedButton primaryButton({
    required VoidCallback onPressed,
    required Widget child,
    bool isLoading = false,
    double width = double.infinity,
    double height = 56,
    Color? backgroundColor,
    Color? textColor,
    BuildContext? context,
  }) {
    final theme = context != null ? Theme.of(context) : null;
    final bgColor = backgroundColor ?? theme?.colorScheme.primary ?? AppTheme.primaryDark;
    final txtColor = textColor ?? theme?.colorScheme.onPrimary ?? Colors.white;

    return AnimatedButton(
      onPressed: onPressed,
      isLoading: isLoading,
      loadingColor: txtColor,
      width: width,
      height: height,
      backgroundColor: bgColor,
      foregroundColor: txtColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      child: child,
    );
  }

  static AnimatedButton secondaryButton({
    required VoidCallback onPressed,
    required Widget child,
    bool isLoading = false,
    double width = double.infinity,
    double height = 56,
    Color? borderColor,
    Color? textColor,
    BuildContext? context,
  }) {
    final theme = context != null ? Theme.of(context) : null;
    final border = borderColor ?? theme?.colorScheme.primary ?? AppTheme.primaryDark;
    final txtColor = textColor ?? theme?.colorScheme.primary ?? AppTheme.primaryDark;

    return AnimatedButton(
      onPressed: onPressed,
      isLoading: isLoading,
      loadingColor: txtColor,
      width: width,
      height: height,
      backgroundColor: Colors.transparent,
      foregroundColor: txtColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
        side: BorderSide(color: border, width: 2),
      ),
      child: child,
    );
  }

  static AnimatedFormField textField({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    IconData? suffixIcon,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    BuildContext? context,
  }) {
    final theme = context != null ? Theme.of(context) : null;
    final primaryColor = theme?.colorScheme.primary ?? colorPrimary;

    return AnimatedFormField(
      controller: controller,
      labelText: labelText ?? '',
      hintText: hintText ?? '',
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      prefixIcon: prefixIcon ?? Icons.edit,
      suffixIcon: suffixIcon,
      focusNode: focusNode,
      onChanged: onChanged,
    );
  }

  static GlassmorphicCard card({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double borderRadius = radiusM,
    double blur = 10,
    // opacity parameter removed as it's not supported in GlassmorphicContainer
    Color? borderColor,
    Color? backgroundColor,
    List<BoxShadow>? boxShadow,
    LinearGradient? gradient,
    VoidCallback? onTap,
    double? width,
    double? height,
    BuildContext? context,
  }) {
    final theme = context != null ? Theme.of(context) : null;
    final border = borderColor ?? theme?.colorScheme.primary.withOpacity(0.3) ?? 
        colorPrimary.withOpacity(0.3);
    final bgColor = backgroundColor ?? Colors.white.withOpacity(0.1);

    return GlassmorphicCard(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(spacingM),
      borderRadius: borderRadius,
      blur: blur,
      borderColor: border,
      backgroundColor: bgColor,
      boxShadow: boxShadow,
      onTap: onTap,
      width: width,
      height: height,
      child: child,
    );
  }

  static LoadingAnimation loadingIndicator({
    LoadingAnimationType type = LoadingAnimationType.circular,
    Color? color,
    double size = 40.0,
    String? message,
    bool showBackground = false,
    Duration duration = const Duration(milliseconds: 1500),
    BuildContext? context,
  }) {
    final theme = context != null ? Theme.of(context) : null;
    final indicatorColor = color ?? theme?.colorScheme.primary ?? colorPrimary;

    return LoadingAnimation(
      type: type,
      color: indicatorColor,
      size: size,
      message: message,
      showBackground: showBackground,
      duration: duration,
    );
  }
}