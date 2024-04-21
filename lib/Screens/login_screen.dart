import 'package:chatt_client/Screens/home_page.dart';
import 'package:chatt_client/Screens/signup_screen.dart';
import 'package:chatt_client/Widgets/sucess_easy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ScreenLogin extends StatefulWidget {
  const ScreenLogin({super.key});

  @override
  State<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {
 
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late  SharedPreferences sharedPreferences;
  @override
  void initState() {
   
   
    super.initState();
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
            child: ListView(
              children: [
                const SizedBox(
                  height: 150,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 100),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Text(
                  'Kindly provide your credentials to login',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 260),
                      child: Text(
                        'User Name',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 50, top: 10),
                      child: TextFormField(
                          controller: _emailController,
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
                      padding: EdgeInsets.only(right: 260),
                      child: Text(
                        'Password',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 50, top: 5),
                      child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password Cannot be empty!';
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
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
                        onPressed: () async {
                           sharedPreferences = await SharedPreferences.getInstance();
                          ScreenLoader().screenLoaderSuccessFailStart();
                          try {
                         
                              
                               final user =
                                (await _auth.signInWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            )).user;
                             
                            if(user!=null)
                            {
                              await sharedPreferences.setBool('isLoggedIn', true);
                               // ignore: use_build_context_synchronously
                               Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const ScreenHome()));
                               ScreenLoader().screenLoaderDismiss('1', 'Logged In');
                            }
                            else
                            {
                               ScreenLoader().screenLoaderDismiss('0', 'Invalid Login');
                            }
                          } catch (e) {
                             ScreenLoader().screenLoaderDismiss('0', '$e');
                          }
                       
                          
                          
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35, vertical: 10),
                            textStyle: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: Colors.black, fontSize: 23),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          ScreenLoader().screenLoaderSuccessFailStart();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => const ScreenSignUp()));
                          ScreenLoader().screenLoaderDismiss('2', '');
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            side: const BorderSide(
                              width: 0.0,
                              color: Colors.green,
                            )),
                        child: const Text(
                          'Sign-up',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white),
                        )),
                    ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            side: const BorderSide(
                              width: 0.0,
                              color: Colors.green,
                            )),
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white),
                        ))
                  ],
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
