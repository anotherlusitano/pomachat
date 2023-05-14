import 'package:flutter/material.dart';
import 'package:my_pap/auth/auth.dart';
import 'package:my_pap/auth/login_or_sign_up.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}
