import 'package:chatt_client/Screens/personal_chat.dart';
import 'package:chatt_client/Widgets/sucess_easy.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ScreenSearchContact extends StatefulWidget {
  const ScreenSearchContact({super.key});

  @override
  State<ScreenSearchContact> createState() => _ScreenSearchContactState();
}

class _ScreenSearchContactState extends State<ScreenSearchContact> {
 final databaseReference = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> userList = [];
  List<Map<String, dynamic>> userList2 = [];
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black54,
            ),
          ),
          backgroundColor: Colors.green,
          title: const Row(
            children: [
              Text(
                'Search',
                style: TextStyle(color: Colors.white),
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
                  image: AssetImage("assets/chat_background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListView(
              children: [
                SizedBox(
                  height: 100,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: 50, top: 10, left: 50),
                    child: TextFormField(
                        onChanged: (value) {
                          setState(() {});
                        },
                        controller: _searchController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Search with Mobile Number",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(),
                          ),
                        )),
                  ),
                ),
                SizedBox(
                    height: 1000,
                    child: StreamBuilder(
                        stream: _searchController.text.isEmpty
                            ? databaseReference
                                .child('users')
                                .orderByChild('mobile')
                                .onValue
                            : databaseReference
                                .child('users')
                                .orderByChild('mobile')
                                .startAt(_searchController.text)
                                .endAt('${_searchController.text}\uf8ff')
                                .onValue,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('');
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.snapshot.value == null) {
                            return const Padding(
                              padding: EdgeInsets.only(left: 130),
                              child: Text(
                                'No Data Available',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            );
                          }
                          var dataValues = snapshot.data!.snapshot.value;
                          if (dataValues == null || dataValues is! Map) {
                            return const Text(
                                'Data is not in the expected format');
                          }

                          Map<dynamic, dynamic> values = dataValues;
                          userList = [];
                          values.forEach((key, value) {
                            if (value != null && value is Map) {
                              Map<String, dynamic> user =
                                  Map<String, dynamic>.from(value);
                              user['id'] = key;
                              userList.add(user);
                            }
                          });

                          return ListView.separated(
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    ScreenLoader()
                                        .screenLoaderSuccessFailStart();
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (ctx) =>
                                                ScreenPersonalChat(
                                                    friendId: userList[index]
                                                        ['id'])));
                                    ScreenLoader().screenLoaderDismiss('2', '');
                                  },
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        userList[index]['profilePicture'],
                                      ),
                                    ),
                                    title: Text(
                                      userList[index]['name'],
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Georgia',
                                          fontSize: 20),
                                    ),
                                    subtitle: Text(
                                      userList[index]['mobile'],
                                      style: const TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 15,
                                        //fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const Divider();
                              },
                              itemCount: userList.length);
                        }))
              ],
            )
          ],
        ));
  }
}
