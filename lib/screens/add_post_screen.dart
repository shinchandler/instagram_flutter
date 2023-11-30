import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:neumorphic_ui/neumorphic_ui.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
      );

      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
        clearImage();
        showSnackBar(context, 'Posted');
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, res);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.black,
          title: Center(
              child: const Text(
            'Create a Post',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Take a photo'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.camera);

                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Choose From Gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.gallery);

                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: Text(
                  '❌ Cancel',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return _file == null
        ? Center(
            child: NeumorphicButton(
              onPressed: () => _selectImage(context),
              style: NeumorphicStyle(
                shape: NeumorphicShape.concave,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                depth: 8,
                intensity: 0.8,
                color: Colors.white, // Set the color of the button
                shadowDarkColor: Colors.grey, // Set the color of the shadow
                shadowLightColor: Colors.white, // Set the color of the light shadow
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.upload,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 12),
                  Text('Upload Post', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                onPressed: clearImage,
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text("New Post", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              actions: [
                TextButton(
                  onPressed: () => postImage(
                    user.uid,
                    user.username,
                    user.photoUrl,
                  ),
                  child: Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                _isLoading
                    ? LinearProgressIndicator(
                        color: Colors.blueAccent,
                      )
                    : const SizedBox.shrink(),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user.photoUrl),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          controller: _descriptionController,
                          decoration: const InputDecoration(hintText: 'Write a caption', hintStyle: TextStyle(color: Colors.grey)),
                          maxLines: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: MemoryImage(_file!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
