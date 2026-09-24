import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_profile.dart';
import '../../../services/supabase_customer_service.dart';

class AuthState {
  final UserProfile? profile;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => profile != null;

  AuthState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseCustomerService _service = SupabaseCustomerService.instance;

  AuthNotifier() : super(const AuthState()) {
    initSession();
  }

  Future<void> initSession() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = _service.currentUser;
      if (user != null) {
        final profile = await _service.fetchProfile(user.id);
        state = state.copyWith(
          profile: profile ??
              UserProfile(
                id: user.id,
                fullName: user.userMetadata?['full_name'] ?? 'Customer',
                email: user.email ?? '',
                role: 'customer',
              ),
          isLoading: false,
        );
      } else if (_service.isMockMode) {
        // Default customer for instant preview
        state = state.copyWith(
          profile: UserProfile(
            id: '00000000-0000-0000-0000-000000000004',
            fullName: 'Varsha Kolekar',
            email: 'customer1@example.com',
            phone: '+1 (555) 012-7711',
            role: 'customer',
          ),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (_service.isMockMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        state = state.copyWith(
          profile: UserProfile(
            id: '00000000-0000-0000-0000-000000000004',
            fullName: 'Varsha Kolekar',
            email: email,
            phone: '+1 (555) 012-7711',
            role: 'customer',
          ),
          isLoading: false,
        );
        return true;
      }

      final response = await _service.signIn(email: email, password: password);
      if (response?.user != null) {
        final profile = await _service.fetchProfile(response!.user!.id);
        state = state.copyWith(
          profile: profile ??
              UserProfile(
                id: response.user!.id,
                fullName:
                    response.user!.userMetadata?['full_name'] ?? 'Customer',
                email: response.user!.email ?? '',
                role: 'customer',
              ),
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid email address or password.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Login failed. Please verify your credentials and network connection.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (_service.isMockMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        state = state.copyWith(
          profile: UserProfile(
            id: 'user-${DateTime.now().millisecondsSinceEpoch}',
            fullName: fullName,
            email: email,
            phone: phone,
            role: 'customer',
          ),
          isLoading: false,
        );
        return true;
      }

      final response = await _service.signUpCustomer(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      if (response?.user != null) {
        state = state.copyWith(
          profile: UserProfile(
            id: response!.user!.id,
            fullName: fullName,
            email: email,
            phone: phone,
            role: 'customer',
          ),
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Registration failed. Please check input values.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Registration error. Email may already be registered.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _service.signOut();
    state = const AuthState();
  }

  Future<bool> updateProfile(
      {required String fullName, required String phone}) async {
    if (state.profile == null) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (!_service.isMockMode) {
        final updated = await _service.updateProfile(
          userId: state.profile!.id,
          fullName: fullName,
          phone: phone,
        );
        if (updated != null) {
          state = state.copyWith(profile: updated, isLoading: false);
          return true;
        }
      } else {
        state = state.copyWith(
          profile: state.profile!.copyWith(fullName: fullName, phone: phone),
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Failed to update profile.');
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _service.resetPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to send password reset email.');
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
