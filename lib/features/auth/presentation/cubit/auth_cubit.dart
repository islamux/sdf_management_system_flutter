import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login(String username, String password) async {
    try {
      emit(AuthLoading());
      // TODO: Implement actual authentication logic
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay
      emit(AuthAuthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void logout() {
    emit(AuthInitial());
  }
}
