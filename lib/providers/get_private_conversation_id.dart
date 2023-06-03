import 'package:flutter/material.dart';

class GetPrivateConversationId extends ChangeNotifier {
  String conversationId;
  GetPrivateConversationId({
    this.conversationId = ' ',
  });

  void updateFriendId(String newFriendId) {
    conversationId = newFriendId;
    notifyListeners();
  }
}
