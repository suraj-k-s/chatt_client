import 'dart:async';
import 'dart:convert';
//import 'package:chatt_client/Screens/personal_chat.dart';
import 'package:chatt_client/Screens/personal_chatup.dart';
import 'package:chatt_client/Screens/search_contacts.dart';
import 'package:chatt_client/Widgets/sucess_easy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';

class ScreenChat extends StatefulWidget {
  const ScreenChat({super.key});

  @override
  State<ScreenChat> createState() => _ScreenChatState();
}

class _ScreenChatState extends State<ScreenChat> {
  String userId = '';
  List<Map<String, dynamic>> chatList = [];
  List<Map<String, dynamic>> distinctChatList = [];
  List<Map<String, dynamic>> chatHeader = [];
  String totalNewMessageCounter = '0';
  @override
  void initState() {
    ScreenLoader().screenLoaderSuccessFailStart();
    totalNewMessageCounter = '0';
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
          totalNewMessageCounter = distinctSenderCountWithStatus1.toString();
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ScreenLoader().screenLoaderSuccessFailStart();
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScreenSearchContact()));
            ScreenLoader().screenLoaderDismiss('2', '');
          },
          tooltip: 'Search',
          // ignore: sort_child_properties_last
          child: const Icon(
            Icons.search,
            color: Colors.white,
          ),
          backgroundColor: Colors.amber,
        ),
        body: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/chat_background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListView.separated(
                itemBuilder: (ctx, index) {
                  DateTime dateTime =
                      DateTime.parse(chatHeader[index]['timestamp']);
                  String chatTime = DateFormat('h:mm a').format(dateTime);
                  return GestureDetector(
                    onTap: () {
                      ScreenLoader().screenLoaderSuccessFailStart();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => ScreenPersonalChatUp(
                              friendId: chatHeader[index]['sender_id'])));
                      ScreenLoader().screenLoaderDismiss('2', '');
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(chatHeader[index]['profilePicture']),
                      ),
                      title: Text(
                        chatHeader[index]['sender_name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Georgia',
                            fontSize: 20),
                      ),
                      subtitle: Text(
                        chatHeader[index]['message'],
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 15,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Column(
                        children: [
                          Text(
                            chatTime,
                            style: const TextStyle(color: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: badges.Badge(
                                badgeStyle: badges.BadgeStyle(
                                    badgeColor: chatHeader[index]
                                                ['new_message_count'] >
                                            0
                                        ? Colors.green
                                        : Colors.transparent),
                                badgeContent: Text(
                                  chatHeader[index]['new_message_count'] > 0
                                      ? chatHeader[index]['new_message_count']
                                          .toString()
                                      : ''.toString(),
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                child: const Text('')),
                          )
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (ctx, index) {
                  return const Divider();
                },
                itemCount: distinctChatList.length)
          ],
        ));
  }
}
