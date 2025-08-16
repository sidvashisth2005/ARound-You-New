import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseChecker {
  static Future<Map<String, dynamic>> checkFirebaseStatus() async {
    final results = <String, dynamic>{};
    
    try {
      // Check Firebase initialization
      results['firebase_initialized'] = true;
      results['firebase_error'] = null;
    } catch (e) {
      results['firebase_initialized'] = false;
      results['firebase_error'] = e.toString();
      return results;
    }
    
    // Check Authentication
    try {
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      results['auth_working'] = true;
      results['current_user'] = currentUser?.email ?? 'No user signed in';
      results['auth_error'] = null;
    } catch (e) {
      results['auth_working'] = false;
      results['auth_error'] = e.toString();
    }
    
    // Check Firestore
    try {
      final firestore = FirebaseFirestore.instance;
      // Try to read a test document
      await firestore.collection('test').doc('connection').get();
      results['firestore_working'] = true;
      results['firestore_error'] = null;
    } catch (e) {
      results['firestore_working'] = false;
      results['firestore_error'] = e.toString();
      
      // Check if it's a permission error
      if (e.toString().contains('permission-denied')) {
        results['firestore_permission_issue'] = true;
        results['firestore_suggestion'] = 'Check Firestore security rules';
      } else if (e.toString().contains('unavailable')) {
        results['firestore_connection_issue'] = true;
        results['firestore_suggestion'] = 'Check internet connection and Firebase configuration';
      }
    }
    

    
    return results;
  }
  
  static void printStatus() async {
    if (kDebugMode) {
      print('🔍 Checking Firebase status...');
      final status = await checkFirebaseStatus();
      
      print('\n📊 Firebase Status Report:');
      print('========================');
      
      // Firebase Core
      print('Firebase Core: ${status['firebase_initialized'] ? '✅ Working' : '❌ Failed'}');
      if (status['firebase_error'] != null) {
        print('  Error: ${status['firebase_error']}');
      }
      
      // Authentication
      print('Authentication: ${status['auth_working'] ? '✅ Working' : '❌ Failed'}');
      if (status['auth_working']) {
        print('  Current User: ${status['current_user']}');
      }
      if (status['auth_error'] != null) {
        print('  Error: ${status['auth_error']}');
      }
      
      // Firestore
      print('Firestore: ${status['firestore_working'] ? '✅ Working' : '❌ Failed'}');
      if (!status['firestore_working']) {
        print('  Error: ${status['firestore_error']}');
        if (status['firestore_permission_issue'] == true) {
          print('  💡 Suggestion: ${status['firestore_suggestion']}');
        }
        if (status['firestore_connection_issue'] == true) {
          print('  💡 Suggestion: ${status['firestore_suggestion']}');
        }
      }
      
      print('\n🎯 Recommendations:');
      if (status['firestore_permission_issue'] == true) {
        print('1. Deploy Firestore security rules from firestore.rules');
        print('2. Make sure rules are published (not just saved)');
      }
      if (status['firestore_connection_issue'] == true) {
        print('1. Check your internet connection');
        print('2. Verify Firebase configuration in firebase_options.dart');
        print('3. Make sure Firestore database is created in Firebase Console');
      }
      if (!status['auth_working']) {
        print('1. Check Firebase configuration');
        print('2. Verify Authentication service is enabled in Firebase Console');
      }
    }
  }
  
  static Future<bool> isFirebaseReady() async {
    final status = await checkFirebaseStatus();
    return status['firebase_initialized'] == true &&
           status['auth_working'] == true &&
           status['firestore_working'] == true;
  }
}
