import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'providers/theme_provider.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error initializing cameras: $e');
  }
  
  runApp(
    const ProviderScope(
      child: PublicIssueApp(),
    ),
  );
}

class PublicIssueApp extends ConsumerWidget {
  const PublicIssueApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Public Issue Reporting',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const MainScreen(),
    );
  }
}
