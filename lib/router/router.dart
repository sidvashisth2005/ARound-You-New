import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:around_you/services/auth_service.dart';
import 'dart:io';

// Import all your screen files here
import 'package:around_you/screens/onboarding_screen.dart';
import 'package:around_you/screens/login_screen.dart';
import 'package:around_you/screens/home_screen.dart';
import 'package:around_you/screens/around_screen.dart';
import 'package:around_you/screens/ar_memory_screen.dart';
import 'package:around_you/screens/create_memory_screen.dart';
import 'package:around_you/screens/create_memory_details_screen.dart';
import 'package:around_you/screens/model_selection_screen.dart';
import 'package:around_you/screens/memory_details_screen.dart';
import 'package:around_you/screens/achievements_screen.dart';
import 'package:around_you/screens/profile_screen.dart';
import 'package:around_you/screens/social_discovery_screen.dart';
import 'package:around_you/screens/notifications_screen.dart';
import 'package:around_you/screens/chat_screen.dart';
import 'package:around_you/screens/help_screen.dart';
import 'package:around_you/screens/chat_thread_screen.dart';


// Router with authentication handling
final router = GoRouter(
  initialLocation: '/onboarding',
  redirect: (context, state) async {
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();
    
    // If user is not logged in and trying to access protected routes
    if (!isLoggedIn && state.matchedLocation != '/onboarding' && state.matchedLocation != '/login') {
      return '/login';
    }
    
    // If user is logged in and trying to access login/onboarding
    if (isLoggedIn && (state.matchedLocation == '/login' || state.matchedLocation == '/onboarding')) {
      return '/home';
    }
    
    return null;
  },
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
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CreateMemoryScreen(
          memoryType: extra != null ? extra['memoryType'] as String? : null,
        );
      },
    ),
    GoRoute(
      path: '/model-selection',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ModelSelectionScreen(
          memoryType: extra != null ? extra['memoryType'] as String : 'text',
          memoryText: extra != null ? extra['memoryText'] as String? : null,
          mediaFile: extra != null ? extra['mediaFile'] as String? : null,
        );
      },
    ),
    GoRoute(
      path: '/create-memory-details',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CreateMemoryDetailsScreen(
          memoryType: extra != null ? extra['memoryType'] as String : 'text',
          memoryText: extra != null ? extra['memoryText'] as String? : null,
          mediaFile: extra != null ? extra['mediaFile'] as String? : null,
          modelId: extra != null ? extra['modelId'] as String : 'text',
        );
      },
    ),
    GoRoute(
      path: '/ar-memory',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ARMemoryScreen(
          memoryType: extra != null ? extra['memoryType'] as String? : null,
          memoryText: extra != null ? extra['memoryText'] as String? : null,
          mediaFile: extra != null ? extra['mediaFile'] as File? : null,
          modelId: extra != null ? extra['modelId'] as String? : null,
        );
      },
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
      path: '/chat/:id',
      builder: (context, state) {
        final chatId = state.pathParameters['id']!;
        final extra = state.extra as Map<String, dynamic>?;
        return ChatThreadScreen(chatId: chatId, chatName: extra != null ? extra['name'] as String? : null);
      },
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: '/community',
      builder: (context, state) => const ChatScreen(), // Redirect community to chat
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const HelpScreen(), // Using help screen as settings for now
    ),
  ],
);
