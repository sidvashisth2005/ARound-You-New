import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:around_you/firebase_options.dart'; // Generate this with FlutterFire CLI
import 'package:around_you/theme/theme.dart';
import 'package:around_you/router/router.dart';

void main() async {
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app within a ProviderScope for Riverpod state management
  runApp(const ProviderScope(child: ARoundYouApp()));
}

class ARoundYouApp extends ConsumerWidget {
  const ARoundYouApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the router from the provider
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ARound You',
      // Set the dark, cyberpunk-inspired theme
      theme: AppTheme.darkTheme,
      // Disable the debug banner
      debugShowCheckedModeBanner: false,
      // Use the GoRouter configuration
      routerConfig: router,
    );
  }
}
