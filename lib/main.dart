import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_motes/constants/route.dart';
import 'package:my_motes/services/auth/bloc/auth_bloc.dart';
import 'package:my_motes/services/auth/firebase_auth_provider.dart';
import 'package:my_motes/views/home_view.dart';
import 'package:my_motes/views/login_view.dart';
import 'package:my_motes/views/notes/create_update_note_view.dart';
import 'package:my_motes/views/notes/notes_view.dart';
import 'package:my_motes/views/register_view.dart';
import 'package:my_motes/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute: (context) => const CreateAndUpdateNoteView(),
      },
    ),
  );
}
