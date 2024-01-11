import 'package:bloc/bloc.dart';
import 'package:my_motes/services/auth/auth_provider.dart';
import 'package:my_motes/services/auth/bloc/auth_event.dart';
import 'package:my_motes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProviders provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    // forgot password
    on<AuthEventForgotPassword>((event, emit) async {
      emit(
        const AuthStateForgotPassword(
          isLoading: false,
          exception: null,
          hasSentEmail: false,
        ),
      );

      final email = event.email;
      if (email == null) {
        return;
      }
      emit(
        const AuthStateForgotPassword(
          isLoading: true,
          exception: null,
          hasSentEmail: false,
        ),
      );

      bool didSendEmail;
      Exception? exception;
      try {
        await provider.sendPasswordReset(toEmail: email);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }

      emit(
        AuthStateForgotPassword(
          isLoading: false,
          exception: exception,
          hasSentEmail: didSendEmail,
        ),
      );
    });

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
        emit(const AuthStateNeedVerification(isLoading: false));
      } on Exception catch (e) {
        emit(
          AuthStateRegistering(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });

    // handle go to login
    on<AuthEventGoToLogin>((event, emit) async {
      emit(
        const AuthStateLogOut(
          isLoading: false,
          exception: null,
        ),
      );
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
        emit(
          const AuthStateNeedVerification(
            isLoading: false,
          ),
        );
      } else {
        emit(
          AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ),
        );
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLogOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while i log you in',
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
          emit(const AuthStateNeedVerification(isLoading: false));
        } else {
          emit(
            const AuthStateLogOut(
              exception: null,
              isLoading: false,
            ),
          );
          emit(
            AuthStateLoggedIn(
              user: user,
              isLoading: false,
            ),
          );
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

    // handle go to register view
    on<AuthEventGoToRegistration>((event, emit) async {
      emit(
        const AuthStateLogOut(
          isLoading: false,
          exception: null,
        ),
      );
      emit(
        const AuthStateRegistering(
          isLoading: false,
          exception: null,
        ),
      );
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
