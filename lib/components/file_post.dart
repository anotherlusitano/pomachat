import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FilePost extends StatelessWidget {
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
                  Container(
                    height: 90,
                    width: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[400],
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        final Uri url = Uri.parse(fileUrl);
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
                              getNameOfFile(fileUrl),
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
