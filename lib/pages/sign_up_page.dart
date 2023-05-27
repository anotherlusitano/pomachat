import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_pap/components/primary_button.dart';
import 'package:my_pap/components/validated_text_field.dart';
import 'package:my_pap/constants/layout.dart';

class SignUpPage extends StatefulWidget {
  final Function()? onTap;
  const SignUpPage({
    super.key,
    required this.onTap,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailTextController = TextEditingController();
  final usernameTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  late final String discriminator = generateDiscriminator().toString();

  String generateDiscriminator() {
    int randomNumber = Random().nextInt(9999 - 1) + 1;
    return randomNumber.toString().padLeft(4, '0');
  }

  // sign user up
  void signUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // make sure passwords match
    if (passwordTextController.text != confirmPasswordTextController.text) {
      // pop loading circle
      Navigator.pop(context);

      // show error to user
      displayErrorMessage('Palavras-passe não são iguais!');
      return;
    }

    try {
      // create user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // after creating the user,
      // will create a new document in cloud firestore called Users
      FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid).set({
        'username': emailTextController.text.split('@')[0],
        'bio': 'Biografia vazia....',
      });

      //pop loading circule
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop loading circle
      Navigator.pop(context);

      // show error to user
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
                    'Vamos criar uma conta!',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 25),
                  ValidatedTextFormField(
                    controller: emailTextController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  ValidatedTextFormField(
                    controller: usernameTextController,
                    hintText: 'Username',
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  ValidatedTextFormField(
                    controller: passwordTextController,
                    hintText: 'Palavra-passe',
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  ValidatedTextFormField(
                    controller: confirmPasswordTextController,
                    hintText: 'Confirmar palavra-passe',
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  PrimaryButton(onTap: signUp, text: 'Registar'),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Já tens uma conta?',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onTap,
                        child: const Text(
                          'Entra nela aqui!',
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
