import 'package:flutter/material.dart';

class MessagePost extends StatelessWidget {
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

  Widget isUserMessage() {
    if (user == currentUser) {
      return IconButton(
        onPressed: deleteMessage,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user,
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          timestamp ?? '',
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
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
