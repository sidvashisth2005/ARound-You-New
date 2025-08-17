import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/widgets/glassmorphic_container.dart';

import 'dart:ui';
import 'dart:math' as math;
import '../main.dart';
import '../widgets/glassmorphic_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock user data
  final Map<String, dynamic> _userData = {
    'username': 'UrbanExplorer22',
    'fullName': 'Alex Johnson',
    'bio': 'Adventure seeker | Photography enthusiast | Coffee lover',
    'location': 'San Francisco, CA',
    'email': 'alex.johnson@example.com',
    'phone': '+1 (555) 123-4567',
    'joinDate': 'March 2023',
    'memories': 12,
    'friends': 5,
    'badges': 3,
    'level': 4,
    'xp': 1250,
    'nextLevelXp': 2000,
  };
  
  // Mock achievements data
  final List<Map<String, dynamic>> _achievements = [
    {
      'id': 'ach1',
      'name': 'Explorer',
      'description': 'Visited 5 different locations',
      'icon': Icons.explore,
      'isUnlocked': true,
      'progress': 1.0,
    },
    {
      'id': 'ach2',
      'name': 'Photographer',
      'description': 'Captured 10 memories',
      'icon': Icons.camera_alt,
      'isUnlocked': true,
      'progress': 1.0,
    },
    {
      'id': 'ach3',
      'name': 'Social Butterfly',
      'description': 'Connected with 10 friends',
      'icon': Icons.people,
      'isUnlocked': false,
      'progress': 0.5,
    },
  ];
  
  // Mock memories data
  final List<Map<String, dynamic>> _memories = [
    {
      'id': 'mem1',
      'title': 'Golden Gate Park',
      'description': 'Beautiful sunset at the park',
      'date': 'May 15, 2023',
      'location': 'San Francisco, CA',
      'icon': Icons.park,
    },
    {
      'id': 'mem2',
      'title': 'Ocean Beach',
      'description': 'Waves crashing on the shore',
      'date': 'June 2, 2023',
      'location': 'San Francisco, CA',
      'icon': Icons.beach_access,
    },
    {
      'id': 'mem3',
      'title': 'Downtown Coffee Shop',
      'description': 'Best latte in town',
      'date': 'June 10, 2023',
      'location': 'San Francisco, CA',
      'icon': Icons.coffee,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _showEditProfileModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header with Background
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Background gradient
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.8),
                        theme.colorScheme.secondary.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                
                // Profile info
                Positioned(
                  bottom: -50,
                  child: Column(
                    children: [
                      // Avatar with glow effect
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.colorScheme.primary,
                          child: CircleAvatar(
                            radius: 58,
                            backgroundColor: Colors.black,
                            child: Icon(Icons.person, size: 60, color: Colors.white.withOpacity(0.9)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _userData['username'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userData['location'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 60),
            
            // Bio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                _userData['bio'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats in glassmorphic container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GlassmorphicContainer(
                width: double.infinity,
                height: 100,
                borderRadius: 20,
                blur: 10,
                border: 1.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(context, _userData['memories'].toString(), 'Memories'),
                    _buildDivider(),
                    _buildStatColumn(context, _userData['friends'].toString(), 'Friends'),
                    _buildDivider(),
                    _buildStatColumn(context, _userData['badges'].toString(), 'Badges'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Level progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Level ${_userData['level']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_userData['xp']}/${_userData['nextLevelXp']} XP',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _userData['xp'] / _userData['nextLevelXp'],
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GlassmorphicContainer(
                width: double.infinity,
                height: 50,
                borderRadius: 25,
                blur: 10,
                border: 1.5,
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.5),
                  tabs: const [
                    Tab(text: 'MEMORIES'),
                    Tab(text: 'ACHIEVEMENTS'),
                    Tab(text: 'INFO'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tab content
            SizedBox(
              height: 406, // Increased height to fix overflow
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Memories Tab
                  _buildMemoriesTab(context),
                  
                  // Achievements Tab
                  _buildAchievementsTab(context),
                  
                  // Info Tab
                  _buildInfoTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }
  
  Widget _buildMemoriesTab(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 22.0), // Added bottom padding to fix overflow
      itemCount: _memories.length,
      itemBuilder: (context, index) {
        final memory = _memories[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 100,
            borderRadius: 16,
            blur: 10,
            border: 1.5,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/memory-details/${memory['id']}'),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Memory icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            memory['icon'],
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Memory details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              memory['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              memory['description'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              memory['date'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Arrow icon
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAchievementsTab(BuildContext context) {
    final theme = Theme.of(context);
    
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.5), // Added bottom padding to fix overflow
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        return GestureDetector(
          onTap: () => _showAchievementDetails(achievement),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 16,
            blur: 10,
            border: 1.5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Achievement icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: achievement['isUnlocked']
                          ? theme.colorScheme.primary.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: achievement['isUnlocked']
                            ? theme.colorScheme.primary
                            : Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: achievement['isUnlocked']
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Icon(
                        achievement['icon'],
                        color: achievement['isUnlocked']
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Achievement name
                  Text(
                    achievement['name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: achievement['isUnlocked']
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Achievement description
                  Text(
                    achievement['description'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: achievement['progress'],
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        achievement['isUnlocked']
                            ? theme.colorScheme.primary
                            : Colors.white.withOpacity(0.5),
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(achievement['progress'] * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      if (achievement['isUnlocked']) ...[  
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'UNLOCKED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInfoTab(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 27.0), // Added bottom padding to fix overflow
      children: [
        _buildInfoItem(context, 'Full Name', 'John Doe', Icons.person),
        _buildInfoItem(context, 'Email', 'john.doe@example.com', Icons.email),
        _buildInfoItem(context, 'Phone', '+1 (555) 123-4567', Icons.phone),
        _buildInfoItem(context, 'Location', 'San Francisco, CA', Icons.location_on),
        _buildInfoItem(context, 'Joined', 'January 2023', Icons.calendar_today),
        
        const SizedBox(height: 24),
        
        // Account actions
        GlassmorphicContainer(
          width: double.infinity,
          height: 180,
          borderRadius: 16,
          blur: 10,
          border: 1.5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Actions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButton('Privacy Settings', Icons.privacy_tip, () {}),
                _buildActionButton('Notification Preferences', Icons.notifications, () {}),
                _buildActionButton('Log Out', Icons.logout, () {}),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 70,
        borderRadius: 16,
        blur: 10,
        border: 1.5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showAchievementDetails(Map<String, dynamic> achievement) {
    // Use the current build context
    final currentContext = navigatorKey.currentContext;
    if (currentContext == null) return;
    
    final theme = Theme.of(currentContext);
    
    showModalBottomSheet(
      context: currentContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Achievement icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: achievement['isUnlocked']
                              ? theme.colorScheme.primary.withOpacity(0.3)
                              : Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: achievement['isUnlocked']
                                ? theme.colorScheme.primary
                                : Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                          boxShadow: achievement['isUnlocked']
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ]
                              : [],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              achievement['icon'],
                              color: achievement['isUnlocked']
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              size: 50,
                            ),
                            if (!achievement['isUnlocked'])
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.lock,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Achievement title and status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            achievement['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: achievement['isUnlocked']
                                  ? theme.colorScheme.primary.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              achievement['isUnlocked'] ? 'UNLOCKED' : 'LOCKED',
                              style: TextStyle(
                                color: achievement['isUnlocked']
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Achievement description
                      Text(
                        achievement['description'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Progress
                      Text(
                        'Progress: ${(achievement['progress'] * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: achievement['progress'],
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                            ).colors[0],
                          ),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Reward
                      if (achievement['isUnlocked'])
                        Column(
                          children: [
                            Text(
                              'Reward',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '+100 XP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      
                      const Spacer(),
                      
                      // Close button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showEditProfileModal(BuildContext context) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Form fields
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Profile picture
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: theme.colorScheme.primary,
                            child: CircleAvatar(
                              radius: 58,
                              backgroundColor: Colors.black,
                              child: Icon(Icons.person, size: 60, color: Colors.white.withOpacity(0.9)),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Form fields
                    _buildEditField('Username', 'JohnDoe', Icons.person),
                    _buildEditField('Full Name', 'John Doe', Icons.badge),
                    _buildEditField('Bio', 'Flutter developer and nature enthusiast', Icons.info),
                    _buildEditField('Location', 'San Francisco, CA', Icons.location_on),
                    _buildEditField('Email', 'john.doe@example.com', Icons.email),
                    _buildEditField('Phone', '+1 (555) 123-4567', Icons.phone),
                    
                    const SizedBox(height: 24),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildEditField(String label, String initialValue, IconData icon) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
    
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 70,
          borderRadius: 16,
          blur: 10,
          border: 1.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: initialValue),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: label,
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
