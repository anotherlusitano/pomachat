import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footer/footer.dart';
import 'package:my_pap/components/call_snackbar.dart';
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
  final pattern = RegExp(r'^[^#]*#\d{4}$');

  sendInvite([String? friendUsername, String? friendDiscriminator]) {
    if (pattern.hasMatch(inviteController.text) || (friendUsername != null && friendDiscriminator != null)) {
      String username = '';
      String discriminator = '';

      if (friendUsername != null && friendDiscriminator != null) {
        username = friendUsername;
        discriminator = friendDiscriminator;
      } else {
        username = inviteController.text.split('#')[0];
        discriminator = inviteController.text.split('#')[1];
      }

      // store in firebase
      FirebaseFirestore.instance
          .collection('Users')
          .where("username", isEqualTo: username)
          .where("discriminator", isEqualTo: discriminator)
          .get()
          .then(
        (value) async {
          final group = await FirebaseFirestore.instance.collection('Groups').doc(widget.groupId).get();
          //verify if user is in the group
          if (group['members'].contains(value.docs[0].id)) {
            return SnackMsg.showInfo(context, 'Este utilizador já está no grupo!');
          }
          // verify if the user has the invite
          else if (value.docs[0]['invites'].contains('#${widget.groupId}')) {
            return SnackMsg.showInfo(context, 'Este utilizador já tem um convite');
          } else {
            //send invite to user
            await FirebaseFirestore.instance.collection('Users').doc(value.docs[0].id).update({
              'invites': FieldValue.arrayUnion(['#${widget.groupId}']),
            });
            return SnackMsg.showOk(context, 'Convite enviado!');
          }
        },
      ).catchError((error) {
        if (error.toString() == 'RangeError (index): Index out of range: no indices are valid: 0') {
          SnackMsg.showError(context, 'Utilizador não existe!');
        } else {
          SnackMsg.showError(context, 'Ocorreu um erro: $error');
        }
      });
    } else {
      SnackMsg.showError(context, 'Esse utilizador não é válido para enviar um convite!');
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

                                    return Stack(
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
                                              onPressed: () => sendInvite(username, discriminator),
                                              icon: const Icon(
                                                Icons.email,
                                                color: Colors.blue,
                                                size: 42,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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
