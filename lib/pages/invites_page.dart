import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_pap/components/message_post.dart';
import 'package:footer/footer.dart';

class InvitesPage extends StatefulWidget {
  const InvitesPage({super.key});

  @override
  State<InvitesPage> createState() => _InvitesPageState();
}

class _InvitesPageState extends State<InvitesPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  late final userCollection = FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid);

  final inviteController = TextEditingController();

  addFriend() {}

  acceptInvite(String userId) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convites'),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Column(
          children: [
            // messages
            Expanded(
              child: StreamBuilder(
                stream: userCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final invitesList = snapshot.data!['invites'] as List<dynamic>;

                    return invitesList.isEmpty
                        ?
                        // Widget to show when invites list is empty
                        const Center(
                            child: Text("Não tens convites :)"),
                          )
                        :
                        // ListView.builder when there are invites
                        ListView.builder(
                            addAutomaticKeepAlives: false,
                            itemCount: invitesList.length,
                            itemBuilder: (context, index) {
                              final userId = invitesList[index];
                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                    final username = snapshot.data!['username'];
                                    final bio = snapshot.data!['bio'];
                                    final discriminator = snapshot.data!['discriminator'];

                                    return GestureDetector(
                                      onTap: () => acceptInvite(userId),
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
          ],
        ),
      ),
    );
  }
}
