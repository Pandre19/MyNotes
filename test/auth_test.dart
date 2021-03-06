import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import "package:test/test.dart";

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();
    test("Should not be initialized to begin with", () {
      expect(provider.isInitialized, false);
    });

    test("Cannot log out if not initialized", () {
      expect(
        provider.logOut(),
        //Esto espera la excepcion como respuesta
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    // test("Should be able to be initialized", () async {
    //   await provider.initialize();
    //   expect(provider.initialize(), true);
    // });
    test(
      "Should be able to initialze in less than 2 seconds",
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      }, //la prueba falla si no cumple el tiempo
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test("User should be null after initialization", () {
      expect(provider.currentUser, null);
    });

    test("Create user should delegate to login function", () async {
      final badEmailUser = provider.createUser(
        email: "foo@bar.com",
        password: "anypassword",
      );
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser = provider.createUser(
        email: "someone@bar.com2",
        password: "foobar",
      );
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

    test("Should be able to log out and log in again", () async {
      await provider.logOut();
      await provider.logIn(email: "email", password: "password");
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

//En el caso de la app, firebase es inicializada con un futurebuilder y
//se pueden usar las otras funciones de firebase sabiendo que la primera ya est??.
//Pero en este caso tenemos que asegurarnos que initialize fue usada primero.
class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == "foo@bar.com") throw UserNotFoundAuthException();
    if (password == "foobar") throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false, email: "foo@bar.com");
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUSer = AuthUser(isEmailVerified: true, email: "foo@bar.com");
    _user = newUSer;
  }
}
