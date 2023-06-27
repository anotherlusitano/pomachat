import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_pap/auth/auth.dart';
import 'package:my_pap/components/primary_button.dart';
import 'package:my_pap/components/profile_picture.dart';
import 'package:my_pap/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  late Reference ref;

  // all users
  final usersCollection = FirebaseFirestore.instance.collection('Users');

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
          maxLength: 32,
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
      await usersCollection.doc(currentUser!.uid).update({field: newValue});
    }
  }

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
          .collection('Users')
          .doc(currentUser!.uid)
          .get()
          .then((snapshot) => snapshot.data()!['profilePicture']);

      if (previousImageUrl.isNotEmpty) {
        FirebaseStorage.instance.refFromURL(previousImageUrl).delete();
      }

      // Update the user document in Firestore with the new profile picture URL
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.uid)
          .update({'profilePicture': downloadUrl});
    } else {
      print('No Image Path Received');
    }
  }

  showWarning() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Apagar a Conta"),
          content: SizedBox(
            width: 200,
            height: 80,
            child: Column(
              children: const [
                Text("Tens a certeza que queres apagar a conta?"),
                Text("Este processo pode levar alguns minutos."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: deleteAccount,
              child: const Text("Sim"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Não"),
            )
          ],
        );
      },
    );
  }

  deleteAccount() async {
    Navigator.of(context).pop();

    // Show CircularProgressIndicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Perform Firestore querys
      deleteInvites();
      deleteFriends();
      deletePrivateConversations();
      leaveGroups();
      deleteGroups();
      await FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid).delete();

      await currentUser!.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.lightGreen,
          content: Text('Conta apagada com sucesso!'),
        ),
      );

      // After deleting, navigate to Login page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthPage(),
        ),
      );
    } catch (e) {
      // Handle exceptions
      print('Error deleting account: $e');
    }
  }

  deleteFriends() async {
    final usersCollection = FirebaseFirestore.instance.collection('Users');

    final querySnapshot = await usersCollection.where('friends', arrayContains: currentUser!.uid).get();

    for (DocumentSnapshot docSnapshot in querySnapshot.docs) {
      final docReference = docSnapshot.reference;

      await docReference.update({
        'friends': FieldValue.arrayRemove([currentUser!.uid])
      });
      print('Updated friends list of user ${docSnapshot.id}');
    }
  }

  deleteInvites() async {
    final usersCollection = FirebaseFirestore.instance.collection('Users');

    final querySnapshot = await usersCollection.where('invites', arrayContains: currentUser!.uid).get();

    for (DocumentSnapshot docSnapshot in querySnapshot.docs) {
      final docReference = docSnapshot.reference;

      await docReference.update({
        'invites': FieldValue.arrayRemove([currentUser!.uid])
      });
    }
  }

  leaveGroups() async {
    final groupCollection = FirebaseFirestore.instance.collection('Groups');

    QuerySnapshot querySnapshot;

    final querySnapsho = await groupCollection
        .where('admin', isNotEqualTo: currentUser!.uid)
        .where('members', arrayContains: currentUser!.uid)
        .get();

    for (DocumentSnapshot docSnapshot in querySnapsho.docs) {
      final docReference = docSnapshot.reference;

      // DELETE MESSAGES BEFORE LEAVING GROUP
      //------------------------------------------------------------------------
      final CollectionReference messagesRef =
          FirebaseFirestore.instance.collection('Groups').doc(docReference.id).collection('Messages');

      do {
        querySnapshot = await messagesRef.limit(500).get();

        final WriteBatch writeBatch = FirebaseFirestore.instance.batch();

        for (DocumentSnapshot docSnapshot in querySnapshot.docs) {
          writeBatch.delete(docSnapshot.reference);
        }

        await writeBatch.commit();
      } while (querySnapshot.size > 0);
      //------------------------------------------------------------------------

      await docReference.update({
        'members': FieldValue.arrayRemove([currentUser!.uid])
      });
    }
  }

  deleteGroups() async {
    final groupCollection = FirebaseFirestore.instance.collection('Groups');

    QuerySnapshot querySnapshot;

    final querySnapsho = await groupCollection.where('admin', isEqualTo: currentUser!.uid).get();

    for (DocumentSnapshot docSnapshot in querySnapsho.docs) {
      final docReference = docSnapshot.reference;

      // DELETE MESSAGES BEFORE LEAVING GROUP
      //------------------------------------------------------------------------
      final CollectionReference messagesRef =
          FirebaseFirestore.instance.collection('Groups').doc(docReference.id).collection('Messages');

      do {
        querySnapshot = await messagesRef.limit(500).get();

        final WriteBatch writeBatch = FirebaseFirestore.instance.batch();

        for (DocumentSnapshot docSnapshot in querySnapshot.docs) {
          writeBatch.delete(docSnapshot.reference);
        }

        await writeBatch.commit();
      } while (querySnapshot.size > 0);
      //------------------------------------------------------------------------

      await docReference.delete();
    }
  }

  deletePrivateConversations() async {
    //we do two querys because firestore, in dart, dont't have
    //the OR operator
    await deletePrivateConversationsFirst();
    await deletePrivateConversationsSecond();
  }

  deletePrivateConversationsFirst() async {
    final privateConversationCollection = FirebaseFirestore.instance.collection('PrivateConversations');

    QuerySnapshot querySnapshot;

    final queryForFirstField = await privateConversationCollection
        .where('user1', isEqualTo: currentUser!.uid)
        .where('user2', isNotEqualTo: currentUser!.uid)
        .get();

    for (DocumentSnapshot docSnapshot in queryForFirstField.docs) {
      final docReference = docSnapshot.reference;

      // DELETE MESSAGES BEFORE DELETING PRIVATE CONVERSATION
      //------------------------------------------------------------------------
      final CollectionReference messagesRef =
          FirebaseFirestore.instance.collection('PrivateConversations').doc(docReference.id).collection('Messages');

      do {
        querySnapshot = await messagesRef.limit(500).get();

        final WriteBatch writeBatch = FirebaseFirestore.instance.batch();

        for (DocumentSnapshot docSnapshot in querySnapshot.docs) {
          writeBatch.delete(docSnapshot.reference);
        }

        await writeBatch.commit();
      } while (querySnapshot.size > 0);
      //------------------------------------------------------------------------

      await docReference.delete();
    }
  }

  deletePrivateConversationsSecond() async {
    final privateConversationCollection = FirebaseFirestore.instance.collection('PrivateConversations');

    QuerySnapshot querySnapshot;

    //we do two querys because firestore, in dart, dont't have
    //the OR operator
    final queryForSecondField = await privateConversationCollection
        .where('user1', isNotEqualTo: currentUser!.uid)
        .where('user2', isEqualTo: currentUser!.uid)
        .get();

    for (DocumentSnapshot docSnapshot in queryForSecondField.docs) {
      final docReference = docSnapshot.reference;

      // DELETE MESSAGES BEFORE DELETING PRIVATE CONVERSATION
      //------------------------------------------------------------------------
      final CollectionReference messagesRef =
          FirebaseFirestore.instance.collection('PrivateConversations').doc(docReference.id).collection('Messages');

      do {
        querySnapshot = await messagesRef.limit(500).get();

        final WriteBatch writeBatch = FirebaseFirestore.instance.batch();

        for (DocumentSnapshot docSnapshot in querySnapshot.docs) {
          writeBatch.delete(docSnapshot.reference);
        }

        await writeBatch.commit();
      } while (querySnapshot.size > 0);
      //------------------------------------------------------------------------

      await docReference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.grey[900],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          // get user data
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

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
                          profilePictureUrl: userData['profilePicture'],
                          size: 200,
                        ),
                        Align(
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
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  "${userData['username']}#${userData['discriminator']}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[699],
                  ),
                ),

                const SizedBox(height: 49),

                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    'Os meus detalhes',
                    style: TextStyle(
                      color: Colors.grey[599],
                    ),
                  ),
                ),

                TextBox(
                  text: userData['username'],
                  sectionName: 'username',
                  onPressed: () => editField('username'),
                ),

                TextBox(
                  text: userData['bio'],
                  sectionName: 'bio',
                  onPressed: () => editField('bio'),
                ),

                const SizedBox(height: 49),
                SizedBox(
                  width: 300,
                  height: 70,
                  child: PrimaryButton(
                    onTap: showWarning,
                    text: 'Apagar conta',
                  ),
                ),
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
