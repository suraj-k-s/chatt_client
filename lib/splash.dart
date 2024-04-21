import 'package:chatt_client/Screens/home_page.dart';
import 'package:chatt_client/Screens/login_screen.dart';
//import 'package:chatt_client/Widgets/logout.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenSplash extends StatefulWidget {
  const ScreenSplash({super.key});

  @override
  State<ScreenSplash> createState() => _ScreenSplashState();
}

class _ScreenSplashState extends State<ScreenSplash> {
  @override
  void initState() {
    checkUserLoggedIn();
    //ScreenLogout().sessionLogout(context);  //forcefull logout incase of infinite screen loading
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
            width: 50, height: 50, child: Image.asset('assets/splash.gif')),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> gotoLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) {
      return const ScreenLogin();
    }));
  }

  Future<void> checkUserLoggedIn() async {
    final sharedpreference = await SharedPreferences.getInstance();

    final _userLoggedIn = sharedpreference.getBool('isLoggedIn');
    if (_userLoggedIn == null || _userLoggedIn == false) {
      gotoLogin();
    } else {
      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx1) => const ScreenHome()));
    }
  }
}
