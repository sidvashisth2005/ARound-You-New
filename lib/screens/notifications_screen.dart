import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:around_you/services/firebase_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'memory':
        return Icons.location_on_outlined;
      case 'friend':
        return Icons.person_add_alt;
      case 'like':
        return Icons.favorite_border;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firebase = FirebaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: firebase.currentUser?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => Divider(color: theme.primaryColor.withValues(alpha: 0.2)),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final type = (data['type'] ?? 'general') as String;
              final title = (data['title'] ?? 'Notification') as String;
              final timeText = '';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.surface,
                  child: Icon(_getIconForType(type), color: theme.colorScheme.secondary),
                ),
                title: Text(title),
                subtitle: Text(timeText, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                onTap: () {
                  final route = data['route'] as String?;
                  if (route != null) {
                    Navigator.of(context).pushNamed(route);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
