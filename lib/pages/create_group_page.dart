import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_pap/components/big_text_field.dart';
import 'package:my_pap/components/primary_button.dart';
import 'package:my_pap/components/profile_picture.dart';
import 'package:my_pap/components/validated_text_field.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final groupNameTextController = TextEditingController();
  final groupDescriptionTextController = TextEditingController();
  Uint8List? groupImage;
  String imageName = '';

  displayImage() async {
    // Create a new instance of the ImagePicker
    final ImagePicker picker = ImagePicker();

    // Call this method to get an image from the user's device
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Save the image name
      imageName = image.name;

      // Read the image file as bytes
      groupImage = await image.readAsBytes();
    } else {
      groupImage = null;
    }
    setState(() {});
  }

  createGroup() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (groupNameTextController.text.trim().isNotEmpty) {
      // Create a reference to a file in Firebase Cloud Storage
      final storageReference =
          FirebaseStorage.instance.ref().child("${DateTime.now().microsecondsSinceEpoch}$imageName");

      if (groupImage != null) {
        // Upload the image file
        final uploadTask = storageReference.putData(groupImage!);
        final snapshot = await uploadTask.whenComplete(() {});

        // Get the download URL of the uploaded image
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Create Group
        await FirebaseFirestore.instance.collection('Groups').add(
          {
            'admin': currentUser!.uid,
            'description': groupDescriptionTextController.text,
            'icon_group': downloadUrl,
            'members': [currentUser.uid],
            'name': groupNameTextController.text,
          },
        );
      } else {
        await FirebaseFirestore.instance.collection('Groups').add(
          {
            'admin': currentUser!.uid,
            'description': groupDescriptionTextController.text,
            'icon_group': '',
            'members': [currentUser.uid],
            'name': groupNameTextController.text,
          },
        );
      }

      // After creating the group, will pop the screen and show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.lightGreen,
          content: Text('Grupo criado!'),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Grupo'),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: SizedBox(
          width: 351,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 255,
                    height: 200,
                    child: Row(
                      children: [
                        groupImage != null
                            ? SizedBox(
                                width: 200,
                                height: 200,
                                child: ClipOval(
                                  child: SizedBox.fromSize(
                                    size: const Size.fromRadius(48),
                                    child: Image.memory(groupImage!, fit: BoxFit.fill),
                                  ),
                                ))
                            : ProfilePicture(profilePictureUrl: '', size: 200),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            width: 54,
                            height: 54,
                            child: IconButton(
                              onPressed: displayImage,
                              icon: const Icon(
                                Icons.add_photo_alternate,
                                color: Colors.black,
                                size: 54,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  ValidatedTextFormField(
                    controller: groupNameTextController,
                    hintText: 'Nome do grupo',
                    obscureText: false,
                    maxLenght: 128,
                  ),
                  const SizedBox(height: 25),
                  BigTextFormField(
                    controller: groupDescriptionTextController,
                    hintText: 'Descrição do grupo',
                    maxLenght: 252,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 25),
                  PrimaryButton(
                    onTap: createGroup,
                    text: 'Criar grupo',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
