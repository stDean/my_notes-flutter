import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:my_motes/constants/route.dart';
import 'package:my_motes/services/auth/auth_exceptions.dart';
// import 'package:my_motes/services/auth/auth_service.dart';
import 'package:my_motes/services/auth/bloc/auth_bloc.dart';
import 'package:my_motes/services/auth/bloc/auth_event.dart';
import 'package:my_motes/services/auth/bloc/auth_state.dart';
// import 'package:my_motes/utils/dialog/loading/loading_dialog.dart';
import 'package:my_motes/utils/dialog/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLogOut) {
          if (state.exception is InvalidCredentialAuthException) {
            await showErrorDialog(
              context,
              'invalid credentials entered',
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              'Authentication Error!',
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please log in to your account in order to interact or create new notes.',
              ),
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  hintText: 'Enter Email Here...',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _password,
                decoration: const InputDecoration(
                  hintText: 'Enter Password Here...',
                ),
                obscureText: true,
                obscuringCharacter: '#',
                autocorrect: false,
                enableSuggestions: false,
              ),
              /*
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
            
                  try {
                    context.read<AuthBloc>().add(
                          AuthEventLogIn(
                            email: email,
                            password: password,
                          ),
                        );
            
                    /*
                    await AuthService.firebase().logIn(
                      email: email,
                      password: password,
                    );
            
                    final user = AuthService.firebase().currentUser;
                    if (user?.isEmailVerified ?? false) {
                      // email verified
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        notesRoute,
                        (route) => false,
                      );
                    } else {
                      // email not verified
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        verifyEmailRoute,
                        (route) => false,
                      );
                    }
                    */
                  } on InvalidCredentialAuthException {
                    await showErrorDialog(
                      context,
                      'invalid credentials entered',
                    );
                  } on GenericAuthException {
                    await showErrorDialog(
                      context,
                      'Authentication Error!',
                    );
                  }
                },
                child: const Text('Login'),
              ),
              */
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;

                        context.read<AuthBloc>().add(
                              AuthEventLogIn(
                                email: email,
                                password: password,
                              ),
                            );
                      },
                      child: const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(const AuthEventForgotPassword());
                      },
                      child: const Text('Forgot Password?'),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(const AuthEventGoToRegistration());
                      },
                      child: const Text('Not Registered, Register here.'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
