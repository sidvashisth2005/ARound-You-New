import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:around_you/firebase_options.dart';
import 'package:around_you/router/router.dart';
import 'package:around_you/theme/theme.dart';
import 'package:around_you/utils/firebase_checker.dart';

// Global navigator key for accessing context outside of build
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Check Firebase status for debugging
  FirebaseChecker.printStatus();
  
  runApp(const ARoundYouApp());
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
    );
  }
}
