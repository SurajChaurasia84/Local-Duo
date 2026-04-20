import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'my_reports_screen.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final userName = user?['name'] ?? 'User';
    final userEmail = user?['email'] ?? '';
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
                        color: const Color(0xFF4A00E0).withValues(alpha: 0.3),
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
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                
                _settingsTile(
                  context,
                  Icons.assignment_outlined,
                  'My Reports',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyReportsScreen()),
                  ),
                ),

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
                  Icons.share_outlined,
                  'Share App',
                  () => SharePlus.instance.share(
                    ShareParams(
                      text: 'Hey! Check out Jan Report - An easy way to report community issues. \n\nDownload now: https://play.google.com/store/apps/details?id=com.janreport.community 🚀'
                    ),
                  ),
                ),

                _settingsTile(
                  context,
                  Icons.help_outline_rounded,
                  'Help & Support',
                  () async {
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'support.janreport@gmail.com',
                      queryParameters: {
                        'subject': 'Jan Report - Support Request',
                      },
                    );
                    if (await canLaunchUrl(emailLaunchUri)) {
                      await launchUrl(
                        emailLaunchUri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),

                _settingsTile(
                  context,
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  () async {
                    final Uri url = Uri.parse('https://surajchaurasia84.github.io/Privacy-Policy/janreport.html');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
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
        // Branding Footer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 56),
            child: Column(
              children: [
                Text(
                  'Jan Report',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Made for the people, by the people.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 6),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: Colors.red.withValues(alpha: 0.5)),
                      );
                    }
                    if (snapshot.hasData) {
                      final version = snapshot.data!.version;
                      final buildNumber = snapshot.data!.buildNumber;
                      return Text(
                        'Version $version ($buildNumber)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      );
                    }
                    return Text(
                      'Syncing version...', 
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
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
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
    );
  }
}
