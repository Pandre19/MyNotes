import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import "dart:developer" as devtools show log;
import '../utilities/show_error_dialog.dart';

class VerifyEmailView extends StatefulWidget {
  VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  late final TextEditingController _reemail;
  late final TextEditingController _repassword;
  final _reformKey = GlobalKey<FormState>();

  @override
  void initState() {
    _reemail = TextEditingController();
    _repassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _reemail.dispose();
    _repassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                "We've sent you an email verification.\nPlease open it to verify your account"),
            const SizedBox(height: 10),
            const Text(
              "If you haven't received a verification email yet, press the button below",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await user!.sendEmailVerification();
              },
              child: const Text("Send email verification"),
            ),
            TextButton(
              onPressed: () async {
                // await FirebaseAuth.instance.signOut();
                // Navigator.of(context).pushNamedAndRemoveUntil(
                //   registerRoute,
                //   (route) => false,
                // );
                try {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                } catch (e) {
                  print(e.toString());
                }
              },
              child: const Text("Log In After verification"),
            ),
            TextButton(
              onPressed: () async {
                // await FirebaseAuth.instance.signOut();
                // Navigator.of(context).pushNamedAndRemoveUntil(
                //   registerRoute,
                //   (route) => false,
                // );
                try {
                  bool answerReAuth = await _displayTextInputDialog(context);
                  if (answerReAuth) {
                    AuthCredential credentials = EmailAuthProvider.credential(
                        email: _reemail.text, password: _repassword.text);
                    await FirebaseAuth.instance.currentUser!
                        .reauthenticateWithCredential(credentials);
                    await FirebaseAuth.instance.currentUser!.delete();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      registerRoute,
                      (route) => false,
                    );
                  }
                } catch (e) {
                  print(e.toString());
                }
              },
              child: const Text("Remove Current User"),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Insert Your Credentials first'),
            content: Form(
              key: _reformKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    controller: _reemail,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter some text";
                      }
                      return validateEmail(value);
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
                    controller: _repassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter some text";
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      FlatButton(
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text('CANCEL'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      FlatButton(
                        color: Colors.green,
                        textColor: Colors.white,
                        child: Text('OK'),
                        onPressed: () async {
                          if (_reformKey.currentState!.validate()) {
                            final email = _reemail.text;
                            final password = _repassword.text;
                            try {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                              Navigator.of(context).pop(true);
                            } on FirebaseAuthException catch (e) {
                              if (e.code == "user-not-found") {
                                devtools.log("User not found");
                                showErrorDialog(context, "User not found");
                              } else if (e.code == "wrong-password") {
                                devtools.log("Wrong Password");
                                showErrorDialog(context, "Wrong Password");
                              } else {
                                showErrorDialog(context, "Error: ${e.code}");
                              }
                            } catch (e) {
                              showErrorDialog(context, e.toString());
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
