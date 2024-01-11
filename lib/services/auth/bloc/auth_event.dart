import 'package:flutter/foundation.dart' show immutable;
import 'package:my_motes/services/auth/auth_user.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

@immutable
class AuthEventInitialize implements AuthEvent {
  const AuthEventInitialize();
}

@immutable
class AuthEventLogIn implements AuthEvent {
  final String email;
  final String password;

  const AuthEventLogIn({
    required this.email,
    required this.password,
  });
}

@immutable
class AuthEventRegister implements AuthEvent {
  final String email;
  final String password;

  const AuthEventRegister({
    required this.email,
    required this.password,
  });
}

@immutable
class AuthEventGoToRegistration implements AuthEvent {
  const AuthEventGoToRegistration();
}

@immutable
class AuthEventGoToLogin implements AuthEvent {
  const AuthEventGoToLogin();
}

@immutable
class AuthEventSendVerification extends AuthEvent {
  const AuthEventSendVerification();
}

@immutable
class AuthEventLogOut implements AuthEvent {
  const AuthEventLogOut();
}
