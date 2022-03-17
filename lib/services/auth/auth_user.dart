import "package:firebase_auth/firebase_auth.dart" show User;
import 'package:flutter/foundation.dart';

//this class and their children are gonna be immutable
@immutable
class AuthUser {
  final bool isEmailVerified;

  const AuthUser(this.isEmailVerified);

  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}
