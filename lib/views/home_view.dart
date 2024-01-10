import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:my_motes/services/auth/auth_service.dart';
import 'package:my_motes/services/auth/bloc/auth_bloc.dart';
import 'package:my_motes/services/auth/bloc/auth_event.dart';
import 'package:my_motes/services/auth/bloc/auth_state.dart';
import 'package:my_motes/views/notes/notes_view.dart';
import 'package:my_motes/views/verify_email_view.dart';
import 'package:my_motes/views/login_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLogOut) {
          return const LoginView();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
    // return FutureBuilder(
    //   future: AuthService.firebase().initialize(),
    //   builder: (context, snapshot) {
    //     switch (snapshot.connectionState) {
    //       case ConnectionState.done:
    //         final user = AuthService.firebase().currentUser;
    //         if (user != null) {
    //           if (user.isEmailVerified) {
    //             return const NotesView();
    //           } else {
    //             return const VerifyEmailView();
    //           }
    //         } else {
    //           return const LoginView();
    //         }
    //       default:
    //         return const CircularProgressIndicator();
    //     }
    //   },
    // );
  }
}
