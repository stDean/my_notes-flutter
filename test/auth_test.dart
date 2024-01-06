import 'package:my_motes/services/auth/auth_exceptions.dart';
import 'package:my_motes/services/auth/auth_provider.dart';
import 'package:my_motes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    test('should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('cannot logout if not initialized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedAuthException>()),
      );
    });

    test('should be able to initialize app', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('user should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test(
      'should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('create user should delegate to login', () async {
      final badEmailUser = provider.createUser(
        email: 'foo@bar.com',
        password: 'anypassword',
      );

      expect(
        badEmailUser,
        throwsA(const TypeMatcher<InvalidCredentialAuthException>()),
      );

      final badPasswordUser = provider.createUser(
        email: 'any-email',
        password: 'foobar1',
      );

      expect(
        badPasswordUser,
        throwsA(const TypeMatcher<InvalidCredentialAuthException>()),
      );

      // because registering a new user triggers the login, i expect it to return a user!
      final user = await provider.createUser(
        email: 'foo',
        password: 'bar1',
      );

      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('should be able to logout and log in again', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'user',
        password: 'password',
      );

      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedAuthException implements Exception {}

class UserNotFoundAuthException implements Exception {}

class MockAuthProvider implements AuthProviders {
  var _isInitialize = false;
  bool get isInitialized => _isInitialize;

  AuthUser? _user;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) {
      throw NotInitializedAuthException();
    }

    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialize = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedAuthException();
    if (email == 'foo@bar.com') throw InvalidCredentialAuthException();
    if (password == 'foobar1') throw InvalidCredentialAuthException();
    const user = AuthUser(
      isEmailVerified: false,
      email: 'foo@bar.com',
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedAuthException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedAuthException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();

    const newUser = AuthUser(
      isEmailVerified: true,
      email: 'user',
    );
    _user = newUser;
  }
}
