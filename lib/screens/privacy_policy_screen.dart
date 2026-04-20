import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reporting System Privacy',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _policySection(
              context,
              'Data Collection',
              'We collect the images you upload and your approximate location to process public issues. This data is shared only with relevant municipal authorities.',
            ),
            _policySection(
              context,
              'Location Privacy',
              'Your location is used only for the purpose of identifying the exact spot of the reported issue. We do not track your movements in the background.',
            ),
            _policySection(
              context,
              'Image Usage',
              'Images provided should not contain faces or personal identification. We use these images solely for verifying the reported issue.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Last Updated: April 18, 2026',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), 
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _policySection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w600, 
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), 
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
