import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_pap/components/group_list_item.dart';
import 'package:my_pap/pages/group_conversation_page.dart';
import 'package:my_pap/providers/get_group_id.dart';
import 'package:provider/provider.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Groups')
                    .where("members", arrayContains: currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Não estás em nenhum grupo :("));
                    } else {
                      return ListView.builder(
                        addAutomaticKeepAlives: false,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final group = snapshot.data!.docs[index].data();
                          final String groupId = snapshot.data!.docs[index].id;
                          return GestureDetector(
                            onTap: () {
                              Provider.of<GetGroupId>(context, listen: false).updateGroupId(groupId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const GroupConversationPage()),
                              );
                            },
                            child: GroupListItem(
                              pictureUrl: group['icon_group'],
                              name: group["name"],
                              bio: group["description"],
                              membersQuantity: group["members"].length.toString(),
                            ),
                          );
                        },
                      );
                    }
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
