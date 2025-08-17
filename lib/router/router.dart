import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Import all your screen files here
import 'package:around_you/screens/onboarding_screen.dart';
import 'package:around_you/screens/login_screen.dart';
import 'package:around_you/screens/home_screen.dart';
import 'package:around_you/screens/around_screen.dart';
import 'package:around_you/screens/ar_memory_screen.dart';
import 'package:around_you/screens/create_memory_screen.dart';
import 'package:around_you/screens/memory_details_screen.dart';
import 'package:around_you/screens/achievements_screen.dart';
import 'package:around_you/screens/profile_screen.dart';
import 'package:around_you/screens/social_discovery_screen.dart';
import 'package:around_you/screens/notifications_screen.dart';
import 'package:around_you/screens/chat_screen.dart';
import 'package:around_you/screens/help_screen.dart';
import 'package:around_you/utils/page_transitions.dart';

// Simple router without authentication for now
final router = GoRouter(
  initialLocation: '/onboarding',
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
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/around',
      builder: (context, state) => const AroundScreen(),
    ),
    GoRoute(
      path: '/create-memory',
      builder: (context, state) => const CreateMemoryScreen(),
    ),
    GoRoute(
      path: '/ar-memory',
      builder: (context, state) => const ARMemoryScreen(),
    ),
    GoRoute(
      path: '/memory/:id',
      builder: (context, state) => MemoryDetailsScreen(
        memoryId: state.pathParameters['id']!,
      ),
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
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: '/community',
      builder: (context, state) => const SocialDiscoveryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const HelpScreen(), // Using help screen as settings for now
    ),
  ],
);
