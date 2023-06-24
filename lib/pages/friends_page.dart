import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_pap/components/profile_list_item.dart';
import 'package:my_pap/pages/private_conversation_page.dart';
import 'package:my_pap/providers/get_friend_id.dart';
import 'package:my_pap/providers/get_private_conversation_id.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  void createPrivateConversation(String friendId) {
    final List<String> userIds = [currentUser!.uid, friendId];
    userIds.sort();
    final conversationsCollection = FirebaseFirestore.instance.collection('PrivateConversations');
    conversationsCollection
        .where('user1', isEqualTo: userIds[0])
        .where('user2', isEqualTo: userIds[1])
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // Save conversation Id
        Provider.of<GetPrivateConversationId>(context, listen: false).updateFriendId(querySnapshot.docs[0].id);
        return;
      }

      // Create new document to collection
      else {
        conversationsCollection.add({
          'user1': userIds[0],
          'user2': userIds[1],
        }).then(
          (value) {
            // After created, will create an sub collection
            conversationsCollection.doc(value.id).collection('Messages');

            // And will save the conversation id
            Provider.of<GetPrivateConversationId>(context, listen: false).updateFriendId(value.id);
          },
        ).catchError((error) => print('Failed to add conversation: $error'));
      }
    }).catchError((error) => print('Failed to get querySnapshot1: $error'));
  }

  deleteFriend(List<dynamic> currentFriends, String friendId) async {
    currentFriends.remove(friendId);

    await FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid).update({
      'friends': currentFriends,
    });

    final friend = await FirebaseFirestore.instance.collection('Users').doc(friendId).get();
    final friendListOfFriends = friend['friends'];
    friendListOfFriends.remove(currentUser!.uid);

    await FirebaseFirestore.instance.collection('Users').doc(friendId).update({
      'friends': friendListOfFriends,
    });
  }

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
                        // Widget to show when friends list is empty
                        const Center(
                            child: Text("Não tens amigos :("),
                          )
                        :
                        // ListView.builder when there are friends
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
                                    final pictureUrl = snapshot.data!['profilePicture'];
                                    final friendsList = snapshot.data!['friends'];
                                    final friendId = snapshot.data!.id;

                                    return GestureDetector(
                                      onTap: () {
                                        Provider.of<GetFriendId>(context, listen: false).updateFriendId(friendId);
                                        createPrivateConversation(friendId);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const PrivateConversationPage()),
                                        );
                                      },
                                      child: Stack(
                                        children: [
                                          ProfileListItem(
                                            bio: bio,
                                            username: "$username#$discriminator",
                                            pictureUrl: pictureUrl,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: IconButton(
                                                onPressed: () => deleteFriend(friendsList, friendId),
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          )
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
