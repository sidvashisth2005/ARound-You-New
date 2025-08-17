import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/help_screen.dart';
import '../screens/around_screen.dart';
import '../screens/create_memory_screen.dart';
import '../screens/achievements_screen.dart';
import '../screens/ar_memory_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/social_discovery_screen.dart';
import '../screens/notifications_screen.dart';
import '../widgets/page_transition.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/onboarding':
        return PageTransition(
          child: const OnboardingScreen(),
          type: PageTransitionType.fade,
        );

      case '/login':
        return PageTransition(
          child: const LoginScreen(),
          type: PageTransitionType.fade,
        );

      case '/home':
        return PageTransition(
          child: const HomeScreen(),
          type: PageTransitionType.fade,
        );

      case '/profile':
        return PageTransition(
          child: const ProfileScreen(),
          type: PageTransitionType.slideLeft,
        );

      case '/help':
        return PageTransition(
          child: const HelpScreen(),
          type: PageTransitionType.slideLeft,
        );

      case '/around':
        return PageTransition(
          child: const AroundScreen(),
          type: PageTransitionType.slideLeft,
        );

      case '/create-memory':
        final args = settings.arguments as Map<String, dynamic>?;
        final memoryType = args?['type'] as String?;
        return PageTransition(
          child: CreateMemoryScreen(memoryType: memoryType),
          type: PageTransitionType.scale,
          alignment: Alignment.center,
        );

      case '/achievements':
        return PageTransition(
          child: const AchievementsScreen(),
          type: PageTransitionType.slideLeft,
        );

      case '/ar-memory':
        final args = settings.arguments as Map<String, dynamic>?;
        final memoryType = args?['memoryType'] as String? ?? 'text';
        final memoryText = args?['memoryText'] as String?;
        final imagePath = args?['imagePath'] as String?;
        return PageTransition(
          child: ARMemoryScreen(
            memoryType: memoryType,
            memoryText: memoryText,
            imagePath: imagePath,
          ),
          type: PageTransitionType.scale,
          alignment: Alignment.bottomRight,
        );

      case '/settings':
        return PageTransition(
          child: const SettingsScreen(),
          type: PageTransitionType.slideLeft,
        );

      case '/discover':
        return PageTransition(
          child: const SocialDiscoveryScreen(),
          type: PageTransitionType.slideUp,
        );

      case '/notifications':
        return PageTransition(
          child: const NotificationsScreen(),
          type: PageTransitionType.slideDown,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}