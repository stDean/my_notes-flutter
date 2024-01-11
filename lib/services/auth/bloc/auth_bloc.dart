import 'package:bloc/bloc.dart';
import 'package:my_motes/services/auth/auth_provider.dart';
import 'package:my_motes/services/auth/bloc/auth_event.dart';
import 'package:my_motes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProviders provider) : super(const AuthStateUninitialized()) {
    // send email verification
    on<AuthEventSendVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventRegister>((event, emit) async {
      try {
        final email = event.email;
        final password = event.password;

        await provider.createUser(
          email: email,
          password: password,
        );

        await provider.sendEmailVerification();
        emit(const AuthStateNeedVerification());
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e));
      }
    });

    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();

      final user = provider.currentUser;
      if (user == null) {
        emit(
          const AuthStateLogOut(
            exception: null,
            isLoading: false,
          ),
        );
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedVerification());
      } else {
        emit(AuthStateLoggedIn(user: user));
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLogOut(
          exception: null,
          isLoading: true,
        ),
      );
      
      try {
        final email = event.email;
        final password = event.password;

        final user = await provider.logIn(
          email: email,
          password: password,
        );
        if (!user.isEmailVerified) {
          emit(
            const AuthStateLogOut(
              exception: null,
              isLoading: false,
            ),
          );
          emit(const AuthStateNeedVerification());
        } else {
          emit(
            const AuthStateLogOut(
              exception: null,
              isLoading: false,
            ),
          );
          emit(AuthStateLoggedIn(user: user));
        }
      } on Exception catch (e) {
        emit(
          AuthStateLogOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(
          const AuthStateLogOut(
            exception: null,
            isLoading: false,
          ),
        );
      } on Exception catch (e) {
        emit(
          AuthStateLogOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });
  }
}
