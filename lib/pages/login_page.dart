import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_pap/components/primary_button.dart';
import 'package:my_pap/components/validated_text_field.dart';
import 'package:my_pap/constants/layout.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  void signIn() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      //pop loading circule
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop loading circule
      Navigator.pop(context);

      //display error message
      displayErrorMessage(e.code);
    }
  }

  void displayErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: Layout.pixel5Height,
          width: Layout.pixel5Width,
          color: Colors.grey[300],
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 100,
                  ),
                  Text(
                    'Bem-vindo de volta!',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 25),
                  ValidatedTextFormField(
                    controller: emailTextController,
                    hintText: 'Email',
                    obscureText: false,
                    maxLenght: 128,
                  ),
                  const SizedBox(height: 25),
                  ValidatedTextFormField(
                    controller: passwordTextController,
                    hintText: 'Palavra-passe',
                    obscureText: true,
                    maxLenght: 64,
                  ),
                  const SizedBox(height: 25),
                  PrimaryButton(
                    onTap: signIn,
                    text: 'Sign In',
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ainda não criaste uma conta?',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onTap,
                        child: const Text(
                          'Cria agora!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
