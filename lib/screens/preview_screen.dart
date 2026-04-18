import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/issue.dart';
import '../providers/issue_provider.dart';
import '../theme/app_theme.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  final String imagePath;
  final bool isMock;

  const PreviewScreen({
    super.key,
    required this.imagePath,
    this.isMock = false,
  });

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  final TextEditingController _captionController = TextEditingController();
  IssueCategory _selectedCategory = IssueCategory.road;
  final String _reportId = 'REP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

  Future<void> _submit() async {
    final issue = Issue(
      category: _selectedCategory,
      caption: _captionController.text,
      imagePath: widget.imagePath,
      location: '221B Baker Street, London', // Mock location
    );

    final success = await ref.read(submitIssueProvider.notifier).submit(issue);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Issue reported successfully!'),
          backgroundColor: Colors.green.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(submitIssueProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview Card
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: widget.isMock 
                  ? Image.network(widget.imagePath, fit: BoxFit.cover)
                  : Image.file(File(widget.imagePath), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 24),

            // Report ID & Location
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoChip(Icons.tag, _reportId),
                _infoChip(Icons.location_on, 'London, UK'),
              ],
            ),
            const SizedBox(height: 32),

            // Category Selector
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: IssueCategory.values.map((category) {
                final isSelected = _selectedCategory == category;
                return choiceChip(category, isSelected);
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Caption Field
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _captionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the issue...',
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
              ),
            ),
            const SizedBox(height: 100), // Space for sticky button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ElevatedButton(
          onPressed: submissionState.isLoading ? null : _submit,
          child: submissionState.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('SUBMIT REPORT'),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13)),
        ],
      ),
    );
  }

  Widget choiceChip(IssueCategory category, bool isSelected) {
    return FilterChip(
      label: Text(category.label),
      selected: isSelected,
      onSelected: (val) {
        setState(() => _selectedCategory = category);
      },
      backgroundColor: Theme.of(context).cardTheme.color,
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
