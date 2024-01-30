import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jinx/models/room_model.dart';
import 'package:jinx/models/user_model.dart';
import 'package:jinx/models/usercarddetails_model.dart';
import 'package:jinx/screens/group_chat_screen.dart';
import 'package:jinx/screens/rooms_screen.dart';
import 'package:jinx/widgets/card_users.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class OngoingRoom extends StatefulWidget with ChangeNotifier {
  UserModel user;
  final roomId;

  //bool isInRoom;
  OngoingRoom(this.user, this.roomId /*this.isInRoom*/);

  @override
  State<OngoingRoom> createState() => _OngoingRoomState();
}

class _OngoingRoomState extends State<OngoingRoom> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final String? currentUserName = FirebaseAuth.instance.currentUser?.displayName;
  final currentUserphoto = FirebaseAuth.instance.currentUser?.photoURL;

  bool isinRoom = true;

  String? adim;
  String? name;
  String? photo;
  Timer? timer;

  //bool isloading = false;
  buildNoContent() {
    return Container(
      padding: EdgeInsets.only(top: 100),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.emoji_emotions,
              size: 100,
              color: Colors.purple,
            ),
            Text(
              'there is not rooms to show...\n',
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> map1 = {};
  int n = 0;

  _getUserinroom(roomid) async {
    QuerySnapshot allusers = await FirebaseFirestore.instance
        .collection('usersinRoom')
        .doc(roomid)
        .collection("list")
        .get();
    allusers.docs.forEach((element) {
      UserCardDetails all = UserCardDetails.fromMap(element);

      map1.putIfAbsent(all.id, () => all.roomId);
    });
  }

  int? isuserInroom;

  _roomUserIn() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('roomuserin')
        .where('userId', isEqualTo: currentUserId)
        .get();

    setState(() {
      isuserInroom = snapshot.docs.length;
    });
  }

  _dialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                'You are currently in a room, please leave it and try again',
                style: TextStyle(color: Colors.red)),
            content: Text(
                'because we send you notifications from the room you are in, you have to leave it first'),
          );
        });
  }

  @override
  void initState() {
    _roomUserIn();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return /*isloading == true?Container(color: Colors.black12,child: Center(child: CircularProgressIndicator(color: Colors.purple,),),):*/ StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data?.docs.length != 0) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    adim = data["userId"];

                    if (n < 1) {
                      snapshot.data?.docs.forEach((element) {
                        _getUserinroom(element.id);
                      });
                      n++;
                    }

                    DateTime dateTime =
                        DateTime.parse(data['time'].toDate().toString());
                    // var formattedTime = DateFormat.Hm().format(dateTime);
                    if (DateTime.now().difference(dateTime).inHours > 25 && widget.roomId != 'jLhQUkYfk2Nelc3H9aRn45FJpap2') {

                      FirebaseFirestore.instance
                          .collection('usersinRoom')
                          .doc(data.id)
                          .delete();
                      FirebaseFirestore.instance
                          .collection('roomuserin')
                          .doc(currentUserId)
                          .delete();
                      FirebaseFirestore.instance
                          .collection('rooms')
                          .doc(data.id)
                          .delete();
                    }

                    RoomModel rooms = RoomModel(
                        createdBy: data["createdBy"],
                        language: data["language"],
                        roomId: data["roomId"],
                        title: data["title"],
                        type: data["type"],
                        userId: data["userId"],
                        //photo:data["photo"] ,
                        //count:data["count"] /*count*/,
                        time: data["time"]);
                    return Container(
                      height: 180,
                      margin: EdgeInsets.only(top: 3),
                      child: InkWell(
                        onTap: (data["type"] == "public" ||
                                adim == currentUserId)
                            ? () async {
                                if (isuserInroom != 0 &&
                                    widget.roomId != data['roomId']) {
                                  return _dialog();
                                }
                                var key = map1.keys
                                    .where((k) => map1[k] == data["roomId"]);

                                if (key.contains(currentUserId)) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => GroupChatScreen(
                                                data['title'],
                                                data['roomId'],
                                                widget.user,
                                                adim,
                                              )));
                                } else {
                                  FirebaseFirestore.instance
                                      .collection('roomuserin')
                                      .doc(widget.user.id)
                                      .set({
                                    'userId': currentUserId,
                                    'title': data['title'],
                                    'roomId': data['roomId'],
                                    "adim": data["userId"]
                                  }).then((value) {
                                    //NOTE: copy this and add in create room so the creator is added to the room list as well
                                    //NOTE2: use created by or userID in collection rooms to give adim privilleges
                                    FirebaseFirestore.instance
                                        .collection('usersinRoom')
                                        .doc(data['roomId'])
                                        .collection("list")
                                        .doc(currentUserId)
                                        .set({
                                      'userId': currentUserId,
                                      'title': data['title'],
                                      'roomId': data['roomId'],
                                      "name": currentUserName,
                                      "photo": currentUserphoto,
                                    });
                                  });

                                  Provider.of<userInRoom>(context,
                                          listen: false)
                                      .changeValue(
                                    true, /*data['roomId']*/
                                  );

                                  ///aiughefiguaegifoguioaefhoieafaefae////////////////
                                  FirebaseMessaging.instance.subscribeToTopic(data['roomId']);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => GroupChatScreen(
                                                data['title'],
                                                data['roomId'],
                                                widget.user,
                                                adim,
                                              )));
                                }
                              }
                            : null,
                        child: Card(
                            color: Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CardUsers(rooms)),
                      ),
                    );
                  });
            } else {
              return buildNoContent();
            }
          }

          ///test
          return Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.purple,
              ),
            ),
          );
        });
  }
}
