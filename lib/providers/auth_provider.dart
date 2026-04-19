import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final Map<String, dynamic>? user;
  final String? error;

  AuthState({
    this.status = AuthStatus.loading,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    Map<String, dynamic>? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      final user = await _authService.getUser();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final data = await _authService.signInWithGoogle();
      if (data != null) {
        if (data['user'] != null) {
          await _authService.saveUser(data['user']);
        }
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: data['user'],
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final data = await _authService.signIn(email, password);
      if (data?['user'] != null) {
        await _authService.saveUser(data!['user']);
      }
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: data?['user'],
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final data = await _authService.signUp(name, email, password);
      if (data?['user'] != null) {
        await _authService.saveUser(data!['user']);
      }
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: data?['user'],
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }
}

final authServiceProvider = Provider((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
