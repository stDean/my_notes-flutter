import 'package:my_motes/services/auth/auth_provider.dart';
import 'package:my_motes/services/auth/auth_user.dart';
import 'package:my_motes/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProviders {
  final AuthProviders providers;

  const AuthService({required this.providers});

  factory AuthService.firebase() =>
      AuthService(providers: FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      providers.createUser(
        email: email,
        password: password,
      );

  @override
  AuthUser? get currentUser => providers.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      providers.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> initialize() => providers.initialize();

  @override
  Future<void> logOut() => providers.logOut();

  @override
  Future<void> sendEmailVerification() => providers.sendEmailVerification();

  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      providers.sendPasswordReset(toEmail: toEmail);
}
