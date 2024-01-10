import 'package:bloc/bloc.dart';
import 'package:my_motes/services/auth/auth_provider.dart';
import 'package:my_motes/services/auth/bloc/auth_event.dart';
import 'package:my_motes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProviders provider) : super(const AuthStateLoading()) {
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();

      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLogOut());
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedVerification());
      } else {
        emit(AuthStateLoggedIn(user: user));
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoading());

      try {
        final email = event.email;
        final password = event.password;

        final user = await provider.logIn(
          email: email,
          password: password,
        );

        emit(AuthStateLoggedIn(user: user));
      } on Exception catch (e) {
        emit(AuthStateLoginFailed(exception: e));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      emit(const AuthStateLoading());

      try {
        await provider.logOut();
        emit(const AuthStateLogOut());
      } on Exception catch (e) {
        emit(AuthStateLoginFailed(exception: e));
      }
    });
  }
}
