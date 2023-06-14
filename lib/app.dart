import 'package:flutter/material.dart';
import 'package:my_pap/auth/auth.dart';
import 'package:my_pap/providers/get_friend_id.dart';
import 'package:my_pap/providers/get_private_conversation_id.dart';
import 'package:my_pap/providers/get_group_id.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GetFriendId(),
        ),
        ChangeNotifierProvider(
          create: (context) => GetPrivateConversationId(),
        ),
        ChangeNotifierProvider(
          create: (context) => GetGroupId(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthPage(),
      ),
    );
  }
}
