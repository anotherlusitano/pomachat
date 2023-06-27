import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footer/footer.dart';
import 'package:my_pap/components/profile_list_item.dart';

class InviteMembersPage extends StatefulWidget {
  final String? groupId;
  const InviteMembersPage({super.key, required this.groupId});

  @override
  State<InviteMembersPage> createState() => _InviteMembersPageState();
}

class _InviteMembersPageState extends State<InviteMembersPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  late final userCollection = FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid);

  final inviteController = TextEditingController();
  final pattern = RegExp(r'^[a-zA-Z0-9]+#\d{4}$');

  sendInvite() {
    if (pattern.hasMatch(inviteController.text)) {
      String username = inviteController.text.split('#')[0];
      String discriminator = inviteController.text.split('#')[1];

      // store in firebase
      FirebaseFirestore.instance
          .collection('Users')
          .where("username", isEqualTo: username)
          .where("discriminator", isEqualTo: discriminator)
          .get()
          .then(
        (value) {
          FirebaseFirestore.instance.collection('Users').doc(value.docs[0].id).update({
            'members': FieldValue.arrayUnion(['#${widget.groupId}']),
          });
        },
      ).catchError((error) => print('Error: $error'));
    }

    setState(() {
      inviteController.clear();
    });
  }

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
                    final friendsList = snapshot.data!['friends'] as List<dynamic>;

                    return friendsList.isEmpty
                        ? const Center(
                            child: Text("Não tens amigos :("),
                          )
                        : ListView.builder(
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
                                    final pictureUrl = snapshot.data!['profilePicture'];

                                    return Expanded(
                                      child: Stack(
                                        children: [
                                          ProfileListItem(
                                            bio: bio,
                                            username: "$username#$discriminator",
                                            pictureUrl: pictureUrl,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(40, 40, 50, 40),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: IconButton(
                                                onPressed: () => sendInvite(),
                                                icon: const Icon(
                                                  Icons.email,
                                                  color: Colors.blue,
                                                  size: 42,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
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
            Footer(
              child: TextField(
                maxLength: 37,
                controller: inviteController,
                decoration: InputDecoration(
                  hintText: "Insira outro utilizador para convida-lo, ex: john#9999",
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: sendInvite,
                      child: const Text("Enviar convite"),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
