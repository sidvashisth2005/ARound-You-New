import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';

class AnimatedBottomNavigation extends StatefulWidget {
  final Function(int) onItemTapped;
  final int currentIndex;
  final List<BottomNavItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final double elevation;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool enableHapticFeedback;

  const AnimatedBottomNavigation({
    super.key,
    required this.onItemTapped,
    required this.currentIndex,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.elevation = 8.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.enableHapticFeedback = true,
  });

  @override
  State<AnimatedBottomNavigation> createState() => _AnimatedBottomNavigationState();
}

class _AnimatedBottomNavigationState extends State<AnimatedBottomNavigation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final inactiveColor = widget.inactiveColor ?? theme.colorScheme.onSurface.withOpacity(0.6);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.surface.withOpacity(0.95);
    
    return AnimatedContainer(
      duration: widget.animationDuration,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          widget.items.length,
          (index) => _buildNavItem(
            context,
            item: widget.items[index],
            isActive: index == widget.currentIndex,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            index: index,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required BottomNavItem item,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        
        if (widget.currentIndex != index) {
          _animationController.reset();
          _animationController.forward();
          widget.onItemTapped(index);
        }
      },
      child: AnimatedContainer(
        duration: widget.animationDuration,
        curve: widget.animationCurve,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: isActive ? _scaleAnimation.value : 1.0,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? activeColor : inactiveColor.withOpacity(0.3),
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Icon(
                  item.icon,
                  color: isActive ? activeColor : inactiveColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: widget.animationDuration,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 12,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.label,
  });
}