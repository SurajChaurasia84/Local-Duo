import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/issue.dart';
import '../services/api_service.dart';
import 'package:geolocator/geolocator.dart';

enum IssueFilter { all, recent, nearby, mostLiked }

final issueFilterProvider = StateProvider<IssueFilter>((ref) => IssueFilter.all);

final apiServiceProvider = Provider((ref) => ApiService());

final issuesProvider = FutureProvider<List<Issue>>((ref) async {
  final filter = ref.watch(issueFilterProvider);
  final apiService = ref.watch(apiServiceProvider);

  switch (filter) {
    case IssueFilter.nearby:
      // Get current location
      final position = await Geolocator.getCurrentPosition();
      return apiService.getNearbyIssues(position.latitude, position.longitude);
    case IssueFilter.recent:
    case IssueFilter.mostLiked:
    case IssueFilter.all:
      return apiService.getIssues();
  }
});

final userIssuesProvider = FutureProvider<List<Issue>>((ref) async {
  return ref.watch(apiServiceProvider).getUserIssues();
});

class SubmitIssueNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _apiService;
  final Ref ref;
  
  SubmitIssueNotifier(this._apiService, this.ref) : super(const AsyncValue.data(null));

  Future<bool> submit(Issue issue) async {
    state = const AsyncValue.loading();
    try {
      final success = await _apiService.createIssue(issue);
      if (success) {
        ref.invalidate(issuesProvider); // Refresh the feed
        state = const AsyncValue.data(null);
        return true;
      } else {
        state = AsyncValue.error('Failed to submit issue', StackTrace.current);
        return false;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final submitIssueProvider = StateNotifierProvider<SubmitIssueNotifier, AsyncValue<void>>((ref) {
  return SubmitIssueNotifier(ref.watch(apiServiceProvider), ref);
});
