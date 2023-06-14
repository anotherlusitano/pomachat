import 'package:flutter/material.dart';

class GetGroupId extends ChangeNotifier {
  String groupId;
  GetGroupId({
    this.groupId = ' ',
  });

  void updateGroupId(String newGroupId) {
    groupId = newGroupId;
    notifyListeners();
  }
}
