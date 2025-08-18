import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:around_you/services/auth_service.dart';
import 'package:around_you/services/firebase_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();

  /// Create a new chat between two users
  Future<String?> createChat(String otherUserId, String otherUserName) async {
    try {
      final currentUser = await _authService.getUserInfo();
      if (currentUser == null) return null;

      final chatData = {
        'participants': [currentUser['userId'], otherUserId],
        'participantNames': [currentUser['name'], otherUserName],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final chatRef = await _firestore.collection('chats').add(chatData);
      return chatRef.id;
    } catch (e) {
      print('Error creating chat: $e');
      return null;
    }
  }

  /// Send a message in a chat
  Future<bool> sendMessage(String chatId, String message) async {
    try {
      final currentUser = await _authService.getUserInfo();
      if (currentUser == null) return false;

      final messageData = {
        'chatId': chatId,
        'senderId': currentUser['userId'],
        'senderName': currentUser['name'],
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      await _firestore.collection('messages').add(messageData);

      // Update chat with last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  /// Get messages for a specific chat
  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get all chats for the current user
  Stream<QuerySnapshot> getUserChats() async* {
    try {
      final currentUser = await _authService.getUserInfo();
      if (currentUser == null) return;

      yield* _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUser['userId'])
          .orderBy('updatedAt', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting user chats: $e');
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final currentUser = await _authService.getUserInfo();
      if (currentUser == null) return;

      // Mark all unread messages as read
      final messagesQuery = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .where('senderId', isNotEqualTo: currentUser['userId'])
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesQuery.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Reset unread count
      batch.update(
        _firestore.collection('chats').doc(chatId),
        {'unreadCount': 0},
      );

      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  /// Create or join a community
  Future<String?> createCommunity(String name, String description) async {
    try {
      final currentUser = await _authService.getUserInfo();
      if (currentUser == null) return null;

      final communityData = {
        'name': name,
        'description': description,
        'creatorId': currentUser['userId'],
        'creatorName': currentUser['name'],
        'members': [currentUser['userId']],
        'memberCount': 1,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final communityRef = await _firestore.collection('communities').add(communityData);
      return communityRef.id;
    } catch (e) {
      print('Error creating community: $e');
      return null;
    }
  }

  /// Join a community
  Future<bool> joinCommunity(String communityId) async {
    try {
      final currentUser = await _authService.getUserInfo();
      if (currentUser == null) return false;

      await _firestore.collection('communities').doc(communityId).update({
        'members': FieldValue.arrayUnion([currentUser['userId']]),
        'memberCount': FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      print('Error joining community: $e');
      return false;
    }
  }

  /// Get all communities
  Stream<QuerySnapshot> getCommunities() {
    return _firestore
        .collection('communities')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  /// Send message to community
  Future<bool> sendCommunityMessage(String communityId, String message) async {
    try {
      final currentUser = await _authService.getUserInfo();
      if (currentUser == null) return false;

      final messageData = {
        'communityId': communityId,
        'senderId': currentUser['userId'],
        'senderName': currentUser['name'],
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      await _firestore.collection('community_messages').add(messageData);

      // Update community with last message
      await _firestore.collection('communities').doc(communityId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error sending community message: $e');
      return false;
    }
  }

  /// Get community messages
  Stream<QuerySnapshot> getCommunityMessages(String communityId) {
    return _firestore
        .collection('community_messages')
        .where('communityId', isEqualTo: communityId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Search for users to start a chat with
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final currentUser = await _authService.getUserInfo();
      if (currentUser == null) return [];

      final usersQuery = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .limit(10)
          .get();

      return usersQuery.docs
          .where((doc) => doc.id != currentUser['userId'])
          .map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown User',
          'avatar': data['avatar'] ?? '👤',
          'isOnline': data['isOnline'] ?? false,
        };
      }).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Get chat participants
  Future<List<Map<String, dynamic>>> getChatParticipants(String chatId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return [];

      final data = chatDoc.data()!;
      final participants = data['participants'] as List<dynamic>;
      final participantNames = data['participantNames'] as List<dynamic>;

      final participantsList = <Map<String, dynamic>>[];
      for (int i = 0; i < participants.length; i++) {
        participantsList.add({
          'id': participants[i],
          'name': participantNames[i],
        });
      }

      return participantsList;
    } catch (e) {
      print('Error getting chat participants: $e');
      return [];
    }
  }

  /// Delete a chat
  Future<bool> deleteChat(String chatId) async {
    try {
      final currentUser = await _authService.getUserInfo();
      if (currentUser == null) return false;

      // Check if user is participant
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return false;

      final data = chatDoc.data()!;
      final participants = data['participants'] as List<dynamic>;
      
      if (!participants.contains(currentUser['userId'])) return false;

      // Delete chat and all messages
      final batch = _firestore.batch();
      
      // Delete messages
      final messagesQuery = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .get();
      
      for (final doc in messagesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete chat
      batch.delete(_firestore.collection('chats').doc(chatId));

      await batch.commit();
      return true;
    } catch (e) {
      print('Error deleting chat: $e');
      return false;
    }
  }

  /// Get unread message count for a user
  Stream<int> getUnreadMessageCount() async* {
    try {
      final currentUser = await _authService.getUserInfo();
      if (currentUser == null) return;

      yield* _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUser['userId'])
          .snapshots()
          .map((snapshot) {
        int totalUnread = 0;
        for (final doc in snapshot.docs) {
          totalUnread += (doc.data()['unreadCount'] ?? 0) as int;
        }
        return totalUnread;
      });
    } catch (e) {
      print('Error getting unread count: $e');
      yield 0;
    }
  }
}
