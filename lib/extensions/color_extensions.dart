import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  /// Creates a new color with the specified alpha value
  Color withValues({int? alpha, int? red, int? green, int? blue}) {
    return Color.fromARGB(
      alpha ?? this.alpha,
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }

  /// Creates a lighter version of the color
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Creates a darker version of the color
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Creates a color with the specified opacity
  Color withOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withValues(alpha: (opacity * 255).round());
  }

  /// Returns the contrast color (black or white) for better readability
  Color get contrastColor {
    final luminance = computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Creates a color with adjusted saturation
  Color withSaturation(double saturation) {
    assert(saturation >= 0.0 && saturation <= 1.0);
    final hsl = HSLColor.fromColor(this);
    final hslSaturated = hsl.withSaturation(saturation);
    return hslSaturated.toColor();
  }

  /// Creates a color with adjusted hue
  Color withHue(double hue) {
    assert(hue >= 0.0 && hue <= 360.0);
    final hsl = HSLColor.fromColor(this);
    final hslHued = hsl.withHue(hue);
    return hslHued.toColor();
  }
}
