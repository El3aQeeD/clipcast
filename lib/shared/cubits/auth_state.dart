sealed class AuthState {
  const AuthState();
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.authenticated({required String userId}) =
      AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthAuthenticated extends AuthState {
  final String userId;
  const AuthAuthenticated({required this.userId});
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
