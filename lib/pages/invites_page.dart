import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footer/footer.dart';
import 'package:my_pap/components/profile_list_item.dart';

class InvitesPage extends StatefulWidget {
  const InvitesPage({super.key});

  @override
  State<InvitesPage> createState() => _InvitesPageState();
}

class _InvitesPageState extends State<InvitesPage> {
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
            'invites': FieldValue.arrayUnion([currentUser!.uid]),
          });
        },
      ).catchError((error) => print('Error: $error'));
    }

    setState(() {
      inviteController.clear();
    });
  }

  acceptInvite(String userId) {
    userCollection.update({
      "friends": FieldValue.arrayUnion([userId])
    });

    userCollection.update({
      "invites": FieldValue.arrayRemove([userId])
    });

    FirebaseFirestore.instance.collection('Users').doc(userId).update({
      "friends": FieldValue.arrayUnion([currentUser!.uid])
    });

    FirebaseFirestore.instance.collection('Users').doc(userId).update({
      "invites": FieldValue.arrayRemove([currentUser!.uid])
    });
  }

  declineInvite(String userId) {
    userCollection.update({
      "invites": FieldValue.arrayRemove([userId])
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
                                            padding: const EdgeInsets.all(40),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () => acceptInvite(userId),
                                                  icon: const Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                    size: 42,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                IconButton(
                                                  onPressed: () => declineInvite(userId),
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.red,
                                                    size: 42,
                                                  ),
                                                ),
                                              ],
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
                  hintText: "Insira o seu amigo, ex: john#9999",
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
                      child: const Text("Enviar pedido de amizade"),
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
