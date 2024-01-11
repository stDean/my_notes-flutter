import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:my_motes/constants/route.dart';
// import 'package:my_motes/services/auth/auth_service.dart';
import 'package:my_motes/services/auth/auth_exceptions.dart';
import 'package:my_motes/services/auth/bloc/auth_bloc.dart';
import 'package:my_motes/services/auth/bloc/auth_event.dart';
import 'package:my_motes/services/auth/bloc/auth_state.dart';
import 'package:my_motes/utils/dialog/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        if (state is AuthStateRegistering) {
          if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(
              context,
              'Email Already Exists!',
            );
          } else if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(
              context,
              'Weak Password!',
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context,
              'Email is invalid',
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              'Registration Failed, Try Again!',
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Column(
          children: [
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
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;

                context.read<AuthBloc>().add(
                      AuthEventRegister(
                        email: email,
                        password: password,
                      ),
                    );
              },
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () {
                // this navigation does not allow you go back to prev page
                context.read<AuthBloc>().add(const AuthEventGoToLogin());
              },
              child: const Text('Have an account, Login here.'),
            ),
          ],
        ),
      ),
    );
  }
}
