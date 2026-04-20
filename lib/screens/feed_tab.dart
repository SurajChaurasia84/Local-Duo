import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/issue.dart';
import '../providers/issue_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/connectivity_error_widget.dart';

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(issuesProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(issuesProvider.future),
      child: issuesAsync.when(
        data: (issues) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return _IssueFeedCard(issue: issue);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ConnectivityErrorWidget(
          isServerDown: true,
          message: 'Unable to reach Jan Report server. Showing saved reports if available.',
          onRetry: () => ref.refresh(issuesProvider),
        ),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), // Reduced top and bottom padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.caption,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 8), // Reduced gap
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
