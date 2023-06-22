import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:my_pap/components/profile_picture.dart';

class ImagePost extends StatefulWidget {
  final String imageUrl;
  final String user;
  final String currentUser;
  final String? timestamp;
  final VoidCallback? deleteMessage;

  const ImagePost({
    super.key,
    required this.imageUrl,
    required this.user,
    required this.currentUser,
    required this.timestamp,
    required this.deleteMessage,
  });

  @override
  State<ImagePost> createState() => _ImagePostState();
}

class _ImagePostState extends State<ImagePost> {
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Image.network(widget.imageUrl),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                            child: IconButton(
                              onPressed: () async => await WebImageDownloader.downloadImageFromWeb(widget.imageUrl),
                              icon: const Icon(Icons.download),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
