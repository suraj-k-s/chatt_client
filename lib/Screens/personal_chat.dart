import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:intl/intl.dart';

class ScreenPersonalChat extends StatefulWidget {
  final String friendId;
  const ScreenPersonalChat({super.key, required this.friendId});

  @override
  State<ScreenPersonalChat> createState() => _ScreenPersonalChatState();
}

class _ScreenPersonalChatState extends State<ScreenPersonalChat> {
  List<Map<String, dynamic>> chatList = [];
  List<Map<String, dynamic>> tempList = [];
  String friendName = '';
  String friendImageUrl = '';
  final messageController = TextEditingController();
  bool isMessageTyped = false;
  late Icon messageIcon;
  bool isSender = false;
  String userId = '';
  String dayname = '';
  // final ScrollController _scrollController = ScrollController();
  Future<void> getFriendData() async {
    final userRef =
        FirebaseDatabase.instance.ref().child('users').child(widget.friendId);
    try {
      final nameEvent = await userRef.child('name').once();
      final nameSnapshot = nameEvent.snapshot;
      final imageUrlEvent = await userRef.child('profilePicture').once();
      final imageUrlSnapshot = imageUrlEvent.snapshot;
      setState(() {
        friendName = nameSnapshot.value.toString();
        friendImageUrl = imageUrlSnapshot.value.toString();
      });
    } catch (e)
    // ignore: empty_catches
    {}
  }

  Future<void> sendMessage() async {
    User? user = FirebaseAuth.instance.currentUser;
    userId = user!.uid;
    DatabaseReference chatsRef = FirebaseDatabase.instance.ref().child('chats');
    Map<String, dynamic> chatData = {
      'sender_id': userId,
      'receiver_id': widget.friendId,
      'message': messageController.text,
      'timestamp': DateTime.now().toString(),
      'status': '1'
    };
    try {
      await chatsRef.push().set(chatData).then((value) => getChatMessages());
      messageController.text = '';
    } catch (e)
    // ignore: empty_catches
    {}
  }

  Future<void> getChatMessages() async {
    Query chatsQuery = FirebaseDatabase.instance.ref().child('chats');
    chatsQuery = chatsQuery.orderByChild('timestamp');
    tempList = [];
    try {
      User? user = FirebaseAuth.instance.currentUser;
      userId = user!.uid;
      DatabaseEvent event = await chatsQuery.once();
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;
            if (values != null) {
        List<dynamic> filteredRecords = values.entries
            .where((entry) =>
                (entry.value['sender_id'] == userId &&
                    entry.value['receiver_id'] == widget.friendId) ||
                (entry.value['sender_id'] == widget.friendId &&
                    entry.value['receiver_id'] == userId))
            .map((entry) {
          return entry.value;
        })
        .toList();
        
        // Now filteredRecords contains the records matching the conditions
        setState(() {
          chatList = filteredRecords.reversed
              .map((record) =>
                  Map<String, dynamic>.from(json.decode(json.encode(record))))
              .toList();
             
          chatList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
          chatList = chatList.reversed.toList();
          
            
        });

        filteredRecords = values.entries
            .where((entry) =>
                (entry.value['sender_id'] == widget.friendId &&
                    entry.value['receiver_id'] ==userId) 
              )
            .map((entry) {
          // Add the document ID to the chat message before returning it
         entry.value['docId'] = entry.key;
          DatabaseReference userRef =
         FirebaseDatabase.instance.ref().child('chats').child(entry.key);
      userRef.update({
        'status': '2',        
      });
          return entry.value;
        })
        .toList();
      }
    } catch (e)
    // ignore: empty_catches
    {}
  }

  @override
  void initState() {
    getFriendData();
    getChatMessages();
    messageIcon = const Icon(
      Icons.mic,
      size: 24, // Adjust the icon size as needed
      color: Colors.white, // Adjust the icon color as needed
    );
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Remove resizeToAvoidBottomInset property
        appBar: AppBar(
          backgroundColor: Colors.green,
          leading: Row(
            children: [
              const SizedBox(
                width: 15,
              ),
              CircleAvatar(
                radius: 20,
                backgroundImage: (friendImageUrl == ''
                    ? const AssetImage('assets/user_dummy.png') as ImageProvider
                    : NetworkImage(friendImageUrl)),
              ),
            ],
          ),
          title: Row(
            children: [
              Text(
                friendName,
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                onPressed: () {},
                icon:
                    const Icon(Icons.video_chat_outlined, color: Colors.white),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.phone, color: Colors.white),
              ),
            ],
          ),
          actions: <Widget>[
            PopupMenuButton<int>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              iconSize: 24,
              itemBuilder: (context) => [
                const PopupMenuItem<int>(value: 0, child: Text('Logout')),
                const PopupMenuItem<int>(value: 1, child: Text('Settings')),
              ],
            ),
          ],
        ),
        body: Stack(children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/chat_background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SingleChildScrollView(
              // Wrap the body with SingleChildScrollView
              child: Column(
                children: [
                  SizedBox(
                    height: 700,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: SizedBox(
                        height: 740,
                        // color: Colors.white,
                        child: ListView.separated(
                          itemBuilder: (ctx, index) {
                            DateTime dateTime =
                                DateTime.parse(chatList[index]['timestamp']);
                             //   print(chatList[index]['docId']);
                            String chatTime = DateFormat.Hm().format(dateTime);
                            final df = DateFormat('dd/MM/yyyy');
                            String chatDate = df.format(dateTime);
                            if (dateTime.isAfter(
                                DateTime.now().subtract(Duration(days: 7)))) {
                              dayname = DateFormat('EEEE').format(dateTime);
                            }
                            else
                            {
                              dayname=chatDate;
                            }


                            if (chatList[index]['sender_id'] == userId) {
                              isSender = true;
                            } else {
                              isSender = false;
                            }

                            return Row(
                              mainAxisAlignment: isSender == true
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 70,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: isSender == true
                                        ? Colors.yellow[100]
                                        : Colors.green[100],
                                    border: Border.all(
                                      color: isSender == true
                                          ? Colors.amber
                                          : Colors.yellow, // Border color
                                      width: .5, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  // ignore: prefer_const_constructors
                                  child: Center(
                                      child: ListTile(
                                          title: Text(
                                            chatList[index]['message'],
                                            style: const TextStyle(
                                                fontFamily: 'Georgia',
                                                fontSize: 15),
                                          ),
                                          subtitle: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                              //  chatList[index]['status'],
                                              chatTime,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              Visibility(
                                                visible: isSender,
                                                child:  Icon(
                                                 chatList[index]['status']=='1'? Icons.check:Icons.checklist,
                                                  color: chatList[index]['status']=='1'?Colors.black: Colors.blue,
                                                ),
                                              )
                                            ],
                                          ))),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (ctx, index) {
                            return Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayname,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          },
                          itemCount: chatList.length,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  SizedBox(
                      height: 80,
                      // This width constraint might cause overflow issues; you might want to adjust it
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  if (value == '') {
                                    messageIcon = const Icon(
                                      Icons.mic,
                                      size:
                                          24, // Adjust the icon size as needed
                                      color: Colors
                                          .white, // Adjust the icon color as needed
                                    );
                                  } else {
                                    messageIcon = const Icon(
                                      Icons.send,
                                      size:
                                          24, // Adjust the icon size as needed
                                      color: Colors
                                          .white, // Adjust the icon color as needed
                                    );
                                  }
                                });
                              },
                              controller: messageController,
                              decoration: InputDecoration(
                                prefixIcon: IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.emoji_emotions_outlined,
                                    color: Colors.yellow[600],
                                  ),
                                ),
                                suffixIcon: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize:
                                      MainAxisSize.min, // Adjust this as needed
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.attach_file),
                                      onPressed: () {},
                                    ),
                                    Text(
                                      '\u20B9',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.black,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.camera_alt_outlined),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white, // Border color
                                width: 3, // Border width
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (messageController.text != '') {
                                  sendMessage();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: Colors
                                    .green, // This makes the button a circle
                                padding: const EdgeInsets.all(
                                    10), // Adjust the button color as needed
                              ),
                              child: CircleAvatar(
                                  backgroundColor: Colors
                                      .transparent, // Transparent background for the avatar
                                  child: messageIcon),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ),
        ]));
  }
}
