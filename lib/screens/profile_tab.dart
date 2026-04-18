import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../models/issue.dart';
import '../providers/issue_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'privacy_policy_screen.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIssuesAsync = ref.watch(userIssuesProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
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
                    child: const Center(
                      child: Text(
                        'JD',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'johndoe@example.com',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ],
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
                  
                  // Theme Toggle
                  _settingsTile(
                    context,
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    'Dark Mode',
                    () => ref.read(themeProvider.notifier).toggleTheme(),
                    trailing: Switch(
                      value: isDark,
                      onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(),
                      activeColor: AppTheme.primaryColor,
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
                    () {}, // UI Only
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildIssueCard(BuildContext context, Issue issue) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              issue.imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
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
}
