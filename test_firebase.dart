import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Simple test script to verify Firebase connectivity
// Run this with: dart test_firebase.dart

void main() async {
  try {
    print('🚀 Testing Firebase connectivity...');
    
    // Initialize Firebase
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
    
    // Test Firestore connection
    final firestore = FirebaseFirestore.instance;
    print('📚 Testing Firestore connection...');
    
    try {
      // Try to read from a test collection
      final testDoc = await firestore.collection('test').doc('connection').get();
      print('✅ Firestore read successful');
    } catch (e) {
      print('❌ Firestore read failed: $e');
      print('This might be due to security rules or connection issues');
    }
    
    // Test Authentication
    final auth = FirebaseAuth.instance;
    print('🔐 Testing Authentication...');
    
    try {
      // Check if there are any existing users
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        print('✅ User is already signed in: ${currentUser.email}');
      } else {
        print('ℹ️ No user currently signed in');
      }
      
      // Test anonymous sign-in (if enabled)
      try {
        final anonymousCredential = await auth.signInAnonymously();
        print('✅ Anonymous sign-in successful: ${anonymousCredential.user?.uid}');
        
        // Sign out
        await auth.signOut();
        print('✅ Sign out successful');
      } catch (e) {
        print('ℹ️ Anonymous sign-in not enabled or failed: $e');
      }
      
    } catch (e) {
      print('❌ Authentication test failed: $e');
    }
    
    print('\n🎯 Firebase connectivity test completed!');
    print('\nIf you see any ❌ errors above, check:');
    print('1. Your Firebase configuration');
    print('2. Security rules deployment');
    print('3. Internet connection');
    print('4. Firebase Console settings');
    
  } catch (e) {
    print('💥 Critical error: $e');
    print('\nThis usually means:');
    print('1. Firebase configuration is missing or incorrect');
    print('2. Firebase services are not enabled');
    print('3. Network connectivity issues');
  }
}
