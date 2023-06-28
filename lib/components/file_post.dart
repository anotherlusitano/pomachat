import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_pap/components/profile_picture.dart';
import 'package:url_launcher/url_launcher.dart';

class FilePost extends StatefulWidget {
  final String fileUrl;
  final String user;
  final String currentUser;
  final String? timestamp;
  final VoidCallback? deleteMessage;

  const FilePost({
    super.key,
    required this.fileUrl,
    required this.user,
    required this.currentUser,
    required this.timestamp,
    required this.deleteMessage,
  });

  @override
  State<FilePost> createState() => _FilePostState();
}

class _FilePostState extends State<FilePost> {
  String username = '';
  String profilePicture = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  showWarning() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Apagar ficheiro"),
          content: const SizedBox(
            width: 200,
            height: 80,
            child: Column(
              children: [
                Text("Tens a certeza que queres apagar este ficheiro?"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: widget.deleteMessage,
              child: const Text("Sim"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Não"),
            )
          ],
        );
      },
    );
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
        onPressed: showWarning,
        icon: const Icon(
          Icons.delete,
          color: Colors.red,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  String getNameOfFile(String url) {
    Uri uri = Uri.parse(url);
    String path = uri.path;

    // Get the filename from the path
    return path.substring(path.lastIndexOf('/') + 1);
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
                  Container(
                    height: 90,
                    width: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[400],
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        final Uri url = Uri.parse(widget.fileUrl);
                        if (!await launchUrl(url)) {
                          throw Exception('Could not launch $url');
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 90,
                            child: Icon(
                              Icons.insert_drive_file_rounded,
                              size: 84,
                            ),
                          ),
                          SizedBox(
                            width: 240,
                            child: Text(
                              getNameOfFile(widget.fileUrl),
                              maxLines: 4,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
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
