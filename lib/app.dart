import 'package:flutter/material.dart';
import 'package:my_pap/pages/login_page.dart';
import 'package:my_pap/pages/sign_up_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpPage(),
    );
  }
}
