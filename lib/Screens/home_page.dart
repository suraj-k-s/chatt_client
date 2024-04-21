import 'dart:convert';

import 'package:chatt_client/Screens/chat_screen.dart';
import 'package:chatt_client/Screens/profile_screen.dart';
import 'package:chatt_client/Screens/status_screen.dart';
import 'package:chatt_client/Widgets/logout.dart';
import 'package:chatt_client/Widgets/sucess_easy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late SharedPreferences sharedPreferences;
   String userId = '';
  List<Map<String, dynamic>> chatList = [];
  List<Map<String, dynamic>> distinctChatList = [];
  List<Map<String, dynamic>> chatHeader = [];
   String totalNewMessageCounter='0';
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
getMessageHeader();
    super.initState();
  }
  Future<void> getMessageHeader() async {
    Query chatsQuery = FirebaseDatabase.instance.ref().child('chats');
    chatsQuery = chatsQuery.orderByChild('timestamp');
    distinctChatList = [];
   
    try {
      User? user = FirebaseAuth.instance.currentUser;
      userId = user!.uid;
      DatabaseEvent event = await chatsQuery.once();
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;
      if (values != null) {
        List<dynamic> filteredRecords = values.entries
            .where((entry) => (entry.value['receiver_id'] == userId))
            .map((entry) {
          return entry.value;
        }).toList();
        setState(() {
          chatList = filteredRecords.reversed
              .map((record) =>
                  Map<String, dynamic>.from(json.decode(json.encode(record))))
              .toList();
          chatList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        });
        for (int i = 0; i < chatList.length; i++) {
          // print('Message ${chatList[i]['sender_id']}: ${chatList[i]['message']}');
          final userRef = FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(chatList[i]['sender_id']);
          final nameEvent = await userRef.child('name').once();
          final nameSnapshot = nameEvent.snapshot;
          final imageUrlEvent = await userRef.child('profilePicture').once();
          final imageUrlSnapshot = imageUrlEvent.snapshot;
          chatList[i]['sender_name'] = nameSnapshot.value.toString();
          chatList[i]['profilePicture'] = imageUrlSnapshot.value.toString();
        }
        Map<String, int> senderIdCountWithStatus1 = {};
        for (var chat in chatList) {
          if (chat['status'] == '1') {
            String senderId = chat['sender_id'];
            senderIdCountWithStatus1[senderId] =
                (senderIdCountWithStatus1[senderId] ?? 0) + 1;
          }
        }
        int distinctSenderCountWithStatus1 = 0;
      Set<String> distinctSenderIds = {}; // Set to store unique sender_ids
      for (var chat in chatList) {
        if (chat['status'] == '1') {
          if (!distinctSenderIds.contains(chat['sender_id'])) {
            distinctSenderCountWithStatus1++;
            distinctSenderIds.add(chat['sender_id']);
          }
        }
      }

        for (var chat in chatList) {
          bool exists = distinctChatList
              .any((element) => element['sender_id'] == chat['sender_id']);
          if (!exists) {
            chat['new_message_count'] =
                senderIdCountWithStatus1[chat['sender_id']] ?? 0;
            distinctChatList.add(chat);
          }
        }

        setState(() {
          chatHeader = distinctChatList;
          totalNewMessageCounter=distinctSenderCountWithStatus1.toString();
        });
        ScreenLoader().screenLoaderDismiss('2', '');
      }
    } catch (e)
    // ignore: empty_catches
    {}
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chatter Box',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: const Icon(
            Icons.mark_chat_read_rounded,
            color: Colors.yellow,
          ),
          backgroundColor: Colors.lightGreen[800],
          actions: <Widget>[
            PopupMenuButton<int>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              iconSize: 24,
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                    value: 0,
                    child: TextButton(
                        onPressed: () async {
                          ScreenLogout().sessionLogout(context);
                        },
                        child: const Text('Logout'))),
                PopupMenuItem<int>(
                    value: 1,
                    child: TextButton(
                        onPressed: () async {
                          ScreenLoader().screenLoaderSuccessFailStart();

                          // ignore: use_build_context_synchronously
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const ScreenProfile()));
                        },
                        child: const Text('Profile'))),
              ],
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Column(
              children: [
                Container(
                  color: Colors.lightGreen[800],
                  child: TabBar(
                      controller: tabController,
                      unselectedLabelColor: Colors.grey,
                      labelColor: Colors.white,
                      tabs:  [
                        Tab(
                            child: badges.Badge(
                          badgeStyle:
                               badges.BadgeStyle(badgeColor:totalNewMessageCounter=='0'?Colors.transparent: Colors.yellow),
                          badgeContent: Text(totalNewMessageCounter=='0'?'':totalNewMessageCounter),
                          child: const Text(
                            'Chats',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        )),
                        const Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                            'Status',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          Visibility(
                            visible: true,
                            child: Padding(
                              padding: EdgeInsets.only(left: 3),
                              child: Icon(Icons.circle,
                              size: 10,
                              ),
                            ),
                          )
                            ],
                          )
                        ),
                      ]),
                ),
                Expanded(
                  child: TabBarView(
                      controller: tabController,
                      children: const [ScreenChat(), ScreenStatus()]),
                )
              ],
            )
          ],
        ));
  }
}
