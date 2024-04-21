import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class ScreenStatus extends StatefulWidget {
  const ScreenStatus({super.key});

  @override
  State<ScreenStatus> createState() => _ScreenStatusState();
}

class _ScreenStatusState extends State<ScreenStatus> {
  @override
  Widget build(BuildContext context) {
    return Stack(
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
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 30, top: 10),
          child: Text(
            'Status',
            style: TextStyle(fontSize: 17),
          ),
        ),
        const ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/dummy_profile.jpg'),
                radius: 37,
              ),
              Positioned(
                  top: 35,
                  left: 65,
                  child: badges.Badge(
                    badgeStyle: badges.BadgeStyle(badgeColor: Colors.yellow),
                    badgeContent: Icon(Icons.add),
                    child: Text(''),
                  ))
            ],
          ),
          title: Text('My Status',
           style: TextStyle(
                  fontSize: 19,
                  color: Colors.white
                ),
          ),
          subtitle: Text('Tap to add status update',
           style: TextStyle(
                  fontSize: 19,
                  color: Colors.yellow
                ),
          ),
        ),
        const Divider(
          color: Colors.black,
        ),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 100,
          itemBuilder: (ctx, index) {
            return SizedBox(
              height: 100,
              child: ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.amber, // Border color
                      width: 3, // Border width
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 37,
                    backgroundImage: AssetImage('assets/dummy_profile.jpg'),
                  ),
                ),
                title: const Text('Rons David',
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.white
                ),
                ),
                subtitle: const Text('10.30AM',
                 style: TextStyle(
                  fontSize: 19,
                  color: Colors.yellow
                ),
                ),
              ),
            );
          },
          separatorBuilder: (ctx,index){
            return const Divider();
          },
        ),
      ],
    )
        
      ]
    );
  }
}
