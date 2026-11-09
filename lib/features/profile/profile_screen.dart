import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final locations = ref.watch(locationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                      child: Text(
                        (auth.name ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.accent, fontSize: 32, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 14, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.name ?? 'User',
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
                      Text(auth.phone ?? '',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.verified_rounded, color: AppColors.info, size: 14),
                          SizedBox(width: 4),
                          Text('Verified Customer',
                              style: TextStyle(color: AppColors.info, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_rounded, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Service locations
          const _SectionHeader('Service Locations'),
          const SizedBox(height: 10),
          ...locations.map((loc) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _LocationTile(location: loc),
              )),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_location_alt_rounded, color: AppColors.accent),
            label: const Text('Add New Location', style: TextStyle(color: AppColors.accent)),
          ),
          const SizedBox(height: 20),

          // Settings
          const _SectionHeader('Preferences'),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            trailing: Switch(
              value: true,
              onChanged: (_) {},
              activeColor: AppColors.accent,
            ),
          ),
          _SettingsTile(
            icon: Icons.sms_outlined,
            label: 'SMS Fallback',
            trailing: Switch(
              value: true,
              onChanged: (_) {},
              activeColor: AppColors.accent,
            ),
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            label: 'Language',
            trailing: DropdownButton<String>(
              value: 'English',
              dropdownColor: AppColors.card,
              underline: const SizedBox.shrink(),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              items: const [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Chichewa', child: Text('Chichewa')),
              ],
              onChanged: (_) {},
            ),
          ),
          const SizedBox(height: 20),

          const _SectionHeader('Account'),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            label: 'Terms of Service',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            label: 'App Version',
            trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ),
          const SizedBox(height: 20),

          // Sign out
          ElevatedButton.icon(
            onPressed: () => _signOut(context, ref),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withOpacity(0.15),
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error, width: 1),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _signOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Sign Out', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700));
  }
}

class _LocationTile extends StatelessWidget {
  final ServiceLocation location;
  const _LocationTile({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              location.label.toLowerCase() == 'home'
                  ? Icons.home_rounded
                  : Icons.storefront_rounded,
              color: AppColors.accent, size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location.label,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                Text(location.address,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textMuted, size: 18),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              trailing ?? const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.textMuted, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
