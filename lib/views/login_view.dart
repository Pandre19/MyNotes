import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import "package:firebase_auth/firebase_auth.dart";
import "dart:developer" as devtools show log;

import 'package:mynotes/constants/routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              enableSuggestions: false,
              decoration: const InputDecoration(
                hintText: "Enter your email",
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
              ),
              controller: _email,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter some text";
                }
                return null;
              },
            ),
            TextFormField(
              autocorrect: false,
              enableSuggestions: false,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Enter your password",
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
              ),
              controller: _password,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter some text";
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final email = _email.text;
                  final password = _password.text;
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    // devtools.log(userCredential.toString());
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoute,
                      (route) => false,
                    );
                  } on FirebaseAuthException catch (e) {
                    if (e.code == "user-not-found") {
                      devtools.log("User not found");
                    } else if (e.code == "wrong-password") {
                      devtools.log("Wrong Password");
                    }
                  }
                }
              },
              child: Text("Log In"),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                      text: 'Not registered yet? ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      )),
                  TextSpan(
                    text: 'Register Here',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueAccent,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            registerRoute, (route) => false);
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
