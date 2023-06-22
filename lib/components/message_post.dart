import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_pap/components/profile_picture.dart';

class MessagePost extends StatefulWidget {
  final String message;
  final String user;
  final String currentUser;
  final String? timestamp;
  final VoidCallback? deleteMessage;

  const MessagePost({
    super.key,
    required this.message,
    required this.user,
    required this.currentUser,
    required this.timestamp,
    required this.deleteMessage,
  });

  @override
  State<MessagePost> createState() => _MessagePostState();
}

class _MessagePostState extends State<MessagePost> {
  String username = '';
  String profilePicture = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = await FirebaseFirestore.instance.collection('Users').doc(widget.user).get();
    setState(() {
      username = "${user['username']}#${user['discriminator']}";
      profilePicture = user['profilePicture'] ?? '';
    });
  }

  Widget isUserMessage() {
    if (widget.user == widget.currentUser) {
      return IconButton(
        onPressed: widget.deleteMessage,
        icon: const Icon(
          Icons.delete,
          color: Colors.red,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
        padding: const EdgeInsets.all(25),
        child: Row(
          children: [
            ProfilePicture(profilePictureUrl: profilePicture, size: 60),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.timestamp ?? '',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                          isUserMessage(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(widget.message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
