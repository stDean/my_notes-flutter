import 'package:flutter/material.dart';
import 'package:my_motes/constants/route.dart';
import 'package:my_motes/services/auth/auth_exceptions.dart';
import 'package:my_motes/services/auth/auth_service.dart';
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
    return Scaffold(
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

              try {
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );

                await AuthService.firebase().sendEmailVerification();

                // this allows you go back to prev page
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(
                  context,
                  'Email Already Exists!',
                );
              } on WeakPasswordAuthException {
                await showErrorDialog(
                  context,
                  'Weak Password!',
                );
              } on InvalidEmailAuthException {
                await showErrorDialog(
                  context,
                  'Email is invalid',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'Registration Failed, Try Again!',
                );
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              // this navigation does not allow you go back to prev page
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text('Have an account, Login here.'),
          ),
        ],
      ),
    );
  }
}
