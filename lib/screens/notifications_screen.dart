import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // Mock data for notifications
  final List<Map<String, dynamic>> _notifications = const [
    {'icon': Icons.person_add_outlined, 'title': 'NeonNomad sent you a friend request.', 'time': '5m ago', 'type': 'request'},
    {'icon': Icons.location_on_outlined, 'title': 'A new memory was placed near you!', 'time': '1h ago', 'type': 'memory'},
    {'icon': Icons.check_circle_outline, 'title': 'ARtist_42 accepted your friend request.', 'time': '3h ago', 'type': 'info'},
    {'icon': Icons.military_tech_outlined, 'title': 'You unlocked the "Explorer" badge!', 'time': '1d ago', 'type': 'info'},
  ];

  IconData _getIconForType(String type) {
    switch (type) {
      case 'request': return Icons.person_add_alt_1_outlined;
      case 'memory': return Icons.location_on_outlined;
      default: return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.separated(
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => Divider(color: theme.primaryColor.withOpacity(0.2)),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.surface,
              child: Icon(_getIconForType(notification['type']), color: theme.colorScheme.secondary),
            ),
            title: Text(notification['title']),
            subtitle: Text(notification['time'], style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
            onTap: () {
              // TODO: Handle notification tap (e.g., navigate to profile or memory)
            },
          );
        },
      ),
    );
  }
}
