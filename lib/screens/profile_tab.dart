import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../models/issue.dart';
import '../providers/issue_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'privacy_policy_screen.dart';
import 'signup_screen.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIssuesAsync = ref.watch(userIssuesProvider);
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = user?['name'] ?? 'Jan User';
    final userEmail = user?['email'] ?? 'user@janreport.com';
    final avatarUrl = user?['avatar_url'];

    return CustomScrollView(
      slivers: [
        // Profile Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 80, left: 24, right: 24, bottom: 40),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A00E0).withOpacity(0.3),
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: avatarUrl != null
                      ? Image.network(avatarUrl, fit: BoxFit.cover)
                      : Center(
                          child: Text(
                            userName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // User Issues Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'My Reports',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        userIssuesAsync.when(
          data: (issues) => SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildIssueCard(context, issues[index]),
              childCount: issues.length,
            ),
          ),
          loading: () => SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildSkeletonItem(context),
              childCount: 3,
            ),
          ),
          error: (err, stack) => const SliverToBoxAdapter(
            child: Center(child: Text('Error loading issues')),
          ),
        ),

        // Settings Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Theme Selection
                _settingsTile(
                  context,
                  themeMode == ThemeMode.system 
                      ? Icons.brightness_auto 
                      : (themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                  'App Theme',
                  () => _showThemeSelector(context, ref, themeMode),
                  trailing: Text(
                    themeMode == ThemeMode.system ? 'System' : (themeMode == ThemeMode.dark ? 'Dark' : 'Light'),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

                _settingsTile(
                  context,
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                  ),
                ),
                
                _settingsTile(
                  context,
                  Icons.logout,
                  'Logout',
                  () => ref.read(authProvider.notifier).logout(),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
      ],
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose App Theme',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _themeOption(context, ref, 'System Default', Icons.brightness_auto, ThemeMode.system, currentMode),
            _themeOption(context, ref, 'Light Mode', Icons.light_mode, ThemeMode.light, currentMode),
            _themeOption(context, ref, 'Dark Mode', Icons.dark_mode, ThemeMode.dark, currentMode),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(BuildContext context, WidgetRef ref, String title, IconData icon, ThemeMode mode, ThemeMode currentMode) {
    final isSelected = mode == currentMode;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : null),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primaryColor) : null,
      onTap: () {
        ref.read(themeProvider.notifier).setTheme(mode);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildIssueCard(BuildContext context, Issue issue) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 4)
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 60,
              height: 60,
              child: issue.isMock
                  ? Image.network(
                      issue.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _imageErrorPlaceholder(),
                    )
                  : Image.file(
                      File(issue.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _imageErrorPlaceholder(),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.category.label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  issue.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
        ],
      ),
    );
  }

  Widget _buildSkeletonItem(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.black12,
      highlightColor: isDark ? Colors.white24 : Colors.grey.shade200,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, 
    IconData icon, 
    String title, 
    VoidCallback onTap, 
    {bool isDestructive = false, Widget? trailing}
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
    );
  }

  Widget _imageErrorPlaceholder() {
    return Container(
      color: Colors.grey.withOpacity(0.1),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 20),
      ),
    );
  }
}
