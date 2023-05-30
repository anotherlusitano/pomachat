import 'package:flutter/material.dart';

class PrivateConversationPage extends StatefulWidget {
  final String? friendId;

  const PrivateConversationPage({
    super.key,
    this.friendId,
  });

  @override
  State<PrivateConversationPage> createState() => _PrivateConversationPageState();
}

class _PrivateConversationPageState extends State<PrivateConversationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello ${widget.friendId}'),
      ),
    );
  }
}
