import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_pap/components/primary_button.dart';
import 'package:my_pap/components/profile_list_item.dart';
import 'package:my_pap/components/profile_picture.dart';
import 'package:my_pap/components/text_box.dart';
import 'package:my_pap/pages/groups_page.dart';

class GroupInformationPage extends StatefulWidget {
  final String? groupId;
  const GroupInformationPage({super.key, required this.groupId});

  @override
  State<GroupInformationPage> createState() => _GroupInformationPageState();
}

class _GroupInformationPageState extends State<GroupInformationPage> {
  void changeProfilePicture() async {
    // Create a new instance of the ImagePicker
    final ImagePicker picker = ImagePicker();

    // Call this method to get an image from the user's device
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Read the image file as bytes
      final fileBytes = await image.readAsBytes();

      // Create a reference to a file in Firebase Cloud Storage
      final storageReference =
          FirebaseStorage.instance.ref().child("${DateTime.now().microsecondsSinceEpoch}${image.name}");

      // Upload the image file
      final uploadTask = storageReference.putData(fileBytes);
      final snapshot = await uploadTask.whenComplete(() {});

      // Get the download URL of the uploaded image
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Delete the previous profile picture from Cloud Storage
      String previousImageUrl = await FirebaseFirestore.instance
          .collection('Groups')
          .doc(widget.groupId)
          .get()
          .then((snapshot) => snapshot.data()!['icon_group']);

      if (previousImageUrl.isNotEmpty) {
        FirebaseStorage.instance.refFromURL(previousImageUrl).delete();
      }

      // Update the user document in Firestore with the new profile picture URL
      await FirebaseFirestore.instance.collection('Groups').doc(widget.groupId).update({
        'icon_group': downloadUrl,
      });
    } else {
      print('No Image Path Received');
    }
  }

  deleteMember(String memberUid) async {
    final messagesCollection =
        FirebaseFirestore.instance.collection('Groups').doc(widget.groupId).collection('Messages');

    QuerySnapshot querySnapshot;
    do {
      querySnapshot = await messagesCollection.where('user', isEqualTo: memberUid).limit(500).get();

      final batch = FirebaseFirestore.instance.batch();
      for (DocumentSnapshot docSnapshot in querySnapshot.docs) {
        batch.delete(docSnapshot.reference);
      }
      await batch.commit();
    } while (querySnapshot.size > 0);

    await FirebaseFirestore.instance.collection('Groups').doc(widget.groupId).update({
      'members': FieldValue.arrayRemove([memberUid]),
    });
  }

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Editar $field',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          maxLength: 252,
          decoration: InputDecoration(
            counterText: "",
            hintText: 'Insira um novo $field',
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[^#]*')),
          ],
        ),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),

          // save button
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: const Text(
              'Salvar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    // update in firestore
    if (newValue.trim().isNotEmpty) {
      await FirebaseFirestore.instance.collection('Groups').doc(widget.groupId).update({
        field: newValue,
      });
    }
  }

  deleteGroup() async {
    final CollectionReference messagesRef =
        FirebaseFirestore.instance.collection('Groups').doc(widget.groupId).collection('Messages');

    QuerySnapshot querySnapshot;

    do {
      querySnapshot = await messagesRef.limit(500).get();

      final WriteBatch writeBatch = FirebaseFirestore.instance.batch();

      for (DocumentSnapshot docSnapshot in querySnapshot.docs) {
        writeBatch.delete(docSnapshot.reference);
      }

      await writeBatch.commit();
    } while (querySnapshot.size > 0);

    // delete the "Messages" subcollection
    await FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget.groupId)
        .collection('Messages')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });

    // delete the "Groups" document
    await FirebaseFirestore.instance.collection('Groups').doc(widget.groupId).delete();

    // after delete the group
    // will show a snaskbar to confirm that the group was deleted
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.lightGreen,
        content: Text('Grupo apagado!'),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GroupsPage(),
      ),
    );
  }

  leaveGroup(List<dynamic> currentMembers, String memberUid) async {
    currentMembers.remove(memberUid);

    await FirebaseFirestore.instance.collection('Groups').doc(widget.groupId).update({
      'members': currentMembers,
    });

    // after leave the group
    // will show a snaskbar to confirm that leave the group
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.lightGreen,
        content: Text('Saiste do grupo!'),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GroupsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupo'),
        backgroundColor: Colors.grey[900],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('Groups').doc(widget.groupId).snapshots(),
        builder: (context, snapshot) {
          // get user data
          if (snapshot.hasData) {
            final groupData = snapshot.data!.data() as Map<String, dynamic>;
            final members = groupData['members'] as List<dynamic>;

            return Column(
              children: [
                const SizedBox(height: 49),

                // profile pic
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      children: [
                        ProfilePicture(
                          profilePictureUrl: groupData['icon_group'],
                          size: 200,
                        ),
                        groupData['admin'] == currentUser!.uid
                            ? Align(
                                alignment: Alignment.bottomRight,
                                child: SizedBox(
                                  width: 54,
                                  height: 54,
                                  child: IconButton(
                                    onPressed: changeProfilePicture,
                                    icon: const Icon(
                                      Icons.add_photo_alternate,
                                      size: 54,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink()
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  groupData['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[699],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  groupData['description'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[699],
                  ),
                ),
                const SizedBox(height: 20),
                groupData['admin'] == currentUser.uid ? const Divider() : SizedBox.fromSize(),

                groupData['admin'] == currentUser.uid
                    ? Column(
                        children: [
                          const Text('Alterar informações do grupo'),
                          TextBox(
                            text: groupData['name'],
                            sectionName: 'name',
                            onPressed: () => editField('name'),
                          ),
                          TextBox(
                            text: groupData['description'],
                            sectionName: 'description',
                            onPressed: () => editField('description'),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),

                const Divider(),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    'Membros do grupo',
                    style: TextStyle(
                      color: Colors.grey[599],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                Expanded(
                  child: ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        return StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('Users').doc(members[index]).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final userData = snapshot.data!.data() as Map<String, dynamic>;

                              return Column(
                                children: [
                                  Stack(
                                    children: [
                                      ProfileListItem(
                                        bio: userData['bio'],
                                        username: "${userData['username']}#${userData['discriminator']}",
                                        pictureUrl: userData['profilePicture'],
                                      ),
                                      groupData['admin'] == currentUser.uid && snapshot.data!.id != currentUser.uid
                                          ? Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Align(
                                                alignment: Alignment.bottomRight,
                                                child: IconButton(
                                                  onPressed: () => deleteMember(snapshot.data!.id),
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        );
                      }),
                ),

                const Divider(),
                const SizedBox(height: 15),
                groupData['admin'] == currentUser.uid
                    ? SizedBox(
                        width: 300,
                        height: 70,
                        child: PrimaryButton(
                          onTap: deleteGroup,
                          text: 'Apagar grupo',
                        ),
                      )
                    : SizedBox(
                        width: 300,
                        height: 70,
                        child: PrimaryButton(
                          onTap: () => leaveGroup(members, currentUser.uid),
                          text: 'Sair do grupo',
                        ),
                      ),

                const SizedBox(height: 15),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${snapshot.error}'),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
