import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:around_you/services/firebase_service.dart';
import 'package:around_you/services/permission_service.dart';

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final FirebaseService _firebaseService;
  final PermissionService _permissionService;

  AuthNotifier(this._firebaseService, this._permissionService) : super(const AsyncValue.loading()) {
    _initializeAuth();
  }

  void _initializeAuth() {
    _firebaseService.authStateChanges.listen((User? user) {
      if (user != null) {
        state = AsyncValue.data(user);
        _initializeUserData();
      } else {
        state = const AsyncValue.data(null);
      }
    });
  }

  Future<void> _initializeUserData() async {
    if (state.value != null) {
      // Request location permission and update user location
      try {
        final locationGranted = await _permissionService.requestLocationPermission();
        if (locationGranted) {
          final position = await _permissionService.getCurrentLocation();
          if (position != null) {
            await _firebaseService.updateUserLocation(position);
          }
        }
      } catch (e) {
        debugPrint('Error initializing user data: $e');
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await _firebaseService.signIn(email: email, password: password);
      // State will be updated by the authStateChanges listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signUp(String email, String password, String displayName, String bio) async {
    try {
      state = const AsyncValue.loading();
      await _firebaseService.signUp(email: email, password: password, displayName: displayName);
      // State will be updated by the authStateChanges listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      // State will be updated by the authStateChanges listener
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  Future<void> updateLocation() async {
    try {
      if (state.value != null) {
        final position = await _permissionService.getCurrentLocation();
        if (position != null) {
          await _firebaseService.updateUserLocation(position);
        }
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  final permissionService = ref.read(permissionServiceProvider);
  return AuthNotifier(firebaseService, permissionService);
});

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
}); 