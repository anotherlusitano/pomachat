import 'package:flutter/material.dart';

class GetFriendId extends ChangeNotifier {
  String friendId;
  GetFriendId({
    this.friendId = '',
  });

  void updateFriendId(String newFriendId) {
    friendId = newFriendId;
    notifyListeners();
  }
}
