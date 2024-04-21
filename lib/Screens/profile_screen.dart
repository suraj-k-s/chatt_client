import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chatt_client/Widgets/sucess_easy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_glow/flutter_glow.dart';

class ScreenProfile extends StatefulWidget {
  const ScreenProfile({super.key});

  @override
  State<ScreenProfile> createState() => _ScreenProfileState();
}

class _ScreenProfileState extends State<ScreenProfile> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final cpasswordController = TextEditingController();
  bool canSeePassword = true;
  bool canSeeConfrimPassword = true;
  XFile? _selectedImage;
  String updateImage = '';
  String name = '';
  String userId = '';
  late bool isEditable;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  Future<void> pickImage() async {
     updateImage = '';
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    // ignore: unnecessary_null_comparison
    if (PickedFile != null) {
      setState(() {
        _selectedImage = XFile(pickedFile!.path);
        updateImage = _selectedImage!.path;
      });
    }
  }

  Future<void> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    userId = user!.uid;
    final userRef =
        FirebaseDatabase.instance.ref().child('users').child(userId);
    try {
      final nameEvent = await userRef.child('name').once();
      final nameSnapshot = nameEvent.snapshot;
      final imageUrlEvent = await userRef.child('profilePicture').once();
      final imageUrlSnapshot = imageUrlEvent.snapshot;
      final emailEvent = await userRef.child('email').once();
      final emailSnapshot = emailEvent.snapshot;
      final mobileEvent = await userRef.child('mobile').once();
      final mobileSnapshot = mobileEvent.snapshot;
      setState(() {
        updateImage = imageUrlSnapshot.value.toString();
        name = nameSnapshot.value.toString();
        nameController.text = nameSnapshot.value.toString();
        emailController.text = emailSnapshot.value.toString();
        mobileController.text = mobileSnapshot.value.toString();
      });
    } catch (e)
    // ignore: empty_catches
    {}
  }

  Future<void> editUserData() async {
    ScreenLoader().screenLoaderSuccessFailStart();
    try {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(userId);
      userRef.update({
        'name': nameController.text,
        'mobile': mobileController.text
      }).catchError(
          (error) => ScreenLoader().screenLoaderDismiss('0', 'Error'));
          if (_selectedImage != null) {
           
            String fileName = userId+DateTime.now().toString();
             Reference ref =
          FirebaseStorage.instance.ref().child('profile_pictures/$fileName');
           UploadTask uploadTask = ref.putFile(File(_selectedImage!.path));
           await uploadTask.whenComplete(() => null);
            String downloadURL = await ref.getDownloadURL();
            DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(userId);
           userRef
          .update({'profilePicture': downloadURL})
          .catchError((error) =>
              ScreenLoader().screenLoaderDismiss('0', 'Error'));
          }
      ScreenLoader().screenLoaderDismiss('1', 'User Details Updated');
      setState(() {
        name = nameController.text;
        isEditable = false;
      });
    } catch (e) {
      ScreenLoader().screenLoaderDismiss('0', 'Error');
    }
  }

  @override
  void initState() {
    setState(() {
      isEditable = false;
    });
     updateImage = '';

    getUserData();
    ScreenLoader().screenLoaderDismiss('2', '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: const Row(
          children: [
            SizedBox(
              width: 15,
            ),
          ],
        ),
        title:const Row(
          children: [
             Text(
              'Profile',
              style:  TextStyle(color: Colors.white),
            ),
             SizedBox(
              width: 60,
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/login_background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 50),
                    child: GestureDetector(
                      onTap: isEditable==false?(() {
                        
                      }):pickImage,
                      child: Center(
                        child: GlowContainer(
                          glowColor: Colors.purple,
                          shape: BoxShape.circle,
                          child: CircleAvatar(
                            backgroundImage: _selectedImage != null
                                ? FileImage(File(_selectedImage!.path))
                                : (updateImage == ''
                                    ? const AssetImage('assets/user_dummy.png')
                                        as ImageProvider
                                    : NetworkImage(updateImage)),
                            radius: 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 230),
                    child: Text(
                      'Name',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 50, top: 10),
                    child: TextFormField(
                        enabled: isEditable,
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name Required!';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(),
                          ),
                        )),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 230, top: 10),
                    child: Text(
                      'Email',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 50, top: 10),
                    child: TextFormField(
                        enabled: false,
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter a valid emial adress!';
                          } else if (!RegExp(
                                  r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(),
                          ),
                        )),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 230, top: 10),
                    child: Text(
                      'Mobile Number',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 50, top: 10),
                    child: TextFormField(
                        enabled: isEditable,
                        controller: mobileController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mobile number required!';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(),
                          ),
                        )),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 100, right: 140, top: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditable = !isEditable;
                        });

                        if (_formKey.currentState!.validate()) {
                          if (updateImage == '') {
                            final snackBar = SnackBar(
                              content: const Text('Please upload your photo.'),
                              action: SnackBarAction(
                                label: 'Ok',
                                onPressed: () {},
                              ),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          } else {
                            if (isEditable == false) {
                              editUserData();
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35, vertical: 10),
                          textStyle: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      child: Text(
                        isEditable == true ? 'Save' : 'Edit',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}
