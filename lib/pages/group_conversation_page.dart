import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pap/components/message_post.dart';
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

  void postMessage() {
    if (textController.text.trim().isNotEmpty) {
      // store in firebase
      FirebaseFirestore.instance.collection('Groups').doc(groupId).collection('Messages').add({
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
    groupId = Provider.of<GetGroupId>(context).groupId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Conversation'),
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

                        return MessagePost(
                          message: message['message'],
                          user: message['user'],
                          timestamp: formattedDate,
                          currentUser: getUsername(),
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