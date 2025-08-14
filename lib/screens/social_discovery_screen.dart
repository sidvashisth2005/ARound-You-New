import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/widgets/glassmorphic_container.dart';

class SocialDiscoveryScreen extends StatelessWidget {
  const SocialDiscoveryScreen({super.key});

  // Mock data for nearby users
  final List<Map<String, String>> _nearbyUsers = const [
    {'name': 'CyberHiker', 'distance': '25m away'},
    {'name': 'ARtist_42', 'distance': '50m away'},
    {'name': 'NeonNomad', 'distance': '80m away'},
    {'name': 'GlitchGardener', 'distance': '95m away'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('People Around You'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement scan logic
              },
              icon: const Icon(Icons.radar),
              label: const Text('SCAN FOR NEARBY USERS'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: theme.colorScheme.secondary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _nearbyUsers.length,
              itemBuilder: (context, index) {
                final user = _nearbyUsers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: GlassmorphicContainer(
                    width: double.infinity,
                    height: 80,
                    child: Center(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary,
                          child: const Icon(Icons.person, color: Colors.black),
                        ),
                        title: Text(user['name']!, style: theme.textTheme.titleLarge),
                        subtitle: Text(user['distance']!, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                        trailing: IconButton(
                          icon: Icon(Icons.person_add_alt_1_outlined, color: theme.colorScheme.secondary),
                          onPressed: () {
                            // TODO: Send friend request logic
                          },
                        ),
                        onTap: () => context.push('/chat/someUserId'), // TODO: Use actual user ID
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
