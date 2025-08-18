import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/theme/theme.dart';
import 'package:around_you/extensions/color_extensions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:around_you/services/location_service.dart';
import 'package:around_you/services/firebase_service.dart';
import 'dart:async';

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
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _nearbyUsers = [];
  bool _isLoadingUsers = false;
  StreamSubscription? _nearbyUsersSub;
  
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
    _subscribeNearbyUsers();
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
    _nearbyUsersSub?.cancel();
    super.dispose();
  }

  void _startChat(String userId) {
    context.push('/chat?userId=$userId');
  }

  void _viewProfile(String userId) {
    // Navigate to user profile
    context.push('/profile?userId=$userId');
  }

  Future<void> _subscribeNearbyUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      final pos = await _locationService.getCurrentLocation();
      if (pos == null) {
        setState(() => _isLoadingUsers = false);
        return;
      }
      _nearbyUsersSub?.cancel();
      _nearbyUsersSub = _firebaseService
          .getNearbyUsers(pos, 5.0)
          .listen((users) {
        setState(() {
          _nearbyUsers = users;
          _isLoadingUsers = false;
        });
      }, onError: (_) {
        setState(() => _isLoadingUsers = false);
      });
    } catch (_) {
      setState(() => _isLoadingUsers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: const Text(
            'Around You',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.5),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 20),
                          SizedBox(width: 8),
                          Text('Map View'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, size: 20),
                          SizedBox(width: 8),
                          Text('Nearby'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Map View Tab
                _buildMapView(),
                // Nearby Users Tab
                _buildNearbyUsers(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Google Maps Placeholder
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.withOpacity(0.3),
                      Colors.green.withOpacity(0.3),
                      Colors.orange.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Interactive Map',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'See people and memories around you',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Radar Animation
              Positioned(
                top: 20,
                right: 20,
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.radar,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              
              // User Count
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.secondary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people,
                        color: theme.colorScheme.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_nearbyUsers.length} people nearby',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyUsers() {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _fadeAnimation,
                      child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _nearbyUsers.length,
                  itemBuilder: (context, index) {
                    final user = _nearbyUsers[index];
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.3 + (index * 0.1)),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOutCubic,
                      )),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: AppTheme.elegantCardDecoration,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: AppTheme.cardShadows,
                            ),
                            child: Center(
                              child: Text(
                                user['avatar'],
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                user['name'],
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: user['isOnline'] 
                                    ? Colors.green 
                                    : Colors.grey,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${user['distance']} km away • ${user['lastSeen']}',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: (user['interests'] as List<String>)
                                    .take(3)
                                    .map((interest) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withOpacity(0.25),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: theme.colorScheme.primary.withOpacity(0.4),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Text(
                                            interest,
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _viewProfile(user['id']),
                                icon: Icon(
                                  Icons.person_outline,
                                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                                  size: 24,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _startChat(user['id']),
                                icon: Icon(
                                  Icons.chat_bubble_outline,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}