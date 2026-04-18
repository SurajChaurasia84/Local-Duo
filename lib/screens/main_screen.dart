import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import 'map_tab.dart';
import 'feed_tab.dart';
import 'profile_tab.dart';
import 'camera_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 1; // Default to Home (Feed)

  final List<Widget> _tabs = [
    const MapTab(),
    const FeedTab(),
    const ProfileTab(),
  ];

  String _getTitle() {
    switch (_currentIndex) {
      case 0: return 'Map View';
      case 1: return 'Community Feed';
      case 2: return 'Profile';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: _currentIndex != 2 // Hide AppBar on profile as it has its own header logic
        ? AppBar(
            title: Text(_getTitle()),
            backgroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0,
          )
        : null,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: isDark ? Colors.white38 : Colors.black38,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'You',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 1 // Only show on Feed page
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraScreen()),
              ),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.camera_alt, color: Colors.white),
            )
          : null,
    );
  }
}
