import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import all your screen files here
import 'package:around_you/screens/onboarding_screen.dart';
import 'package:around_you/screens/login_screen.dart';
import 'package:around_you/screens/home_map_screen.dart';
import 'package:around_you/screens/ar_memory_screen.dart';
import 'package:around_you/screens/social_discovery_screen.dart';
import 'package:around_you/screens/achievements_screen.dart';
import 'package:around_you/screens/chat_screen.dart';
import 'package:around_you/screens/profile_screen.dart';
import 'package:around_you/screens/settings_screen.dart';
import 'package:around_you/screens/memory_details_screen.dart';
import 'package:around_you/screens/notifications_screen.dart';
import 'package:around_you/screens/help_screen.dart';

// Provider for the router
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding', // The app starts with the onboarding screen
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeMapScreen(),
      ),
      GoRoute(
        path: '/create-memory',
        builder: (context, state) => const ARMemoryScreen(),
      ),
      GoRoute(
        path: '/discover',
        builder: (context, state) => const SocialDiscoveryScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/chat/:userId', // Example of a route with a parameter
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ChatScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
       GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
       GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
       GoRoute(
        path: '/memory-details/:memoryId',
        builder: (context, state) {
           final memoryId = state.pathParameters['memoryId']!;
           return MemoryDetailsScreen(memoryId: memoryId);
        },
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpScreen(),
      ),
    ],
  );
});
