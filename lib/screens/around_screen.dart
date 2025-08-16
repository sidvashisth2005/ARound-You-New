import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/theme/theme.dart';
import 'package:around_you/extensions/color_extensions.dart';

class AroundScreen extends StatefulWidget {
  const AroundScreen({super.key});

  @override
  State<AroundScreen> createState() => _AroundScreenState();
}

class _AroundScreenState extends State<AroundScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _radarController;
  late Animation<double> _radarAnimation;
  late Animation<double> _pulseAnimation;
  
  // Mock nearby users data
  final List<Map<String, dynamic>> _nearbyUsers = [
    {
      'id': 'user1',
      'name': 'Sarah Chen',
      'avatar': '👩‍💼',
      'distance': 0.2,
      'status': 'online',
      'lastSeen': '2 min ago',
      'interests': ['Photography', 'Coffee', 'Art'],
      'isOnline': true,
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
    _radarController = AnimationController(
      duration: const Duration(seconds: 3),
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
    
    _radarController.repeat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  void _startChat(String userId) {
    // Navigate to chat screen or open chat modal
    context.push('/chat?userId=$userId');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Around You'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
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
                      Icon(Icons.chat_bubble, size: 20),
                      SizedBox(width: 8),
                      Text('Chat'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMapViewTab(context),
                _buildChatTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapViewTab(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        // Map Background (Placeholder)
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.2),
                Colors.black,
                theme.colorScheme.secondary.withOpacity(0.1),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  color: Colors.white.withOpacity(0.3),
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  'Interactive Map',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'See nearby users and memories',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Radar Visualization
        Positioned(
          top: 50,
          left: 50,
          child: AnimatedBuilder(
            animation: _radarAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _radarAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Radar sweep line
                      Positioned(
                        top: 60,
                        left: 60,
                        child: Container(
                          width: 60,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.8),
                                theme.colorScheme.primary.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // User proximity indicators
        ..._nearbyUsers.map((user) {
          final distance = user['distance'] as double;
          final angle = distance * 2 * 3.14159; // Convert distance to angle
          final radius = 100.0 + (distance * 50); // Convert distance to radius
          
          return Positioned(
            top: 110 + (radius * 0.5 * (1 - distance)),
            left: 110 + (radius * 0.5 * distance),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: user['isOnline'] 
                          ? theme.colorScheme.primary 
                          : Colors.grey.withOpacity(0.5),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (user['isOnline'] 
                              ? theme.colorScheme.primary 
                              : Colors.grey).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user['avatar'],
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
        
        // Nearby users list overlay
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              itemCount: _nearbyUsers.take(5).length,
              itemBuilder: (context, index) {
                final user = _nearbyUsers[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: user['isOnline'] 
                              ? theme.colorScheme.primary.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          border: Border.all(
                            color: user['isOnline'] 
                                ? theme.colorScheme.primary
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            user['avatar'],
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${(user['distance'] * 1000).toInt()}m',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatTab(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Online users count
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_nearbyUsers.where((user) => user['isOnline']).length} people nearby',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Recent conversations
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _nearbyUsers.where((user) => user['isOnline']).length,
            itemBuilder: (context, index) {
              final user = _nearbyUsers.where((user) => user['isOnline']).toList()[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _startChat(user['id']),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // User avatar
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user['avatar'],
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // User info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(user['distance'] * 1000).toInt()}m away',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children: (user['interests'] as List).take(2).map((interest) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      interest,
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        
                        // Chat button
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}