import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/firebase_options.dart';
import 'package:around_you/services/auth_service.dart';
import 'package:around_you/services/cloudinary_service.dart';
import 'package:around_you/services/permission_service.dart';
import 'package:around_you/services/location_service.dart';
import 'package:around_you/services/ar_service.dart';
import 'package:around_you/router/router.dart';
import 'package:around_you/theme/theme.dart';
import 'package:around_you/utils/firebase_checker.dart';

// Global navigator key for accessing context outside of build
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize services
  await _initializeServices();
  
  // Check Firebase status for debugging
  FirebaseChecker.printStatus();
  
  runApp(const ARoundYouApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize Cloudinary service
    CloudinaryService().initialize();
    
    // Initialize Auth service
    await AuthService().initialize();
    
    // Initialize Permission service
    await PermissionService().initializePermissions();
    
    // Initialize Location service
    await LocationService().initialize();
    
    // Initialize AR Camera service
    await ARService().initializeCamera();
    
    debugPrint('All services initialized successfully');
  } catch (e) {
    debugPrint('Error initializing services: $e');
  }
}

class ARoundYouApp extends StatefulWidget {
  const ARoundYouApp({super.key});

  @override
  State<ARoundYouApp> createState() => _ARoundYouAppState();
}

class _ARoundYouAppState extends State<ARoundYouApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Dispose AR service camera to prevent memory leaks
    ARService().disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Handle app lifecycle changes
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // Dispose camera when app goes to background
        ARService().disposeCamera();
        break;
      case AppLifecycleState.resumed:
        // Reinitialize camera when app comes to foreground
        ARService().initializeCamera();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Around You',
      theme: AppTheme.elegantTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return WillPopScope(
          onWillPop: () async {
            // Handle back button press
            final navigator = Navigator.of(context);
            final router = GoRouter.of(context);
            
            // Check if we can pop the current route
            if (navigator.canPop()) {
              navigator.pop();
              return false;
            }
            
            // Check if we're at a main screen that should exit the app
            final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
            final mainScreens = ['/home', '/around', '/chat', '/achievements', '/profile'];
            
            if (mainScreens.contains(currentLocation)) {
              // Show exit confirmation for main screens
              final shouldExit = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.black,
                  title: const Text(
                    'Exit App',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Are you sure you want to exit the app?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Exit'),
                    ),
                  ],
                ),
              );
              return shouldExit ?? false;
            }
            
            // For other screens, try to navigate back to home
            router.go('/home');
            return false;
          },
          child: child!,
        );
      },
    );
  }
}
