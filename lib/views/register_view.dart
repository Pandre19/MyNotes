import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import "dart:developer" as devtools show log;

import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

import '../services/auth/auth_exceptions.dart';
import '../services/auth/auth_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text("Register")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
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
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final email = _email.text;
                    final password = _password.text;
                    try {
                      await AuthService.firebase()
                          .createUser(email: email, password: password);
                      await AuthService.firebase().sendEmailVerification();
                      //devtools.log(userCredential.toString());
                      Navigator.of(context).pushNamed(verifyEmailRoute);
                    } on WeakPasswordAuthException {
                      devtools.log("weak password");
                      showErrorDialog(
                        context,
                        "Weak Password",
                      );
                    } on EmailAlreadyInUseException {
                      devtools.log("email already in use");
                      showErrorDialog(
                        context,
                        "Email already in use",
                      );
                    } on InvalidEmailAuthException {
                      devtools.log("invalid email");
                      showErrorDialog(
                        context,
                        "Invalid Email",
                      );
                    } on GenericAuthException {
                      showErrorDialog(context, "Failed to register");
                    }
                  }
                },
                child: const Text("Register"),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                        text: 'Already Registered? ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        )),
                    TextSpan(
                        text: 'Login Here',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blueAccent,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                loginRoute, (route) => false);
                          }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
