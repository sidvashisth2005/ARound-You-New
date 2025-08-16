import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Account'),
          _buildSettingsTile(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, 'Notifications'),
          _buildSwitchTile(
            context,
            title: 'Friend Requests',
            value: true,
            onChanged: (val) {},
          ),
          _buildSwitchTile(
            context,
            title: 'Nearby Memory Alerts',
            value: true,
            onChanged: (val) {},
          ),
           const Divider(),
          _buildSectionHeader(context, 'Application'),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => context.push('/help'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.logout,
            title: 'Logout',
            color: theme.colorScheme.error,
            onTap: () {
              // TODO: Implement logout logic
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: color ?? theme.colorScheme.primary),
      title: Text(title, style: TextStyle(color: color)),
      trailing: color == null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(BuildContext context, {required String title, required bool value, required Function(bool) onChanged}) {
    final theme = Theme.of(context);
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: theme.colorScheme.secondary,
      inactiveTrackColor: theme.colorScheme.surface,
    );
  }
}
