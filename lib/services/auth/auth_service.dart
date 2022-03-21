import "package:mynotes/services/auth/auth_user.dart";
import "package:mynotes/services/auth/auth_provider.dart";
import 'package:mynotes/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  //----El service habla con el provider y da la información al UI
  //La cosa sería llenar el constructor con la instancia de firebase_auth_provider
  //para que así las funciones estén llenas
  //la cosa es que AuthService es lo que se conectará con el UI
  final AuthProvider provider;

  const AuthService(this.provider);

  //Esto evita que cada vez que se llame AuthService también se llame a
  //FirebaseAuthProvider
  //Porque con el factory ya se devuelve un AuthService que tiene
  //al provider aplicado
  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

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

  @override
  Future<void> initialize() => provider.initialize();
}
