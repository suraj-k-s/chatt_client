import 'dart:io';
import 'package:chatt_client/Screens/login_screen.dart';
import 'package:chatt_client/Widgets/sucess_easy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_glow/flutter_glow.dart';


class ScreenSignUp extends StatefulWidget {
  const ScreenSignUp({super.key});

  @override
  State<ScreenSignUp> createState() => _ScreenSignUpState();
}

class _ScreenSignUpState extends State<ScreenSignUp> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final cpasswordController = TextEditingController();
  bool canSeePassword = true;
  bool canSeeConfrimPassword = true;
  XFile? _selectedImage;
  String updateImage = '';
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    canSeePassword = true;
    updateImage='';
    super.initState();
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    // ignore: unnecessary_null_comparison
    if (PickedFile != null) {
      setState(() {
        _selectedImage = XFile(pickedFile!.path);
        updateImage=_selectedImage!.path;
      });
    }
  }
  Future<void>addUser() 
  async{
    ScreenLoader().screenLoaderSuccessFailStart();
    //  _progressDialog.show();
      try{
           UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
       String userId = userCredential.user!.uid;
        await insertUserData(userId);
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const ScreenLogin()));
        ScreenLoader().screenLoaderDismiss('1', 'User Registration Sucessfull');
      }
      catch(e)
      // ignore: empty_catches
      {
        ScreenLoader().screenLoaderDismiss('0', 'Error');
      }

  }
  Future<void> insertUserData(String userId)async{
    String nameLowerCase=nameController.text;
     DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
     Map<String, dynamic> userData = {
      'name': nameController.text,
      'name_lower_case': nameLowerCase.toLowerCase(),
      'email': emailController.text,
      'password': passwordController.text,
      'mobile': mobileController.text
    };
    return usersRef
        .child(userId)
        .set(userData)
        .then(
          (_) => uploadImage(userId),
        )
        .catchError((error) => ScreenLoader().screenLoaderDismiss('0', 'Error'));
  }
  Future<void> uploadImage(String userId)async{
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
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const Padding(
                    padding: EdgeInsets.only(left: 100),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 60),
                    child: Text(
                      'Kindly provide your details',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 50),
                    child: GestureDetector(
                      onTap: pickImage,
                      child: Center(
                        child: GlowContainer(
                          glowColor: Colors.purple,
                          shape: BoxShape.circle,
                          child: CircleAvatar(
                            backgroundImage: _selectedImage != null
                                ? FileImage(File(_selectedImage!.path))
                                : const AssetImage('assets/user_dummy.png')
                                    as ImageProvider,
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
                      keyboardType: TextInputType.phone,
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
                  const Padding(
                    padding: EdgeInsets.only(right: 230, top: 10),
                    child: Text(
                      'Password',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 50, top: 5),
                    child: TextFormField(
                        controller: passwordController,
                        obscureText: canSeePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password Cannot be empty!';
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
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                canSeePassword = !canSeePassword;
                              });
                            },
                            icon: canSeePassword==true?const Icon(
                              Icons.remove_red_eye_outlined,
                            ):const Icon(
                              Icons.password,
                            ),
                          ),
                        )),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 230, top: 10),
                    child: Text(
                      'Confirm Password',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 50, top: 5),
                    child: TextFormField(
                        controller: cpasswordController,
                        obscureText: canSeeConfrimPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password Cannot be empty!';
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
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                canSeeConfrimPassword = !canSeeConfrimPassword;
                              });
                            },
                            icon: canSeeConfrimPassword==true?const Icon(
                              Icons.remove_red_eye_outlined,
                            ):const Icon(
                              Icons.password,
                            ),
                          ),
                        )),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 100, right: 140, top: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        if (passwordController.text !=
                            cpasswordController.text) {
                          ScreenLoader()
                              .screenLoaderDismiss('0', 'Password Mismatch!');
                        } else {
                          if (_formKey.currentState!.validate()) {
                            if (updateImage == '') {
                              final snackBar = SnackBar(
                                content:
                                    const Text('Please upload your photo.'),
                                action: SnackBarAction(
                                  label: 'Ok',
                                  onPressed: () {},
                                ),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } else {

                              addUser();
                              
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
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.black, fontSize: 20),
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
