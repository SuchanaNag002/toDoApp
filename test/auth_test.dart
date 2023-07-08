import 'package:app_first/services/auth/auth_exceptions.dart';
import 'package:app_first/services/auth/auth_provider.dart';
import 'package:app_first/services/auth/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();
    test("Should not be initialized to begin with", () {
      expect(provider._isInitialized, false);
    });
    test("Cannot log out if not initialized", () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test("Should be able to be initialized", () async {
      await provider.initialize();
      expect(provider.isInitilialized, true);
    });
    test("User should be null after initialization", () {
      expect(provider.currentUser, null);
    });
    test(
      "Should be able to initialize in less than two seconds",
      () async {
        await provider.initialize();
        expect(provider.isInitilialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test("Create user should delegate to login function", () async {
      final badEmailUser =
          provider.createUser(email: "foo@bar.com", password: "anypassword");
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));
      final badPasswordUser =
          provider.createUser(email: "foo", password: "foobar");
      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));
      final user = await provider.createUser(email: "foo", password: "bar");
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    test("Logged in user should be able to get verified", () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test("should be able to log out and log in again", () async {
      await provider.logOut();
      await provider.logIn(email: "email", password: "password");
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitilialized => _isInitialized;
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitilialized) {
      throw NotInitializedException();
    }
    await Future.delayed(const Duration(seconds: 2));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitilialized) {
      throw NotInitializedException();
    }
    if (email == "foo@bar.com") {
      throw UserNotFoundAuthException();
    }
    if (password == "foobar") {
      throw WrongPasswordAuthException();
    }
    const user = AuthUser(
      id: 'my_id',
      isEmailVerified: false,
      email: 'foo@bar.com',
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitilialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitilialized) {
      throw NotInitializedException();
    }
    final user = _user;
    if (user == null) {
      throw UserNotFoundAuthException();
    }
    const newUser = AuthUser(
      id: 'my_id',
      isEmailVerified: true,
      email: 'foo@bar.com',
    );
    _user = newUser;
  }
}
