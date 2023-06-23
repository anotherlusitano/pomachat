import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_pap/components/file_post.dart';
import 'package:my_pap/components/image_post.dart';
import 'package:my_pap/components/message_post.dart';
import 'package:my_pap/components/profile_picture.dart';
import 'package:my_pap/components/validated_text_field.dart';
import 'package:my_pap/providers/get_group_id.dart';
import 'package:provider/provider.dart';

class GroupConversationPage extends StatefulWidget {
  const GroupConversationPage({
    super.key,
  });

  @override
  State<GroupConversationPage> createState() => _GroupConversationPageState();
}

class _GroupConversationPageState extends State<GroupConversationPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  final textController = TextEditingController();

  String? groupId;

  Map<String, dynamic>? groupData = {};

  late String profilePicture;

  late Reference ref;

  void postMessage() {
    if (textController.text.trim().isNotEmpty) {
      // store in firebase
      FirebaseFirestore.instance.collection('Groups').doc(groupId).collection('Messages').add({
        'user': currentUser!.uid,
        'message': textController.text,
        'timeStamp': Timestamp.now(),
      });
    }

    setState(() {
      textController.clear();
    });
  }

  Future<void> getGroupName() async {
    final documentSnapshot = await FirebaseFirestore.instance.collection('Groups').doc(groupId).get();
    setState(() {
      groupData = documentSnapshot.data();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    groupId = Provider.of<GetGroupId>(context).groupId;
    getGroupName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => print("lol"),
          child: Row(
            children: [
              ProfilePicture(profilePictureUrl: groupData?['icon_group'] ?? '', size: 34),
              const SizedBox(width: 15),
              Text(groupData?['name'] ?? 'Grupo'),
            ],
          ),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Column(
          children: [
            // messages
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Groups')
                    .doc(groupId)
                    .collection('Messages')
                    .orderBy(
                      'timeStamp',
                      descending: true,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      addAutomaticKeepAlives: false,
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // get the message
                        final message = snapshot.data!.docs[index];

                        final date = DateTime.fromMillisecondsSinceEpoch(message['timeStamp'].seconds * 1000);
                        final formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(date);

                        if (message['message']
                            .contains("https://firebasestorage.googleapis.com/v0/b/pap-gpsi.appspot.com/o/")) {
                          Uri uri = Uri.parse(message['message']);
                          String path = uri.path;

                          // Get the filename from the path
                          String fileName = path.substring(path.lastIndexOf('/') + 1);

                          // Get the extension of the file
                          String extension = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();

                          List<String> imageFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'wbmp'];

                          if (imageFormats.contains(extension)) {
                            return ImagePost(
                              imageUrl: message['message'],
                              user: message['user'],
                              timestamp: formattedDate,
                              currentUser: currentUser!.uid,
                              deleteMessage: () {
                                FirebaseFirestore.instance
                                    .collection('Groups')
                                    .doc(groupId)
                                    .collection('Messages')
                                    .doc(message.id)
                                    .delete()
                                    .then(
                                      (value) => print('Image deletada com sucesso'),
                                      onError: (e) => print("Erro ao deletar imagem $e"),
                                    )
                                    .then((value) => ref.delete());
                              },
                            );
                          } else {
                            return FilePost(
                              fileUrl: message['message'],
                              user: message['user'],
                              timestamp: formattedDate,
                              currentUser: currentUser!.uid,
                              deleteMessage: () {
                                FirebaseFirestore.instance
                                    .collection('Groups')
                                    .doc(groupId)
                                    .collection('Messages')
                                    .doc(message.id)
                                    .delete()
                                    .then(
                                      (value) => print('Image deletada com sucesso'),
                                      onError: (e) => print("Erro ao deletar imagem $e"),
                                    )
                                    .then((value) => ref.delete());
                              },
                            );
                          }
                        }

                        return MessagePost(
                          message: message['message'],
                          user: message['user'],
                          timestamp: formattedDate,
                          currentUser: currentUser!.uid,
                          deleteMessage: () {
                            FirebaseFirestore.instance
                                .collection('Groups')
                                .doc(groupId)
                                .collection('Messages')
                                .doc(message.id)
                                .delete()
                                .then(
                                  (value) => print('Mensagem deletada com sucesso'),
                                  onError: (e) => print("Erro ao deletar mensagem $e"),
                                );
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),

            // post mesages
            Padding(
              padding: const EdgeInsets.all(25),
              child: Row(
                children: [
                  Expanded(
                    child: ValidatedTextFormField(
                      controller: textController,
                      hintText: 'Mensagem',
                      obscureText: false,
                      maxLenght: 4000,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      //Create new instance
                      final ImagePicker picker = ImagePicker();

                      //Call this method to get image from users device
                      final image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        //Store it, we are going to use it later
                        final fileBytes = await image.readAsBytes();

                        // Create a reference to a file from a Google Cloud Storage URI
                        Reference reference = FirebaseStorage.instance
                            .ref()
                            .child("${DateTime.now().microsecondsSinceEpoch}${image.name}");

                        // save the reference to use them to delete from the storage
                        setState(() {
                          ref = reference;
                        });

                        // Waits till the file is uploaded then stores the download url
                        final snapshot = await reference.putData(fileBytes);
                        String downloadUrl = await snapshot.ref.getDownloadURL();

                        //Upload to Firebase
                        FirebaseFirestore.instance.collection('Groups').doc(groupId).collection('Messages').add({
                          'user': currentUser!.uid,
                          'message': downloadUrl,
                          'timeStamp': Timestamp.now(),
                        });
                      } else {
                        print('No Image Path Received');
                      }
                    },
                    icon: const Icon(Icons.photo),
                  ),
                  IconButton(
                    onPressed: postMessage,
                    icon: const Icon(Icons.send),
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
