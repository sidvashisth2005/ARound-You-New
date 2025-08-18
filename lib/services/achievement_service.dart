import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:around_you/services/auth_service.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Achievement definitions
  static const Map<String, Map<String, dynamic>> _achievementDefinitions = {
    'first_memory': {
      'title': 'First Memory',
      'description': 'Create your first AR memory',
      'category': 'Creativity',
      'icon': '🎯',
      'xpReward': 100,
      'rarity': 'Common',
      'requirements': {'memories_created': 1},
    },
    'memory_collector': {
      'title': 'Memory Collector',
      'description': 'Create 10 AR memories',
      'category': 'Creativity',
      'icon': '📚',
      'xpReward': 250,
      'rarity': 'Uncommon',
      'requirements': {'memories_created': 10},
    },
    'memory_master': {
      'title': 'Memory Master',
      'description': 'Create 50 AR memories',
      'category': 'Creativity',
      'icon': '👑',
      'xpReward': 1000,
      'rarity': 'Rare',
      'requirements': {'memories_created': 50},
    },
    'explorer': {
      'title': 'Explorer',
      'description': 'Visit 5 different locations',
      'category': 'Exploration',
      'icon': '🗺️',
      'xpReward': 300,
      'rarity': 'Uncommon',
      'requirements': {'locations_visited': 5},
    },
    'social_butterfly': {
      'title': 'Social Butterfly',
      'description': 'Interact with 10 different users',
      'category': 'Social',
      'icon': '🦋',
      'xpReward': 400,
      'rarity': 'Uncommon',
      'requirements': {'users_interacted': 10},
    },
    'early_bird': {
      'title': 'Early Bird',
      'description': 'Use the app for 7 consecutive days',
      'category': 'Mastery',
      'icon': '🌅',
      'xpReward': 500,
      'rarity': 'Rare',
      'requirements': {'consecutive_days': 7},
    },
    'night_owl': {
      'title': 'Night Owl',
      'description': 'Use the app after 10 PM',
      'category': 'Mastery',
      'icon': '🦉',
      'xpReward': 200,
      'rarity': 'Common',
      'requirements': {'night_usage': 1},
    },
    'media_creator': {
      'title': 'Media Creator',
      'description': 'Create memories with all media types',
      'category': 'Creativity',
      'icon': '🎬',
      'xpReward': 600,
      'rarity': 'Rare',
      'requirements': {'media_types_used': 4},
    },
    'location_legend': {
      'title': 'Location Legend',
      'description': 'Create memories in 20 different locations',
      'category': 'Exploration',
      'icon': '🏆',
      'xpReward': 1500,
      'rarity': 'Epic',
      'requirements': {'locations_visited': 20},
    },
    'community_builder': {
      'title': 'Community Builder',
      'description': 'Join 5 communities',
      'category': 'Social',
      'icon': '🏘️',
      'xpReward': 800,
      'rarity': 'Rare',
      'requirements': {'communities_joined': 5},
    },
  };

  /// Get all achievement definitions
  Map<String, Map<String, dynamic>> getAchievementDefinitions() {
    return Map.unmodifiable(_achievementDefinitions);
  }

  /// Get achievements by category
  Map<String, Map<String, dynamic>> getAchievementsByCategory(String category) {
    if (category == 'All') {
      return _achievementDefinitions;
    }
    
    return Map.fromEntries(
      _achievementDefinitions.entries.where(
        (entry) => entry.value['category'] == category,
      ),
    );
  }

  /// Get user achievements stream
  Stream<QuerySnapshot> getUserAchievementsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .snapshots();
  }

  /// Get user achievements
  Future<List<Map<String, dynamic>>> getUserAchievements(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Achievement',
          'description': data['description'] ?? '',
          'icon': data['icon'] ?? '🏆',
          'category': data['category'] ?? 'All',
          'unlocked': data['unlocked'] ?? false,
          'progress': (data['progress'] ?? 0).toDouble(),
          'maxProgress': (data['maxProgress'] ?? 1).toDouble(),
          'xpReward': data['xpReward'] ?? 0,
          'unlockDate': data['unlockDate'],
          'rarity': data['rarity'] ?? 'Common',
          'requirements': data['requirements'] ?? {},
        };
      }).toList();
    } catch (e) {
      print('Error fetching user achievements: $e');
      return [];
    }
  }

  /// Initialize user achievements
  Future<void> initializeUserAchievements(String userId) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      
      // Check if achievements are already initialized
      final achievementsDoc = await userDoc.collection('achievements').get();
      if (achievementsDoc.docs.isNotEmpty) return;

      // Initialize all achievements as locked
      final batch = _firestore.batch();
      
      for (final entry in _achievementDefinitions.entries) {
        final achievementId = entry.key;
        final achievementData = entry.value;
        
        final achievementRef = userDoc.collection('achievements').doc(achievementId);
        batch.set(achievementRef, {
          'title': achievementData['title'],
          'description': achievementData['description'],
          'icon': achievementData['icon'],
          'category': achievementData['category'],
          'unlocked': false,
          'progress': 0.0,
          'maxProgress': _getMaxProgress(achievementData['requirements']),
          'xpReward': achievementData['xpReward'],
          'rarity': achievementData['rarity'],
          'requirements': achievementData['requirements'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      print('✅ User achievements initialized successfully');
    } catch (e) {
      print('❌ Error initializing user achievements: $e');
    }
  }

  /// Update achievement progress
  Future<void> updateAchievementProgress({
    required String userId,
    required String achievementType,
    required int increment,
  }) async {
    try {
      // Find achievements that depend on this type
      final achievementsToUpdate = _achievementDefinitions.entries.where(
        (entry) => entry.value['requirements'].containsKey(achievementType),
      );

      for (final entry in achievementsToUpdate) {
        final achievementId = entry.key;
        final achievementData = entry.value;
        final requirement = achievementData['requirements'][achievementType];
        
        // Update progress
        final userAchievementRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('achievements')
            .doc(achievementId);

        final userAchievementDoc = await userAchievementRef.get();
        if (!userAchievementDoc.exists) continue;

        final currentData = userAchievementDoc.data()!;
        final currentProgress = (currentData['progress'] ?? 0).toDouble();
        final maxProgress = (currentData['maxProgress'] ?? 1).toDouble();
        final isUnlocked = currentData['unlocked'] ?? false;

        if (isUnlocked) continue; // Already unlocked

        final newProgress = (currentProgress + increment).clamp(0.0, maxProgress);
        final shouldUnlock = newProgress >= maxProgress;

        await userAchievementRef.update({
          'progress': newProgress,
          'unlocked': shouldUnlock,
          'unlockDate': shouldUnlock ? FieldValue.serverTimestamp() : null,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // If achievement was just unlocked, award XP
        if (shouldUnlock && !isUnlocked) {
          await _awardXP(userId, achievementData['xpReward']);
          print('🎉 Achievement unlocked: ${achievementData['title']}');
        }
      }
    } catch (e) {
      print('❌ Error updating achievement progress: $e');
    }
  }

  /// Award XP to user
  Future<void> _awardXP(String userId, int xpAmount) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'xp': FieldValue.increment(xpAmount),
        'totalXP': FieldValue.increment(xpAmount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Awarded $xpAmount XP to user');
    } catch (e) {
      print('❌ Error awarding XP: $e');
    }
  }

  /// Get user stats for achievements
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return {};

      final userData = userDoc.data()!;
      return {
        'memories_created': userData['memoriesCreated'] ?? 0,
        'locations_visited': userData['locationsVisited'] ?? 0,
        'users_interacted': userData['usersInteracted'] ?? 0,
        'communities_joined': userData['communitiesJoined'] ?? 0,
        'consecutive_days': userData['consecutiveDays'] ?? 0,
        'night_usage': userData['nightUsage'] ?? 0,
        'media_types_used': userData['mediaTypesUsed'] ?? 0,
        'xp': userData['xp'] ?? 0,
        'totalXP': userData['totalXP'] ?? 0,
        'level': userData['level'] ?? 1,
      };
    } catch (e) {
      print('❌ Error fetching user stats: $e');
      return {};
    }
  }

  /// Check and unlock achievements based on current stats
  Future<void> checkAndUnlockAchievements(String userId) async {
    try {
      final userStats = await getUserStats(userId);
      if (userStats.isEmpty) return;

      // Check each achievement type
      for (final statKey in userStats.keys) {
        if (userStats[statKey] != null && userStats[statKey] > 0) {
          await updateAchievementProgress(
            userId: userId,
            achievementType: statKey,
            increment: userStats[statKey] as int,
          );
        }
      }
    } catch (e) {
      print('❌ Error checking achievements: $e');
    }
  }

  /// Get achievement progress percentage
  double getAchievementProgress(Map<String, dynamic> achievement) {
    final progress = achievement['progress'] ?? 0.0;
    final maxProgress = achievement['maxProgress'] ?? 1.0;
    return maxProgress > 0 ? (progress / maxProgress).clamp(0.0, 1.0) : 0.0;
  }

  /// Get rarity color
  Color getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'uncommon':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Get max progress for requirements
  double _getMaxProgress(Map<String, dynamic> requirements) {
    if (requirements.isEmpty) return 1.0;
    
    double maxProgress = 1.0;
    for (final value in requirements.values) {
      if (value is num && value > maxProgress) {
        maxProgress = value.toDouble();
      }
    }
    return maxProgress;
  }

  /// Get achievement summary
  Future<Map<String, dynamic>> getAchievementSummary(String userId) async {
    try {
      final achievements = await getUserAchievements(userId);
      final totalAchievements = achievements.length;
      final unlockedAchievements = achievements.where((a) => a['unlocked'] == true).length;
              int totalXP = 0;
        for (final achievement in achievements) {
          if (achievement['unlocked'] == true) {
            totalXP += (achievement['xpReward'] ?? 0) as int;
          }
        }

      return {
        'total': totalAchievements,
        'unlocked': unlockedAchievements,
        'locked': totalAchievements - unlockedAchievements,
        'completionPercentage': totalAchievements > 0 ? (unlockedAchievements / totalAchievements) * 100 : 0.0,
        'totalXP': totalXP,
      };
    } catch (e) {
      print('❌ Error getting achievement summary: $e');
      return {
        'total': 0,
        'unlocked': 0,
        'locked': 0,
        'completionPercentage': 0.0,
        'totalXP': 0,
      };
    }
  }
}
