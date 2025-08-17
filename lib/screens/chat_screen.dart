import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/theme/theme.dart';
import 'package:around_you/extensions/color_extensions.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _selectedTabIndex = 0;
  
  // Mock chat data
  final List<Map<String, dynamic>> _individualChats = [
    {
      'id': 'chat1',
      'name': 'Sarah Chen',
      'avatar': '👩‍💼',
      'lastMessage': 'Hey! How was your day?',
      'timestamp': '2 min ago',
      'unreadCount': 2,
      'isOnline': true,
      'isTyping': false,
    },
    {
      'id': 'chat2',
      'name': 'Mike Rodriguez',
      'avatar': '👨‍🎨',
      'lastMessage': 'Did you see the new AR feature?',
      'timestamp': '15 min ago',
      'unreadCount': 0,
      'isOnline': true,
      'isTyping': true,
    },
    {
      'id': 'chat3',
      'name': 'Emma Thompson',
      'avatar': '👩‍🎓',
      'lastMessage': 'Thanks for the memory!',
      'timestamp': '1 hour ago',
      'unreadCount': 1,
      'isOnline': false,
      'isTyping': false,
    },
    {
      'id': 'chat4',
      'name': 'Alex Kim',
      'avatar': '👨‍💻',
      'lastMessage': 'Let\'s meet up soon!',
      'timestamp': '2 hours ago',
      'unreadCount': 0,
      'isOnline': false,
      'isTyping': false,
    },
  ];

  final List<Map<String, dynamic>> _communityChats = [
    {
      'id': 'community1',
      'name': 'Photography Enthusiasts',
      'avatar': '📸',
      'lastMessage': 'Check out this amazing sunset!',
      'timestamp': '5 min ago',
      'unreadCount': 5,
      'memberCount': 128,
      'isActive': true,
    },
    {
      'id': 'community2',
      'name': 'Local Foodies',
      'avatar': '🍕',
      'lastMessage': 'New restaurant opening downtown!',
      'timestamp': '30 min ago',
      'unreadCount': 12,
      'memberCount': 89,
      'isActive': true,
    },
    {
      'id': 'community3',
      'name': 'Tech Innovators',
      'avatar': '💻',
      'lastMessage': 'AR development meetup this weekend',
      'timestamp': '2 hours ago',
      'unreadCount': 0,
      'memberCount': 256,
      'isActive': false,
    },
    {
      'id': 'community4',
      'name': 'Nature Explorers',
      'avatar': '🌲',
      'lastMessage': 'Hiking trip this Saturday!',
      'timestamp': '1 day ago',
      'unreadCount': 3,
      'memberCount': 67,
      'isActive': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
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
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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
            'Chats',
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
              icon: const Icon(Icons.search, color: AppTheme.pureWhite),
              onPressed: () => _showSearchDialog(context),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: IconButton(
              icon: const Icon(Icons.add, color: AppTheme.pureWhite),
              onPressed: () => _showNewChatDialog(context),
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
                // Tab Bar
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.pureWhite.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.lightBlue.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTabButton(
                              'Individual',
                              Icons.person,
                              _selectedTabIndex == 0,
                              () => setState(() => _selectedTabIndex = 0),
                            ),
                          ),
                          Expanded(
                            child: _buildTabButton(
                              'Communities',
                              Icons.people,
                              _selectedTabIndex == 1,
                              () => setState(() => _selectedTabIndex = 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Tab Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: IndexedStack(
                      index: _selectedTabIndex,
                      children: [
                        _buildIndividualChatsTab(),
                        _buildCommunityChatsTab(),
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

  Widget _buildTabButton(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.accentGold.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? AppTheme.accentGold
                    : AppTheme.pureWhite.withValues(alpha: 0.7),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? AppTheme.accentGold
                      : AppTheme.pureWhite.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndividualChatsTab() {
    if (_individualChats.isEmpty) {
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
              'No individual chats yet',
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
      itemCount: _individualChats.length,
      itemBuilder: (context, index) {
        final chat = _individualChats[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildIndividualChatCard(chat),
        );
      },
    );
  }

  Widget _buildIndividualChatCard(Map<String, dynamic> chat) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openChat(chat),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar with online status
                Stack(
                  children: [
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
                          chat['avatar'] as String,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    if (chat['isOnline'] as bool)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryDark,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // Chat Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat['name'] as String,
                              style: TextStyle(
                                color: AppTheme.pureWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (chat['unreadCount'] > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                chat['unreadCount'].toString(),
                                style: TextStyle(
                                  color: AppTheme.primaryDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (chat['isTyping'] as bool)
                            Row(
                              children: [
                                Text(
                                  'Typing...',
                                  style: TextStyle(
                                    color: AppTheme.accentGold,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildTypingIndicator(),
                              ],
                            )
                          else
                            Expanded(
                              child: Text(
                                chat['lastMessage'] as String,
                                style: TextStyle(
                                  color: AppTheme.pureWhite.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chat['timestamp'] as String,
                        style: TextStyle(
                          color: AppTheme.pureWhite.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.pureWhite.withValues(alpha: 0.3),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.accentGold,
            shape: BoxShape.circle,
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 600 + (index * 200)),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (0.5 * value),
                child: child,
              );
            },
            child: null,
          ),
        );
      }),
    );
  }

  Widget _buildCommunityChatsTab() {
    if (_communityChats.isEmpty) {
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
              'No community chats yet',
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join communities to start group conversations',
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
      itemCount: _communityChats.length,
      itemBuilder: (context, index) {
        final chat = _communityChats[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCommunityChatCard(chat),
        );
      },
    );
  }

  Widget _buildCommunityChatCard(Map<String, dynamic> chat) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openCommunityChat(chat),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Community Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.secondaryBlue.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      chat['avatar'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Community Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat['name'] as String,
                              style: TextStyle(
                                color: AppTheme.pureWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (chat['unreadCount'] > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                chat['unreadCount'].toString(),
                                style: TextStyle(
                                  color: AppTheme.pureWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chat['lastMessage'] as String,
                        style: TextStyle(
                          color: AppTheme.pureWhite.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${chat['memberCount']} members',
                            style: TextStyle(
                              color: AppTheme.pureWhite.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            chat['timestamp'] as String,
                            style: TextStyle(
                              color: AppTheme.pureWhite.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.pureWhite.withValues(alpha: 0.3),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openChat(Map<String, dynamic> chat) {
    // Navigate to individual chat
    context.push('/chat/${chat['id']}');
  }

  void _openCommunityChat(Map<String, dynamic> chat) {
    // Navigate to community chat
    context.push('/community/${chat['id']}');
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark.withValues(alpha: 0.95),
        title: const Text(
          'Search Chats',
          style: TextStyle(color: AppTheme.pureWhite),
        ),
        content: TextField(
          style: const TextStyle(color: AppTheme.pureWhite),
          decoration: InputDecoration(
            hintText: 'Search by name or message...',
            hintStyle: TextStyle(color: AppTheme.pureWhite.withValues(alpha: 0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.lightBlue.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.lightBlue.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.accentGold),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.pureWhite.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: AppTheme.primaryButtonStyle,
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark.withValues(alpha: 0.95),
        title: const Text(
          'Start New Chat',
          style: TextStyle(color: AppTheme.pureWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person_add, color: AppTheme.accentGold),
              title: const Text(
                'Find Nearby Users',
                style: TextStyle(color: AppTheme.pureWhite),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/around');
              },
            ),
            ListTile(
              leading: Icon(Icons.group_add, color: AppTheme.secondaryBlue),
              title: const Text(
                'Join Communities',
                style: TextStyle(color: AppTheme.pureWhite),
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigate to communities
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.pureWhite.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }
}
