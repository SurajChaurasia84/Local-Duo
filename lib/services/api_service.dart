import '../models/issue.dart';

class ApiService {
  // Simulate network delay
  Future<void> _delay() => Future.delayed(const Duration(seconds: 1));

  Future<List<Issue>> getIssues() async {
    await _delay();
    // Return mock general issues
    return [
      Issue(
        category: IssueCategory.garbage,
        caption: 'Large waste buildup near the park entrance.',
        imagePath: 'https://images.unsplash.com/photo-1542601906990-b4d3fb773b09?w=500',
        location: 'Central Park North',
        isMock: true,
      ),
      Issue(
        category: IssueCategory.road,
        caption: 'Significant pothole on the main crossing.',
        imagePath: 'https://images.unsplash.com/photo-1594411124407-332997e3767c?w=500',
        location: 'Broadway Street',
        isMock: true,
      ),
    ];
  }

  Future<List<Issue>> getUserIssues() async {
    await _delay();
    return [
      Issue(
        category: IssueCategory.safety,
        caption: 'Street light broken for three days.',
        imagePath: 'https://images.unsplash.com/photo-1534349762230-e0cadf78f5db?w=500',
        location: 'Oak Avenue',
        isMock: true,
      ),
    ];
  }

  Future<bool> createIssue(Issue issue) async {
    await _delay();
    // In a real app, we would send 'issue' to the backend
    return true;
  }
}
