import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:my_motes/constants/route.dart';
// import 'package:my_motes/services/auth/auth_service.dart';
import 'package:my_motes/services/auth/bloc/auth_bloc.dart';
import 'package:my_motes/services/auth/bloc/auth_event.dart';
import 'package:my_motes/services/auth/bloc/auth_state.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateNeedVerification) {}
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify Email'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Column(
          children: [
            const Text(
              'We\'ve sent you an email verification. Please check your email and verify your account',
            ),
            const Text(
              'If you haven\'t received a verification email yet, press the button below!',
            ),
            TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventSendVerification());
              },
              child: const Text('Send Email Verification'),
            ),
            TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              },
              child: const Text('Restart'),
            ),
          ],
        ),
      ),
    );
  }
}
