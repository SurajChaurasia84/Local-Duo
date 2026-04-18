import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/issue.dart';
import '../providers/issue_provider.dart';
import '../theme/app_theme.dart';

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(issuesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Community Feed',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
      ),
      body: issuesAsync.when(
        data: (issues) => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: issues.length,
          itemBuilder: (context, index) => _IssueFeedCard(issue: issues[index]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _IssueFeedCard extends StatelessWidget {
  final Issue issue;
  const _IssueFeedCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: const Icon(Icons.person, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Anonymous User', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('2 hours ago', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.network(
              issue.imagePath,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
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
                _actionButton(context, Icons.thumb_up_alt_outlined, '24'),
                const SizedBox(width: 20),
                _actionButton(context, Icons.comment_outlined, '5'),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.share_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
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
}
