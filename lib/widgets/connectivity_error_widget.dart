import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConnectivityErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isServerDown;

  const ConnectivityErrorWidget({
    super.key, 
    required this.message, 
    required this.onRetry,
    this.isServerDown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isServerDown ? Colors.orange.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isServerDown ? Icons.dns_outlined : Icons.wifi_off_rounded,
              size: 64,
              color: isServerDown ? Colors.orange : Colors.redAccent,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isServerDown ? 'Server is Resting' : 'No Connection',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), height: 1.5),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('TRY AGAIN', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (isServerDown)
            const Text(
              'Our engineers are already notified.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
        ],
      ),
    ),
  );
 }
}
