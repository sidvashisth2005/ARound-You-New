import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Frequently Asked Questions',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildFaqItem(
            context,
            question: 'How do I place a memory?',
            answer: 'Go to the Home Map and tap the large pink button at the bottom. This will open the AR camera. Find a flat surface, tap to place your 3D object, add your message and media, and hit "Anchor Memory".',
          ),
          _buildFaqItem(
            context,
            question: 'Is my location shared with everyone?',
            answer: 'No. Your exact location is never shared. When using the "Around" feature, other users only see a fuzzy, approximate location to protect your privacy.',
          ),
          _buildFaqItem(
            context,
            question: 'What are Trails?',
            answer: 'Trails are interactive scavenger hunts created by other users. Follow the AR clues to complete the trail and earn special rewards!',
          ),
          const SizedBox(height: 24),
          Text(
            'Contact Us',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
            title: const Text('support@aroundyou.app'),
            onTap: () {
              // TODO: Implement mailto link
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, {required String question, required String answer}) {
    final theme = Theme.of(context);
    return ExpansionTile(
      title: Text(question, style: theme.textTheme.titleLarge),
      iconColor: theme.colorScheme.secondary,
      collapsedIconColor: theme.colorScheme.primary,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            answer,
            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
