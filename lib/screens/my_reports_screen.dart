import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/issue.dart';
import '../providers/issue_provider.dart';
import 'feed_tab.dart';
import '../widgets/connectivity_error_widget.dart';

class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({super.key});

  Future<void> _deleteIssue(BuildContext context, WidgetRef ref, String issueId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report?'),
        content: const Text('This action cannot be undone. Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleting report...'), duration: Duration(seconds: 1)),
      );

      final success = await ref.read(apiServiceProvider).deleteIssue(issueId);

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report deleted successfully')),
        );
        ref.invalidate(userIssuesProvider);
        ref.invalidate(issuesProvider); // Also refresh main feed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete report. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIssuesAsync = ref.watch(userIssuesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(userIssuesProvider.future),
        child: userIssuesAsync.when(
          data: (issues) => issues.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: issues.length,
                  itemBuilder: (context, index) => _buildIssueCard(context, ref, issues[index]),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => ConnectivityErrorWidget(
            isServerDown: true,
            message: 'Unable to reach Jan Report server. Showing saved reports if available.',
            onRetry: () => ref.refresh(userIssuesProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'No reports found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Issues you report will appear here.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCard(BuildContext context, WidgetRef ref, Issue issue) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 4)
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
                  issue.caption.isEmpty ? 'No description' : issue.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  FeedTab.getTimeAgo(issue.timestamp),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
            onPressed: () => _deleteIssue(context, ref, issue.id),
          ),
        ],
      ),
    );
  }

  Widget _imageErrorPlaceholder() {
    return Container(
      color: Colors.grey.withValues(alpha: 0.1),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 20),
      ),
    );
  }
}
