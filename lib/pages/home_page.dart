import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_pap/components/message_post.dart';
import 'package:my_pap/components/validated_text_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  final textController = TextEditingController();

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    if (textController.text.isNotEmpty) {
      // store in firebase
      FirebaseFirestore.instance.collection('UserMessages').add({
        'UserEmail': currentUser!.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
      });
    }

    setState(() {
      textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        actions: [
          //sign out button
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            // messages
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('UserMessages')
                    .orderBy(
                      'TimeStamp',
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

                        return MessagePost(
                          message: message['Message'],
                          user: message['UserEmail'],
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
