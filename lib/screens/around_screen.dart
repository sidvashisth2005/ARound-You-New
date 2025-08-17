import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/theme/theme.dart';
import 'package:around_you/extensions/color_extensions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:around_you/services/location_service.dart';

class AroundScreen extends StatefulWidget {
  const AroundScreen({super.key});

  @override
  State<AroundScreen> createState() => _AroundScreenState();
}

class _AroundScreenState extends State<AroundScreen> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _radarController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _radarAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _selectedTabIndex = 0;
  final LocationService _locationService = LocationService();
  List<Map<String, dynamic>> _nearbyUsers = [];
  bool _isLoadingUsers = false;
  
  // Mock nearby users data (fallback)
  final List<Map<String, dynamic>> _fallbackUsers = [
    {
      'id': 'user1',
      'name': 'Sarah Chen',
      'avatar': '👩‍💼',
      'distance': 0.2,
      'status': 'online',
      'lastSeen': '2 min ago',
      'interests': ['Photography', 'Coffee', 'Art'],
      'isOnline': true,
      'location': const LatLng(37.7749, -122.4194),
    },
    {
      'id': 'user2',
      'name': 'Mike Rodriguez',
      'avatar': '👨‍🎨',
      'distance': 0.5,
      'status': 'online',
      'lastSeen': '5 min ago',
      'interests': ['Music', 'Travel', 'Food'],
      'isOnline': true,
      'location': const LatLng(37.7849, -122.4094),
    },
    {
      'id': 'user3',
      'name': 'Emma Thompson',
      'avatar': '👩‍🎓',
      'distance': 0.8,
      'status': 'away',
      'lastSeen': '15 min ago',
      'interests': ['Reading', 'Yoga', 'Nature'],
      'isOnline': false,
      'location': const LatLng(37.7649, -122.4294),
    },
    {
      'id': 'user4',
      'name': 'Alex Kim',
      'avatar': '👨‍💻',
      'distance': 1.2,
      'status': 'online',
      'lastSeen': '1 min ago',
      'interests': ['Technology', 'Gaming', 'Fitness'],
      'isOnline': true,
      'location': const LatLng(37.7549, -122.4394),
    },
    {
      'id': 'user5',
      'name': 'Lisa Park',
      'avatar': '👩‍🍳',
      'distance': 1.5,
      'status': 'away',
      'lastSeen': '25 min ago',
      'interests': ['Cooking', 'Gardening', 'Pets'],
      'isOnline': false,
      'location': const LatLng(37.7449, -122.4494),
    },
  ];

  // Mock chat messages
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'id': 'msg1',
      'userId': 'user1',
      'userName': 'Sarah Chen',
      'message': 'Hey! I see you\'re also into photography. Want to grab coffee and chat?',
      'timestamp': '2 min ago',
      'isFromMe': false,
    },
    {
      'id': 'msg2',
      'userId': 'me',
      'userName': 'You',
      'message': 'That sounds great! I\'d love to discuss camera techniques.',
      'timestamp': '1 min ago',
      'isFromMe': true,
    },
    {
      'id': 'msg3',
      'userId': 'user2',
      'userName': 'Mike Rodriguez',
      'message': 'Anyone up for exploring the new art gallery downtown?',
      'timestamp': '5 min ago',
      'isFromMe': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNearbyUsers();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _radarController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _radarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _radarController,
      curve: Curves.linear,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _radarController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _radarController.repeat();
    _fadeController.forward();
    _slideController.forward();
    
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _radarController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _startChat(String userId) {
    context.push('/chat?userId=$userId');
  }

  void _viewProfile(String userId) {
    // Navigate to user profile
    context.push('/profile?userId=$userId');
  }

  Future<void> _loadNearbyUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // For now, use mock data
      // In a real app, you'd fetch from your backend
      setState(() {
        _nearbyUsers = _fallbackUsers;
      });
    } catch (e) {
      debugPrint('Error loading nearby users: $e');
      // Fallback to mock data
      setState(() {
        _nearbyUsers = _fallbackUsers;
      });
    } finally {
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.pureWhite),
          onPressed: () => context.go('/home'),
        ),
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: const Text(
            'Around You',
            style: TextStyle(
              color: AppTheme.pureWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.pureWhite),
              onPressed: _loadNearbyUsers,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Radar Header
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.pureWhite.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppTheme.lightBlue.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: AppTheme.premiumShadows,
                      ),
                      child: Column(
                        children: [
                          // Radar Animation
                          AnimatedBuilder(
                            animation: _radarAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _radarAnimation.value * 2 * 3.14159,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.accentGold.withValues(alpha: 0.6),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: AnimatedBuilder(
                                      animation: _pulseAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _pulseAnimation.value,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppTheme.accentGold.withValues(alpha: 0.3),
                                            ),
                                            child: Icon(
                                              Icons.radar,
                                              color: AppTheme.accentGold,
                                              size: 24,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Discovering Nearby Users',
                            style: TextStyle(
                              color: AppTheme.pureWhite,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Find people with similar interests around you',
                            style: TextStyle(
                              color: AppTheme.pureWhite.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Tab Bar
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.lightBlue.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: AppTheme.accentGold,
                      unselectedLabelColor: AppTheme.pureWhite.withValues(alpha: 0.7),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: 'Nearby Users'),
                        Tab(text: 'Recent Chats'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tab Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Nearby Users Tab
                        _buildNearbyUsersTab(),
                        
                        // Recent Chats Tab
                        _buildRecentChatsTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyUsersTab() {
    if (_isLoadingUsers) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
        ),
      );
    }

    if (_nearbyUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppTheme.pureWhite.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No users nearby',
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try moving to a different location',
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _nearbyUsers.length,
      itemBuilder: (context, index) {
        final user = _nearbyUsers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildUserCard(user),
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightBlue.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: AppTheme.subtleShadows,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user['avatar'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user['name'] as String,
                            style: TextStyle(
                              color: AppTheme.pureWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: user['isOnline'] as bool
                                  ? AppTheme.accentGold
                                  : AppTheme.subtleGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user['distance'].toStringAsFixed(1)} km away',
                        style: TextStyle(
                          color: AppTheme.pureWhite.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last seen: ${user['lastSeen']}',
                        style: TextStyle(
                          color: AppTheme.pureWhite.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Interests
            if (user['interests'] != null) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (user['interests'] as List<String>).map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.secondaryBlue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        color: AppTheme.secondaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _startChat(user['id'] as String),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Start Chat'),
                    style: AppTheme.outlineButtonStyle.copyWith(
                      foregroundColor: MaterialStateProperty.all(AppTheme.pureWhite),
                      side: MaterialStateProperty.all(
                        BorderSide(color: AppTheme.pureWhite.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewProfile(user['id'] as String),
                    icon: const Icon(Icons.person_outline),
                    label: const Text('View Profile'),
                    style: AppTheme.secondaryButtonStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentChatsTab() {
    if (_chatMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppTheme.pureWhite.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No recent chats',
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with nearby users',
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _chatMessages.length,
      itemBuilder: (context, index) {
        final message = _chatMessages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildChatMessageCard(message),
        );
      },
    );
  }

  Widget _buildChatMessageCard(Map<String, dynamic> message) {
    final isFromMe = message['isFromMe'] as bool;
    
    return Container(
      decoration: BoxDecoration(
        color: isFromMe
            ? AppTheme.accentGold.withValues(alpha: 0.2)
            : AppTheme.pureWhite.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFromMe
              ? AppTheme.accentGold.withValues(alpha: 0.3)
              : AppTheme.lightBlue.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: AppTheme.subtleShadows,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  message['userName'] as String,
                  style: TextStyle(
                    color: isFromMe ? AppTheme.accentGold : AppTheme.pureWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  message['timestamp'] as String,
                  style: TextStyle(
                    color: AppTheme.pureWhite.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message['message'] as String,
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}