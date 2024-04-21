import 'dart:async';
import 'package:chatt_client/Screens/login_screen.dart';
import 'package:chatt_client/Widgets/sucess_easy.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenLogout {
  ScreenLogout._internal();
  static ScreenLogout instance = ScreenLogout._internal();
  factory ScreenLogout() {
    return ScreenLogout.instance;
  }
  Future<void> sessionLogout(BuildContext context) async {
    final sharedpreference = await SharedPreferences.getInstance();
    sharedpreference.clear();
    ScreenLoader().screenLoaderSuccessFailStart();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ScreenLogin()),
        (Route<dynamic> route) => false);
    ScreenLoader().screenLoaderDismiss('2', '');
  }
}
