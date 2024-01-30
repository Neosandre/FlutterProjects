import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinx/screens/home_screen.dart';
import 'package:jinx/screens/invite_screen.dart';
import 'package:jinx/screens/profile_screen.dart';
import 'package:jinx/screens/usernotfound_screen.dart';
import '../models/user_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class GroupDetails extends StatefulWidget {
  final UserModel userModel;
  final roomId;
  final roomTitle;
  final adim;

  GroupDetails(this.userModel, this.roomId, this.roomTitle, this.adim);

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  final usersRef = FirebaseFirestore.instance.collection('users');

  final usersinRoomRef = FirebaseFirestore.instance.collection('usersinRoom');

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  UserModel? _user;

  ///UUUUUUUUUUUUSSSSSSSII$$$$$$$$$$$$
  /////seeeendd user to right profile
  _getAllUsers(userId) async {
    QuerySnapshot snapshot = await usersRef.get();
    snapshot.docs.forEach((doc) {
      if (doc.id == userId) {
        UserModel user = new UserModel.fromMap(doc);
        _user = user;
      }
    });
  }

//Kicking user out of the room
  alertDialog(BuildContext context, id, name, photo) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Kick out', style: TextStyle(color: Colors.red)),
            content: Text('are you sure you want to Kick out this user?'),
            actions: [
              TextButton(
                child: Text(
                  'Yes',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('usersinRoom')
                      .doc(widget.roomId)
                      .collection('list')
                      .doc(id)
                      .delete();

                  await FirebaseFirestore.instance
                      .collection('kicked')
                      .doc(widget.roomId)
                      .collection('userKicked')
                      .doc(id)
                      .set({
                    'userId': id,
                    'userName': name,
                    'userImage': photo
                  }).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('You kicked out ${name}')));
                    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NewsFeed(user: widget.user,)));
                  });
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text(
                  'No',
                  style: TextStyle(fontSize: 18, color: Colors.purple),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void deleteroomuserin() async {
    QuerySnapshot inroom = await FirebaseFirestore.instance
        .collection('roomuserin')
        .where('roomId', isEqualTo: widget.roomId)
        .get();

    inroom.docs.forEach((userinroom) => FirebaseFirestore.instance
        .collection('roomuserin')
        .doc(userinroom.id)
        .delete());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: Text(widget.roomTitle),
          backgroundColor: Colors.transparent,
          actions: [
            widget.adim == currentUserId
                ? IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.purple,
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: Text('Delete room',
                                  style: TextStyle(color: Colors.red)),
                              content: Text(
                                  'are you sure you want to Delete this room?'),
                              actions: [
                                TextButton(
                                  child: Text(
                                    'Yes',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.red),
                                  ),
                                  onPressed: () async {
                                    deleteroomuserin();
                                    await FirebaseFirestore.instance
                                        .collection('rooms')
                                        .doc(widget.roomId)
                                        .delete()
                                        .then((value) {
                                      FirebaseFirestore.instance
                                          .collection('usersinRoom')
                                          .doc(widget.roomId)
                                          .delete();
                                    }).then((value) =>
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    backgroundColor: Colors.red,
                                                    content:
                                                        Text('room deleted'))));
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HomeScreen(widget.userModel,'searchScreen')));
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    'No',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.purple),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ]);
                        }))
                : Container(),
          ]),
      body: StreamBuilder(
          stream:
              usersinRoomRef.doc(widget.roomId).collection('list').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(30)),
                        child: //Column( children: [
                        InkWell(
                          onTap: () async {
                            await _getAllUsers(data.id);
                            _user != null
                                ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileScreen(_user!)))
                                : Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UserNotFoundScreen()));
                          },
                          child: Container(

                            color: Colors.purple ,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  //Divider(color: Colors.white,),

                                  Row(children: [
                                    CachedNetworkImage(
                                      imageUrl: data['photo'].toString(),
                                      imageBuilder: (context, imageProvider) => Container(
                                        width: 40.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider, fit: BoxFit.cover),
                                        ),
                                      ),
                                      placeholder: (context, url) => Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: AssetImage('assets/defaultprofile.jpeg'), fit: BoxFit.cover),
                                          )),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                    SizedBox(width: 5,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [


                                        RichText(
                                          overflow: TextOverflow.clip,
                                          text: TextSpan(
                                              style: TextStyle(
                                                fontSize: 14.0,
                                              ),

                                              children: [
                                                TextSpan(
                                                    text:  data['name'],
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,/*fontSize: 15*/)),

                                              ]),
                                        ),

                                      ],),
                                 SizedBox(width: 10,),
                                    widget.adim == currentUserId && currentUserId != data.id ? TextButton(child: Text("Kick"), onPressed: () => alertDialog(
                                        context,
                                        data["userId"],
                                        data['name'],
                                        data['photo']))
                                        : widget.adim == data["userId"]
                                        ? Text("Admin")
                                        : Container(),

                                  ],),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            }
            return Container();
          }),
    );
  }
}
