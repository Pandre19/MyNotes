import "package:mynotes/services/auth/auth_user.dart";
import "package:mynotes/services/auth/auth_provider.dart";

class AuthService implements AuthProvider {
  //Esto es una forma alternativa del firebase_auth_provider, solo que se llama a una instancia misma del provider
  final AuthProvider provider;

  const AuthService(this.provider);

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) {
    return provider.createUser(
      email: email,
      password: password,
    );
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    return provider.logIn(email: email, password: password);
  }

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
}
