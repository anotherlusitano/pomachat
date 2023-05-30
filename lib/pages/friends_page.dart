import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_pap/components/message_post.dart';
import 'package:my_pap/pages/private_conversation_page.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Column(
          children: [
            // messages
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final friendsList = snapshot.data!['friends'] as List<dynamic>;

                    return friendsList.isEmpty
                        ?
                        /* Widget to show when friends list is empty */
                        const Center(
                            child: Text("Não tens amigos :("),
                          )
                        :
                        /* ListView.builder when there are friends */
                        ListView.builder(
                            addAutomaticKeepAlives: false,
                            itemCount: friendsList.length,
                            itemBuilder: (context, index) {
                              final friendId = friendsList[index];
                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('Users').doc(friendId).get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                    final username = snapshot.data!['username'];
                                    final bio = snapshot.data!['bio'];
                                    final discriminator = snapshot.data!['discriminator'];

                                    return GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const PrivateConversationPage()),
                                      ),
                                      child: MessagePost(
                                        message: bio,
                                        user: "$username#$discriminator",
                                      ),
                                    );
                                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('Error fetching user data: ${snapshot.error}');
                                  }

                                  return const SizedBox.shrink();
                                },
                              );
                            },
                          );
                  }
                  return const SizedBox.shrink();
                },
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
