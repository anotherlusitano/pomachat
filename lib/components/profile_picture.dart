import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  String profilePictureUrl;
  double size;

  ProfilePicture({
    super.key,
    required this.profilePictureUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return profilePictureUrl.isEmpty
        ? Icon(
            Icons.person,
            size: size,
          )
        : SizedBox(
            width: size,
            height: size,
            child: CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(profilePictureUrl),
            ),
          );
  }
}
