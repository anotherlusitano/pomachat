import 'package:flutter/material.dart';
import 'package:my_pap/components/profile_picture.dart';

class ProfileListItem extends StatelessWidget {
  final String bio;
  final String username;
  final String pictureUrl;

  const ProfileListItem({
    super.key,
    required this.bio,
    required this.username,
    required this.pictureUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          ProfilePicture(profilePictureUrl: pictureUrl, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 10),
                Text(bio),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
