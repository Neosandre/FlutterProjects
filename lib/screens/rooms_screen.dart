import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jinx/models/user_model.dart';
import 'package:jinx/creation/creatroom_screen.dart';
import 'package:jinx/widgets/delete_button.dart';

import 'package:jinx/widgets/ongoing_rooms.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'group_chat_screen.dart';
import 'package:http/http.dart' as http;


class RoomScreen extends StatefulWidget {
  UserModel user;

  RoomScreen(this.user);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  String? userId;
  String? title = "title";
  String? roomId;
  String? adim;
  bool isInaRoom = false;
  bool hasInternet = false;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
////////////igiguygigguigui////////////////////
  _roomUserIn(currentUserId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('roomuserin')
        .where('userId', isEqualTo: currentUserId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        if (mounted)
          setState(() {
            userId = json.decode(json.encode(doc['userId']));
            title = json.decode(json.encode(doc['title']));
            roomId = json.decode(json.encode(doc['roomId']));
            isInaRoom = true;
            adim = json.decode(json.encode(doc['adim']));
          });
      }
    }
  }



  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();

    /* await Future.delayed(Duration(milliseconds: 1500));
    //items.add((items.length + 1).toString());
    Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (a, b, c) =>
            NotificationScreen(widget.user),
        transitionDuration: Duration(seconds: 10)));
    return Future.value(false);*/

    if (mounted) setState(() {});
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //isInaRoom = Provider.of<userInRoom>(context).isUserInRoom;
  }

  @override
  Widget build(BuildContext context) {
    if (isInaRoom != true) {
      isInaRoom = Provider.of<userInRoom>(context).isUserInRoom;
    }
    _roomUserIn(widget.user.id);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: RichText(
            text: TextSpan(
          style: GoogleFonts.mochiyPopPOne(fontSize: 30),
          children: const <TextSpan>[
            TextSpan(
                text: 'jin',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            TextSpan(
                text: 'X',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.purple)),
          ],
        )),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: isInaRoom == false ? Colors.white : Colors.grey,
            ),
            onPressed: isInaRoom == false
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateRoomScreen(
                              userModel: widget.user,
                            )))
                : null,
          ),
          /*TextButton(onPressed:()=>Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DeleteScreen())) , child:Text("adm",style: TextStyle(color: Colors.purple),))*/

          ///tobedeleted/////////
          // IconButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>Test())), icon: Icon(Icons.play_circle_fill)),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onLoading: _onLoading,
        onRefresh: _onRefresh,
        enablePullDown: true,
        enablePullUp: true,
        footer: ClassicFooter(),
        header: WaterDropMaterialHeader(
          backgroundColor: Colors.purple,
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              isInaRoom == false
                  ? Container()
                  : GestureDetector(
                      onTap: () {
                        print(title);
                        print(roomId);
                        print(adim);

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroupChatScreen(
                                    title, roomId, widget.user, adim)));
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        color: Colors.purple,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 3.0),
                              child: Icon(Icons.star),
                            ),
                            Container(
                              width: 330,
                              padding: const EdgeInsets.all(5.0),
                              child: Text('$title',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ),
              OngoingRoom(widget.user, roomId),
            ],
          ),
        ),
      ),
    );
  }
}

///hot to create chenge notifire #1 create this class then add up on the tree this case Homescreen
class userInRoom extends ChangeNotifier {
  bool isUserInRoom = false;

  /*String? newroomId;*/

  void changeValue(
    bool newValue,
    /*String newroomId*/
  ) {
    isUserInRoom = newValue;
    //newroomId = newroomId;
    notifyListeners();
  }
}
