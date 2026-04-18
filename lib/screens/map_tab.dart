import 'package:flutter/material.dart';
import '../models/issue.dart';
import '../theme/app_theme.dart';

class MapTab extends StatelessWidget {
  const MapTab({super.key});

  void _showIssueDetails(BuildContext context, Issue issue) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 450,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Image
            Container(
              height: 200,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(issue.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          issue.category.label,
                          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'Reported 2h ago',
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    issue.caption,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.white.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Text(
                        issue.location,
                        style: TextStyle(color: Colors.white.withOpacity(0.4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Mock Map Background
        Positioned.fill(
          child: Container(
            color: Colors.black12,
            child: Opacity(
              opacity: 0.3,
              child: GridPaper(
                color: Colors.white.withOpacity(0.1),
                divisions: 2,
                subdivisions: 4,
              ),
            ),
          ),
        ),

        // Map UI elements
        const Positioned(
          top: 60,
          left: 20,
          child: MapSearchOverlay(),
        ),

        // Dummy Markers
        MarkerWidget(
          top: 200,
          left: 100,
          icon: Icons.error_outline,
          color: Colors.redAccent,
          onTap: () => _showIssueDetails(context, Issue(
            category: IssueCategory.garbage,
            caption: 'Piles of trash blocking the sidewalk.',
            imagePath: 'https://images.unsplash.com/photo-1542601906990-b4d3fb773b09?w=500',
            location: 'Old Town Square',
          )),
        ),

        MarkerWidget(
          top: 350,
          right: 80,
          icon: Icons.water_drop_outlined,
          color: Colors.blueAccent,
          onTap: () => _showIssueDetails(context, Issue(
            category: IssueCategory.water,
            caption: 'Burst pipe flooding the basement area.',
            imagePath: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500',
            location: 'East Riverside Dr.',
          )),
        ),

        // Cluster Marker Dummy
        Positioned(
          top: 150,
          right: 120,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, spreadRadius: 5)
              ],
            ),
            child: const Text('12', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class MarkerWidget extends StatelessWidget {
  final double? top, bottom, left, right;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const MarkerWidget({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            CustomPaint(
              size: const Size(10, 5),
              painter: TrianglePainter(color: color),
            )
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MapSearchOverlay extends StatelessWidget {
  const MapSearchOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
          const SizedBox(width: 12),
          Text(
            'Search in this area...',
            style: TextStyle(color: Colors.white.withOpacity(0.4)),
          ),
          const Spacer(),
          Icon(Icons.tune, color: Colors.white.withOpacity(0.4)),
        ],
      ),
    );
  }
}
