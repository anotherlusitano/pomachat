import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool obscurePwd = true;
  bool obscureConfirmedPwd = true;

  String generateDiscriminator() {
    int randomNumber = Random().nextInt(9999 - 1) + 1;
    return randomNumber.toString().padLeft(4, '0');
  }

  Future<bool> usernameExistWithDiscriminator() async {
    final db = FirebaseFirestore.instance.collection('Users');

    QuerySnapshot snapshot = await db
        .where('username', isEqualTo: usernameTextController.text)
        .where('discriminator', isEqualTo: discriminator)
        .get();

    return snapshot.size > 0 ? true : false;
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

    if (usernameTextController.text.isEmpty) {
      // pop loading circle
      Navigator.pop(context);

      // show error to user
      displayErrorMessage('Insira um Username!');
      return;
    }

    if (await usernameExistWithDiscriminator()) {
      // pop loading circle
      Navigator.pop(context);

      // show error to user
      displayErrorMessage('Esse Username já existe, tente um diferente!');
      return;
    }

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
        'username': usernameTextController.text,
        'discriminator': discriminator,
        'bio': 'Biografia vazia....',
        'profilePicture': '',
        'friends': [],
        'invites': [],
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
        child: SizedBox(
          height: Layout.pixel5Height,
          width: 600,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/pomachat.png',
                    width: 300,
                    height: 300,
                  ),
                  Text(
                    'Vamos criar uma conta!',
                    style: TextStyle(color: Colors.grey[700], fontSize: 34),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ValidatedTextFormField(
                      controller: emailTextController,
                      hintText: 'Email',
                      obscureText: false,
                      maxLenght: 128,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ValidatedTextFormField(
                      controller: usernameTextController,
                      hintText: 'Username',
                      obscureText: false,
                      maxLenght: 32,
                      filters: [
                        FilteringTextInputFormatter.allow(RegExp('[^#]*')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 470,
                          height: 51,
                          child: ValidatedTextFormField(
                            controller: passwordTextController,
                            hintText: 'Palavra-passe',
                            obscureText: obscurePwd,
                            maxLenght: 64,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () => setState(() {
                              obscurePwd = !obscurePwd;
                            }),
                            icon: obscurePwd
                                ? const Icon(Icons.visibility_off_outlined)
                                : const Icon(Icons.visibility_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 470,
                          height: 51,
                          child: ValidatedTextFormField(
                            controller: confirmPasswordTextController,
                            hintText: 'Confirmar palavra-passe',
                            obscureText: obscureConfirmedPwd,
                            maxLenght: 64,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () => setState(() {
                              obscureConfirmedPwd = !obscureConfirmedPwd;
                            }),
                            icon: obscureConfirmedPwd
                                ? const Icon(Icons.visibility_off_outlined)
                                : const Icon(Icons.visibility_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: PrimaryButton(
                      onTap: signUp,
                      text: 'Registar',
                    ),
                  ),
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
