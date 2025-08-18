import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/services/achievement_service.dart';
import 'package:around_you/services/auth_service.dart';

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
      'color': Colors.amber,
    },
    {
      'name': 'Exploration',
      'icon': Icons.explore_rounded,
      'color': Colors.blue,
    },
    {
      'name': 'Social',
      'icon': Icons.people_rounded,
      'color': Colors.green,
    },
    {
      'name': 'Creativity',
      'icon': Icons.brush_rounded,
      'color': Colors.purple,
    },
    {
      'name': 'Mastery',
      'icon': Icons.star_rounded,
      'color': Colors.orange,
    },
  ];

  final AchievementService _achievementService = AchievementService();
  List<Map<String, dynamic>> _achievements = [];
  
  @override
  void initState() {
    super.initState();
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
    _bindAchievements();
  }

  Future<void> _bindAchievements() async {
    final auth = AuthService();
    final userId = await auth.getUserId();
    if (userId == null) return;
    
    // Initialize achievements if needed
    await _achievementService.initializeUserAchievements(userId);
    
    // Load achievements
    final achievements = await _achievementService.getUserAchievements(userId);
    if (mounted) {
      setState(() => _achievements = achievements);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAchievements {
    if (_selectedCategoryIndex == 0) return _achievements;
    final category = _categories[_selectedCategoryIndex]['name'];
    return _achievements.where((ach) => ach['category'] == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
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
            'Achievements',
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
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () => _showAchievementInfo(context),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Overview
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      'Unlocked',
                      _achievements.where((a) => a['unlocked']).length.toString(),
                      _achievements.length.toString(),
                      Icons.lock_open_rounded,
                      Colors.green,
                    ),
                    _buildStatItem(
                      context,
                      'Total XP',
                      _achievements
                          .where((a) => a['unlocked'])
                          .fold(0, (sum, a) => sum + (a['xpReward'] as int))
                          .toString(),
                      '',
                      Icons.star_rounded,
                      Colors.amber,
                    ),
                    _buildStatItem(
                      context,
                      'Progress',
                      '${((_achievements.where((a) => a['unlocked']).length / _achievements.length) * 100).toInt()}%',
                      '',
                      Icons.trending_up_rounded,
                      theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Category Filter
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategoryIndex == index;
                    
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? category['color'].withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected 
                              ? category['color'].withOpacity(0.5)
                              : Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category['icon'],
                              color: isSelected ? category['color'] : Colors.white.withOpacity(0.7),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category['name'],
                              style: TextStyle(
                                color: isSelected ? category['color'] : Colors.white.withOpacity(0.7),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Achievements Grid
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _filteredAchievements.length,
                itemBuilder: (context, index) {
                  final achievement = _filteredAchievements[index];
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 0.3 + (index * 0.1)),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _slideController,
                      curve: Curves.easeOutCubic,
                    )),
                    child: _buildAchievementCard(context, achievement),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    String total,
    IconData icon,
    Color color,
  ) {
    return Column(
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
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (total.isNotEmpty) ...[
          Text(
            '/ $total',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(BuildContext context, Map<String, dynamic> achievement) {
    final theme = Theme.of(context);
    final isUnlocked = achievement['unlocked'] as bool;
    final progress = _achievementService.getAchievementProgress(achievement);
    final rarity = achievement['rarity'] as String;
    final xpReward = achievement['xpReward'] as int;
    
    return GestureDetector(
      onTap: () => _showAchievementDetails(context, achievement),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Achievement Icon with Progress Ring
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress Ring
                  if (!isUnlocked) ...[
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                  
                  // Icon Container
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: isUnlocked 
                        ? LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          )
                        : null,
                      color: isUnlocked ? null : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isUnlocked 
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      achievement['icon'] ?? '🏆',
                      style: TextStyle(
                        fontSize: 30,
                        color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                  
                  // Unlock Badge
                  if (isUnlocked)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Achievement Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        achievement['title'],
                        style: TextStyle(
                          color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        achievement['description'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // XP Reward
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$xpReward',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Rarity Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRarityColor(rarity).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getRarityColor(rarity).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            rarity,
                            style: TextStyle(
                              color: _getRarityColor(rarity),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
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

  void _showAchievementDetails(BuildContext context, Map<String, dynamic> achievement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildAchievementModal(context, achievement),
    );
  }

  Widget _buildAchievementModal(BuildContext context, Map<String, dynamic> achievement) {
    final theme = Theme.of(context);
    final isUnlocked = achievement['unlocked'] as bool;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Achievement Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: isUnlocked 
                        ? LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          )
                        : null,
                      color: isUnlocked ? null : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: isUnlocked 
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      achievement['icon'],
                      color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.5),
                      size: 50,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    achievement['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    achievement['description'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildModalStat(
                          'XP Reward',
                          '${achievement['xpReward']}',
                          Icons.star,
                          Colors.amber,
                        ),
                      ),
                      Expanded(
                        child: _buildModalStat(
                          'Rarity',
                          achievement['rarity'],
                          Icons.diamond,
                          _getRarityColor(achievement['rarity']),
                        ),
                      ),
                      Expanded(
                        child: _buildModalStat(
                          'Progress',
                          isUnlocked ? '100%' : '${(achievement['progress'] * 100).toInt()}%',
                          Icons.trending_up,
                          theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  
                  if (isUnlocked && achievement['unlockDate'] != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.celebration,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Unlocked on ${achievement['unlockDate']}',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalStat(String label, String value, IconData icon, Color color) {
    return Column(
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
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showAchievementInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Achievements Guide',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Achievements are earned by completing various activities in the app. '
          'Each achievement gives you XP points and helps you level up. '
          'Track your progress and unlock new achievements!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
