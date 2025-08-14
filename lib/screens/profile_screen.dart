import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/widgets/glassmorphic_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            GlassmorphicContainer(
              width: double.infinity,
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    // backgroundImage: NetworkImage('...'), // TODO: Use user's avatar
                    backgroundColor: Colors.cyan,
                    child: Icon(Icons.person, size: 50, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Text('UrbanExplorer22', style: theme.textTheme.headlineSmall),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(context, '12', 'Memories'),
                _buildStatColumn(context, '5', 'Friends'),
                _buildStatColumn(context, '3', 'Badges'),
              ],
            ),
            const SizedBox(height: 24),
            // My Memories Section
            Text('My Memories', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            // TODO: Replace with a ListView.builder of user's memories
            _buildMemoryCard(context),
            _buildMemoryCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.headlineMedium),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildMemoryCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.location_pin, color: theme.colorScheme.secondary),
        title: const Text('Memory at Golden Gate Park'),
        subtitle: const Text('A beautiful sunset...'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO: Navigate to memory details screen
          // context.push('/memory-details/someId');
        },
      ),
    );
  }
}
