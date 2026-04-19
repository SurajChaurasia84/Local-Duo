import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/issue.dart';
import '../providers/issue_provider.dart';
import '../theme/app_theme.dart';

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(issuesProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(issuesProvider.future),
      child: issuesAsync.when(
        data: (issues) {
          if (issues.isEmpty) {
            return ListView( // ListView is required for RefreshIndicator to work on empty states
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.feed_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(
                        'Nothing to show here',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to report an issue!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: issues.length,
            itemBuilder: (context, index) => _IssueFeedCard(issue: issues[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  static String getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }
}

class _IssueFeedCard extends StatelessWidget {
  final Issue issue;
  const _IssueFeedCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  backgroundImage: issue.userAvatar != null ? NetworkImage(issue.userAvatar!) : null,
                  child: issue.userAvatar == null 
                    ? const Icon(Icons.person, color: AppTheme.primaryColor)
                    : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.userName ?? 'Anonymous User', 
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text(
                      FeedTab.getTimeAgo(issue.timestamp), 
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12)
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    issue.category.label.toUpperCase(),
                    style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Container(
              width: double.infinity,
              child: (issue.isMock || issue.imagePath.startsWith('http'))
                ? Image.network(
                    issue.imagePath,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, error, stackTrace) => _imageErrorPlaceholder(),
                  )
                : Image.file(
                    File(issue.imagePath),
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, error, stackTrace) => _imageErrorPlaceholder(),
                  ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.caption,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                    const SizedBox(width: 4),
                    Text(
                      issue.location,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _actionButton(context, Icons.thumb_up_alt_outlined, '0'),
                const SizedBox(width: 20),
                _actionButton(context, Icons.comment_outlined, '0'),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.share_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // const SizedBox(height: 24),
        ],
      );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
      ],
    );
  }

  Widget _imageErrorPlaceholder() {
    return Container(
      color: Colors.grey.withOpacity(0.1),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
          SizedBox(height: 8),
          Text('Image unavailable', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
