import 'package:flutter/material.dart';
import 'package:around_you/widgets/glassmorphic_container.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  // Mock data for achievements
  final List<Map<String, dynamic>> _achievements = const [
    {'icon': Icons.flag_outlined, 'title': 'First Memory', 'unlocked': true},
    {'icon': Icons.explore_outlined, 'title': 'Explorer', 'unlocked': true},
    {'icon': Icons.group_add_outlined, 'title': 'Social Butterfly', 'unlocked': true},
    {'icon': Icons.location_on_outlined, 'title': 'Trailblazer', 'unlocked': false},
    {'icon': Icons.star_outline, 'title': 'AR Master', 'unlocked': false},
    {'icon': Icons.favorite_border, 'title': 'Heartfelt', 'unlocked': true},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: _achievements.length,
        itemBuilder: (context, index) {
          final achievement = _achievements[index];
          return AchievementCard(
            icon: achievement['icon'],
            title: achievement['title'],
            isUnlocked: achievement['unlocked'],
          );
        },
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isUnlocked;

  const AchievementCard({
    super.key,
    required this.icon,
    required this.title,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassmorphicContainer(
      width: 150,
      height: 150,
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: isUnlocked ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: isUnlocked ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
