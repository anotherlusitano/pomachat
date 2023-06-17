import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_pap/components/image_post.dart';
import 'package:my_pap/components/message_post.dart';
import 'package:my_pap/components/validated_text_field.dart';
import 'package:my_pap/providers/get_private_conversation_id.dart';
import 'package:provider/provider.dart';

class PrivateConversationPage extends StatefulWidget {
  const PrivateConversationPage({
    super.key,
  });

  @override
  State<PrivateConversationPage> createState() => _PrivateConversationPageState();
}

class _PrivateConversationPageState extends State<PrivateConversationPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  final textController = TextEditingController();

  String? conversationId;

  late Reference ref;

  void postMessage() {
    if (textController.text.trim().isNotEmpty) {
      // store in firebase
      FirebaseFirestore.instance.collection('PrivateConversations').doc(conversationId).collection('Messages').add({
        'user': getUsername(),
        'message': textController.text,
        'timeStamp': Timestamp.now(),
      });
    }

    setState(() {
      textController.clear();
    });
  }

  String getUsername() {
    try {
      FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid).get().then((value) {
        return value['username'];
      });
    } catch (e) {
      print('error');
    }
    return currentUser!.email!.split('@')[0];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    conversationId = Provider.of<GetPrivateConversationId>(context).conversationId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Private Conversation'),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Column(
          children: [
            // messages
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('PrivateConversations')
                    .doc(conversationId)
                    .collection('Messages')
                    .orderBy(
                      'timeStamp',
                      descending: false,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      addAutomaticKeepAlives: false,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // get the message
                        final message = snapshot.data!.docs[index];

                        final date = DateTime.fromMillisecondsSinceEpoch(message['timeStamp'].seconds * 1000);
                        final formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(date);

                        if (message['message']
                            .contains("https://firebasestorage.googleapis.com/v0/b/pap-gpsi.appspot.com/o/")) {
                          return ImagePost(
                            imageUrl: message['message'],
                            user: message['user'],
                            timestamp: formattedDate,
                            currentUser: getUsername(),
                            deleteMessage: () {
                              FirebaseFirestore.instance
                                  .collection('PrivateConversations')
                                  .doc(conversationId)
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

                        return MessagePost(
                          message: message['message'],
                          user: message['user'],
                          timestamp: formattedDate,
                          currentUser: getUsername(),
                          deleteMessage: () {
                            FirebaseFirestore.instance
                                .collection('PrivateConversations')
                                .doc(conversationId)
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
                        FirebaseFirestore.instance
                            .collection('PrivateConversations')
                            .doc(conversationId)
                            .collection('Messages')
                            .add({
                          'user': getUsername(),
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

            //logged in as
            Text(
              "Utilizador atual: ${currentUser!.email}",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
