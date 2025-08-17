import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:around_you/firebase_options.dart';
import 'package:around_you/router/router.dart';
import 'package:around_you/theme/theme.dart';
import 'package:around_you/utils/firebase_checker.dart';
import 'package:around_you/services/auth_service.dart';
import 'package:around_you/services/permission_service.dart';
import 'package:around_you/services/location_service.dart';
import 'package:around_you/services/cloudinary_service.dart';
import 'package:around_you/services/ar_service.dart';

// Global navigator key for accessing context outside of build
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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

class ARoundYouApp extends StatelessWidget {
  const ARoundYouApp({super.key});

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
            if (navigator.canPop()) {
              navigator.pop();
              return false;
            } else {
              // If we're at the root, show exit confirmation
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
          },
          child: child!,
        );
      },
    );
  }
}
