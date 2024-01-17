import 'package:my_motes/services/auth/auth_user.dart';

// this is the parent provider that encompasses what all providers can do
abstract class AuthProviders {
  AuthUser? get currentUser;

  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> initialize();

  Future<void> logOut();

  Future<void> sendEmailVerification();

  Future<void> sendPasswordReset({required String toEmail});
}
