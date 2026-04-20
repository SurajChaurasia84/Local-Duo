import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../models/issue.dart';
import '../providers/issue_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/connectivity_error_widget.dart';
import 'image_preview_screen.dart';

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
        loading: () => ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: 3,
          itemBuilder: (context, index) => const _IssueCardSkeleton(),
        ),
        error: (err, stack) => ConnectivityErrorWidget(
          isServerDown: true,
          message: 'Unable to reach server.',
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
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
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
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Image
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImagePreviewScreen(
                    imagePath: issue.imagePath,
                    heroTag: 'feed_img_${issue.id}',
                  ),
                ),
              );
            },
            child: Hero(
              tag: 'feed_img_${issue.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: SizedBox(
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
                    Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                    const SizedBox(width: 4),
                    Text(
                      issue.location,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12),
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
      color: Colors.grey.withValues(alpha: 0.1),
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

class _IssueCardSkeleton extends StatelessWidget {
  const _IssueCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
      highlightColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Skeleton
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 12, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(width: 60, height: 10, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
          // Image Skeleton
          Container(
            width: double.infinity,
            height: 250,
            color: Colors.white,
          ),
          // Content Skeleton
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: double.infinity, height: 14, color: Colors.white),
                const SizedBox(height: 6),
                Container(width: 200, height: 14, color: Colors.white),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(width: 14, height: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Container(width: 100, height: 10, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
