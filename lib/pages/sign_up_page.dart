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
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

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
                  PrimaryButton(onTap: () {}, text: 'Registar'),
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
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
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
