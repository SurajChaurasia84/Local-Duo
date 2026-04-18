import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.globalGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                'Data Collection',
                'We collect the images you upload and your approximate location to process public issues. This data is shared only with relevant municipal authorities.',
              ),
              _policySection(
                'Location Privacy',
                'Your location is used only for the purpose of identifying the exact spot of the reported issue. We do not track your movements in the background.',
              ),
              _policySection(
                'Image Usage',
                'Images provided should not contain faces or personal identification. We use these images solely for verifying the reported issue.',
              ),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Last Updated: April 18, 2026',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _policySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.5),
          ),
        ],
      ),
    );
  }
}
