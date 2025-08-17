import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/theme/theme.dart';
import 'package:around_you/extensions/color_extensions.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  int _selectedCategoryIndex = 0;
  
  // Achievement categories
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'All',
      'icon': Icons.emoji_events_rounded,
      'color': AppTheme.accentGold,
    },
    {
      'name': 'Exploration',
      'icon': Icons.explore_rounded,
      'color': AppTheme.premiumBlue,
    },
    {
      'name': 'Social',
      'icon': Icons.people_rounded,
      'color': AppTheme.secondaryBlue,
    },
    {
      'name': 'Creativity',
      'icon': Icons.brush_rounded,
      'color': AppTheme.accentGold,
    },
    {
      'name': 'Mastery',
      'icon': Icons.star_rounded,
      'color': AppTheme.premiumBlue,
    },
  ];

  // Dynamic achievements data
  final List<Map<String, dynamic>> _achievements = [
    {
      'id': 'ach1',
      'title': 'First Memory',
      'description': 'Create your first memory in the app',
      'icon': Icons.flag_rounded,
      'category': 'Exploration',
      'unlocked': true,
      'progress': 1.0,
      'xpReward': 100,
      'unlockDate': '2024-01-15',
      'rarity': 'Common',
    },
    {
      'id': 'ach2',
      'title': 'Explorer',
      'description': 'Visit 5 different locations',
      'icon': Icons.explore_rounded,
      'category': 'Exploration',
      'unlocked': true,
      'progress': 1.0,
      'xpReward': 250,
      'unlockDate': '2024-01-20',
      'rarity': 'Uncommon',
    },
    {
      'id': 'ach3',
      'title': 'Social Butterfly',
      'description': 'Connect with 10 friends',
      'icon': Icons.people_rounded,
      'category': 'Social',
      'unlocked': true,
      'progress': 1.0,
      'xpReward': 300,
      'unlockDate': '2024-01-25',
      'rarity': 'Rare',
    },
    {
      'id': 'ach4',
      'title': 'Trailblazer',
      'description': 'Create memories in 10 unique locations',
      'icon': Icons.location_on_rounded,
      'category': 'Exploration',
      'unlocked': false,
      'progress': 0.6,
      'xpReward': 500,
      'rarity': 'Epic',
    },
    {
      'id': 'ach5',
      'title': 'AR Master',
      'description': 'Place 20 memories in AR world',
      'icon': Icons.view_in_ar_rounded,
      'category': 'Mastery',
      'unlocked': false,
      'progress': 0.35,
      'xpReward': 750,
      'rarity': 'Legendary',
    },
    {
      'id': 'ach6',
      'title': 'Heartfelt',
      'description': 'Receive 50 likes on your memories',
      'icon': Icons.favorite_rounded,
      'category': 'Social',
      'unlocked': true,
      'progress': 1.0,
      'xpReward': 200,
      'unlockDate': '2024-02-01',
      'rarity': 'Uncommon',
    },
    {
      'id': 'ach7',
      'title': 'Creative Genius',
      'description': 'Create 25 unique memories',
      'icon': Icons.brush_rounded,
      'category': 'Creativity',
      'unlocked': false,
      'progress': 0.8,
      'xpReward': 400,
      'rarity': 'Rare',
    },
    {
      'id': 'ach8',
      'title': 'Community Leader',
      'description': 'Start 5 community discussions',
      'icon': Icons.forum_rounded,
      'category': 'Social',
      'unlocked': false,
      'progress': 0.2,
      'xpReward': 600,
      'rarity': 'Epic',
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
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAchievements {
    if (_selectedCategoryIndex == 0) {
      return _achievements;
    }
    final selectedCategory = _categories[_selectedCategoryIndex]['name'] as String;
    return _achievements.where((achievement) => 
      achievement['category'] == selectedCategory
    ).toList();
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
            'Achievements',
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
              icon: const Icon(Icons.info_outline, color: AppTheme.pureWhite),
              onPressed: _showAchievementsInfo,
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
                // Stats Header
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
                          Row(
                            children: [
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentGold.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        Icons.emoji_events_rounded,
                                        color: AppTheme.accentGold,
                                        size: 32,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Progress',
                                      style: TextStyle(
                                        color: AppTheme.pureWhite,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Keep exploring to unlock more achievements!',
                                      style: TextStyle(
                                        color: AppTheme.pureWhite.withValues(alpha: 0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Unlocked',
                                  _achievements.where((a) => a['unlocked'] as bool).length.toString(),
                                  _achievements.length.toString(),
                                  Icons.lock_open,
                                  AppTheme.accentGold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Total XP',
                                  _achievements
                                      .where((a) => a['unlocked'] as bool)
                                      .fold(0, (sum, a) => sum + (a['xpReward'] as int))
                                      .toString(),
                                  '',
                                  Icons.star,
                                  AppTheme.premiumBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Category Filter
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategoryIndex == index;
                        
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: _buildCategoryChip(category, isSelected, index),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Achievements List
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _filteredAchievements.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredAchievements.length,
                            itemBuilder: (context, index) {
                              final achievement = _filteredAchievements[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildAchievementCard(achievement),
                              );
                            },
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

  Widget _buildStatCard(String label, String value, String total, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (total.isNotEmpty) ...[
            Text(
              '/ $total',
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(Map<String, dynamic> category, bool isSelected, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _selectedCategoryIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? category['color'].withValues(alpha: 0.2)
                : AppTheme.pureWhite.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? category['color']
                  : AppTheme.lightBlue.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category['icon'] as IconData,
                color: isSelected 
                    ? category['color']
                    : AppTheme.pureWhite.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                category['name'] as String,
                style: TextStyle(
                  color: isSelected 
                      ? category['color']
                      : AppTheme.pureWhite.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] as bool;
    final rarity = achievement['rarity'] as String;
    final progress = achievement['progress'] as double;
    
    Color rarityColor;
    switch (rarity) {
      case 'Common':
        rarityColor = AppTheme.pureWhite.withValues(alpha: 0.7);
        break;
      case 'Uncommon':
        rarityColor = AppTheme.secondaryBlue;
        break;
      case 'Rare':
        rarityColor = AppTheme.accentGold;
        break;
      case 'Epic':
        rarityColor = AppTheme.premiumBlue;
        break;
      case 'Legendary':
        rarityColor = AppTheme.accentGold;
        break;
      default:
        rarityColor = AppTheme.pureWhite.withValues(alpha: 0.7);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked 
              ? rarityColor.withValues(alpha: 0.5)
              : AppTheme.lightBlue.withValues(alpha: 0.3),
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
                // Achievement Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isUnlocked 
                        ? rarityColor.withValues(alpha: 0.2)
                        : AppTheme.subtleGray.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUnlocked 
                          ? rarityColor
                          : AppTheme.subtleGray,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    achievement['icon'] as IconData,
                    color: isUnlocked 
                        ? rarityColor
                        : AppTheme.subtleGray,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Achievement Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement['title'] as String,
                              style: TextStyle(
                                color: AppTheme.pureWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isUnlocked)
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.accentGold,
                              size: 24,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement['description'] as String,
                        style: TextStyle(
                          color: AppTheme.pureWhite.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: rarityColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: rarityColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              rarity,
                              style: TextStyle(
                                color: rarityColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${achievement['xpReward']} XP',
                            style: TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress Bar
            if (!isUnlocked) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          color: AppTheme.pureWhite.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          color: AppTheme.pureWhite.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: rarityColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (achievement['unlockDate'] != null) ...[
              Text(
                'Unlocked on ${achievement['unlockDate']}',
                style: TextStyle(
                  color: AppTheme.accentGold.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: AppTheme.pureWhite.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No achievements in this category',
            style: TextStyle(
              color: AppTheme.pureWhite.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different category',
            style: TextStyle(
              color: AppTheme.pureWhite.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementsInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark.withValues(alpha: 0.95),
        title: const Text(
          'About Achievements',
          style: TextStyle(
            color: AppTheme.pureWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Common', 'Easiest to unlock', AppTheme.pureWhite.withValues(alpha: 0.7)),
            _buildInfoRow('Uncommon', 'Moderate difficulty', AppTheme.secondaryBlue),
            _buildInfoRow('Rare', 'Challenging to achieve', AppTheme.accentGold),
            _buildInfoRow('Epic', 'Very difficult', AppTheme.premiumBlue),
            _buildInfoRow('Legendary', 'Extremely rare', AppTheme.accentGold),
            const SizedBox(height: 16),
            Text(
              'Earn XP and unlock achievements by exploring, creating memories, and connecting with others!',
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: TextStyle(
                color: AppTheme.accentGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String rarity, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            rarity,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '- $description',
            style: TextStyle(
              color: AppTheme.pureWhite.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
