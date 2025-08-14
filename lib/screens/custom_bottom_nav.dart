import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final Function(int) onItemTapped;

  const CustomBottomNav({super.key, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: theme.colorScheme.surface.withOpacity(0.95),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(context, icon: Icons.map_outlined, label: 'Map', index: 0),
          _buildNavItem(context, icon: Icons.people_outline, label: 'Around', index: 1),
          const SizedBox(width: 40), // The space for the notch
          _buildNavItem(context, icon: Icons.military_tech_outlined, label: 'Badges', index: 2),
          _buildNavItem(context, icon: Icons.person_outline, label: 'Profile', index: 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, required int index}) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(icon, color: theme.colorScheme.primary, size: 28),
      onPressed: () => onItemTapped(index),
      tooltip: label,
    );
  }
}
