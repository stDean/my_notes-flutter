import 'package:flutter/foundation.dart' show immutable;
import 'package:my_motes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({required this.user});
}

class AuthStateNeedVerification extends AuthState {
  const AuthStateNeedVerification();
}

class AuthStateLogOut extends AuthState {
  final Exception? exception;
  const AuthStateLogOut({required this.exception});
}