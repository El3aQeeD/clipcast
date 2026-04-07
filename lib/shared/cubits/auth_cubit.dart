import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required SupabaseClient supabaseClient})
      : _client = supabaseClient,
        super(const AuthState.initial()) {
    _listenAuthChanges();
  }

  final SupabaseClient _client;

  void _listenAuthChanges() {
    _client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        emit(AuthState.authenticated(userId: session.user.id));
      } else {
        emit(const AuthState.unauthenticated());
      }
    });
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    emit(const AuthState.unauthenticated());
  }
}
