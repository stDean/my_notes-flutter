import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_motes/firebase_options.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
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
                        final userCredentials = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        print(userCredentials);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'invalid-credential') {
                          print('invalid credentials entered');
                        } else {
                          print('Something Went Wrong!!');
                          print(e);
                        }
                      }
                    },
                    child: const Text('Login'),
                  ),
                ],
              );
            default:
              return const Text('loading...');
          }
        },
      ),
    );
  }
}
