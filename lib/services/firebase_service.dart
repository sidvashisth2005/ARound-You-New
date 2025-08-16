import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Authentication methods
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      try {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'displayName': displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
          'isOnline': true,
          'interests': [],
          'bio': '',
          'avatarUrl': null,
          'location': null,
          'memories': [],
          'friends': [],
          'achievements': [],
        });
      } catch (firestoreError) {
        print('Warning: Could not create user profile in Firestore: $firestoreError');
        // If Firestore fails, we should still allow the user to sign up
        // but we'll need to handle this case in the UI
      }

      // Update display name
      try {
        await credential.user!.updateDisplayName(displayName);
      } catch (displayNameError) {
        print('Warning: Could not update display name: $displayNameError');
      }

      return credential;
    } catch (e) {
      print('Sign-up error: $e');
      rethrow;
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ensure user profile exists in Firestore
      await ensureUserExists();

      // Update last seen and online status
      try {
        await _firestore.collection('users').doc(credential.user!.uid).update({
          'lastSeen': FieldValue.serverTimestamp(),
          'isOnline': true,
        });
      } catch (firestoreError) {
        print('Warning: Could not update user status in Firestore: $firestoreError');
        // Don't fail the sign-in if Firestore update fails
      }

      return credential;
    } catch (e) {
      print('Sign-in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // Update offline status
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser!.uid).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }

      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // User profile methods
  Future<void> updateUserProfile({
    String? displayName,
    String? bio,
    List<String>? interests,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (interests != null) updates['interests'] = interests;

      await _firestore.collection('users').doc(currentUser!.uid).update(updates);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserLocation(Position position) async {
    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'location': GeoPoint(position.latitude, position.longitude),
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> uploadUserAvatar(File imageFile) async {
    try {
      // Upload to Cloudinary instead of Firebase Storage
      final cloudinary = CloudinaryPublic('your_cloud_name', 'your_upload_preset');
      
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'avatars',
        ),
      );

      final downloadUrl = response.secureUrl;

      // Update user profile with new avatar URL
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'avatarUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Get user data
  Stream<Map<String, dynamic>?> getUserDataStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data());
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      rethrow;
    }
  }

  // Get nearby users
  Stream<List<Map<String, dynamic>>> getNearbyUsers(
    Position currentPosition,
    double radiusKm,
  ) {
    return _firestore
        .collection('users')
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final users = <Map<String, dynamic>>[];
      
      for (final doc in snapshot.docs) {
        final userData = doc.data();
        if (userData['location'] != null && doc.id != currentUser!.uid) {
          final userLocation = userData['location'] as GeoPoint;
          final distance = Geolocator.distanceBetween(
            currentPosition.latitude,
            currentPosition.longitude,
            userLocation.latitude,
            userLocation.longitude,
          );

          if (distance <= radiusKm * 1000) {
            users.add({
              ...userData,
              'uid': doc.id,
              'distance': distance,
              'distanceText': _formatDistance(distance),
            });
          }
        }
      }

      // Sort by distance
      users.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
      return users;
    });
  }

  // Memory methods
  Future<void> createMemory({
    required String title,
    required String description,
    required Position location,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        // Upload image to Cloudinary
        final cloudinary = CloudinaryPublic('your_cloud_name', 'your_upload_preset');
        
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imageFile.path,
            resourceType: CloudinaryResourceType.Image,
            folder: 'memories',
          ),
        );
        
        imageUrl = response.secureUrl;
      }

      final memoryData = {
        'title': title,
        'description': description,
        'location': GeoPoint(location.latitude, location.longitude),
        'createdBy': currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
        'likes': [],
        'comments': [],
      };

      final docRef = await _firestore.collection('memories').add(memoryData);

      // Add memory to user's memories list
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'memories': FieldValue.arrayUnion([docRef.id]),
      });
    } catch (e) {
      rethrow;
    }
  }



  Stream<List<Map<String, dynamic>>> getNearbyMemories(
    Position currentPosition,
    double radiusKm,
  ) {
    return _firestore
        .collection('memories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final memories = <Map<String, dynamic>>[];
      
      for (final doc in snapshot.docs) {
        final memoryData = doc.data();
        if (memoryData['location'] != null) {
          final memoryLocation = memoryData['location'] as GeoPoint;
          final distance = Geolocator.distanceBetween(
            currentPosition.latitude,
            currentPosition.longitude,
            memoryLocation.latitude,
            memoryLocation.longitude,
          );

          if (distance <= radiusKm * 1000) {
            memories.add({
              ...memoryData,
              'id': doc.id,
              'distance': distance,
              'distanceText': _formatDistance(distance),
            });
          }
        }
      }

      // Sort by distance
      memories.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
      return memories;
    });
  }

  // Friend methods
  Future<void> sendFriendRequest(String targetUserId) async {
    try {
      await _firestore.collection('friendRequests').add({
        'fromUserId': currentUser!.uid,
        'toUserId': targetUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      final requestDoc = await _firestore.collection('friendRequests').doc(requestId).get();
      final requestData = requestDoc.data();
      
      if (requestData != null) {
        final fromUserId = requestData['fromUserId'] as String;
        final toUserId = requestData['toUserId'] as String;

        // Add to both users' friends lists
        await _firestore.collection('users').doc(fromUserId).update({
          'friends': FieldValue.arrayUnion([toUserId]),
        });
        
        await _firestore.collection('users').doc(toUserId).update({
          'friends': FieldValue.arrayUnion([fromUserId]),
        });

        // Update request status
        await _firestore.collection('friendRequests').doc(requestId).update({
          'status': 'accepted',
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Chat methods
  Future<void> sendMessage(String chatId, String message) async {
    try {
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': currentUser!.uid,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update chat last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': currentUser!.uid,
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Utility methods
  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
  }

  // Check if user exists and create if not
  Future<void> ensureUserExists() async {
    if (currentUser != null) {
      final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (!userDoc.exists) {
        // Create user profile if it doesn't exist
        await _firestore.collection('users').doc(currentUser!.uid).set({
          'uid': currentUser!.uid,
          'email': currentUser!.email,
          'displayName': currentUser!.displayName ?? 'User',
          'createdAt': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
          'isOnline': true,
          'interests': [],
          'bio': '',
          'avatarUrl': currentUser!.photoURL,
          'location': null,
          'memories': [],
          'friends': [],
          'achievements': [],
        });
      }
    }
  }
} 