import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class ScreenPersonalChatUp extends StatefulWidget {
  final String friendId;
  const ScreenPersonalChatUp({super.key, required this.friendId});

  @override
  State<ScreenPersonalChatUp> createState() => _ScreenPersonalChatUpState();
}

class _ScreenPersonalChatUpState extends State<ScreenPersonalChatUp> {
  // ignore: unused_field
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ignore: unused_field
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('chats');
  // ignore: unused_field
  late StreamController<List<dynamic>> _chatMessagesController;
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
  late final DatabaseReference databaseReference;
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

  // Create a unique identifier for the chat conversation
  String chatId = userId.compareTo(widget.friendId) < 0
    ? '$userId-${widget.friendId}'
    : '${widget.friendId}-$userId';

  DatabaseReference chatsRef = FirebaseDatabase.instance.ref().child('chats/$chatId');
  Map<String, dynamic> chatData = {
    'sender_id': userId,
    'receiver_id': widget.friendId,
    'message': messageController.text,
    'timestamp': DateTime.now().toString(),
    'status': '1'
  };
  try {
    await chatsRef.push().set(chatData);
    messageController.text = '';
  } catch (e)
  // ignore: empty_catches
  {}
}

  @override
  void initState() {
    _chatMessagesController = StreamController<List<dynamic>>();
    getFriendData();
    User? user = FirebaseAuth.instance.currentUser;
    userId = user!.uid;
    messageIcon = const Icon(
      Icons.mic,
      size: 24, // Adjust the icon size as needed
      color: Colors.white, // Adjust the icon color as needed
    );
     String chatId = userId.compareTo(widget.friendId) < 0
    ? '$userId-${widget.friendId}'
    : '${widget.friendId}-$userId';
  // Set up the DatabaseReference for the specific chat conversation
  databaseReference = FirebaseDatabase.instance.ref().child('chats/$chatId');

  // Listen for changes in the specific chat conversation node
  databaseReference.onChildAdded.listen((event) {
    Map<String, dynamic> message = event.snapshot.value as Map<String, dynamic>;
    setState(() {
      chatList.add(message);
    });
  });
    super.initState();
  }
@override
void dispose() {
 
  super.dispose();
  // Remove the listener to avoid memory leaks
  databaseReference.onChildAdded.drain();
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
                '${friendName}new',
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
                    height: 300,
                    child: ListView.builder(
  itemCount: chatList.length,
  itemBuilder: (context, index) {
    Map<String, dynamic> message = chatList[index];
    return Text(message['message']);
  },
)
                  ),
                  // const Divider(),
                  SizedBox(
                      height: 60,
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
                                      icon: const Icon(Icons.attach_file),
                                      onPressed: () {},
                                    ),
                                    const Text(
                                      '\u20B9',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.black,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.camera_alt_outlined),
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
