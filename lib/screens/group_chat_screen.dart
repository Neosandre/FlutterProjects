import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emojis/emojis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jinx/chats/messages.dart';
import 'package:jinx/main.dart';
import 'package:jinx/models/message_model.dart';
import 'package:jinx/models/user_model.dart';
import 'package:jinx/screens/group_details.dart';
import 'package:jinx/screens/home_screen.dart';
import 'package:jinx/widgets/audio_player/audioplayer.dart';
import 'package:jinx/widgets/bottomlayout.dart';
import 'package:string_validator/string_validator.dart';

import '../chats/group_message.dart';
import '../widgets/groupbottomlayout.dart';
import 'invite_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final roomTitle;
  final roomId;
  UserModel userModel;
  final adim;

  GroupChatScreen(
    this.roomTitle,
    this.roomId,
    this.userModel,
    this.adim,
  );

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  MessageModel? replyMessage;
  final focusNode = FocusNode();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  List<String> kickedUsers = [];
  bool isloading = false;

  _getUserKicked() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('kicked')
        .doc(widget.roomId)
        .collection('userKicked')
        .get();
    snapshot.docs.forEach((doc) => setState(() {
          kickedUsers.add(doc.id);
        }));


  }

  _dialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Leave', style: TextStyle(color: Colors.red)),
              content: Text('are you sure you want to Leave this room?'),
              actions: [
                TextButton(
                    child: Text(
                      'Yes',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    onPressed: () async {
                      try {
                        await FirebaseMessaging.instance
                            .unsubscribeFromTopic(widget.roomId)
                            .then((value) => FirebaseFirestore.instance
                                .collection("roomuserin")
                                .doc(currentUserId)
                                .delete()
                                .then((value) => FirebaseFirestore.instance
                                    .collection('usersinRoom')
                                    .doc(widget.roomId)
                                    .collection('list')
                                    .doc(currentUserId)
                                    .delete()));

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HomeScreen(widget.userModel,'searchScreen')));
                      } on FirebaseException catch (e) {
                        SnackBar(
                            backgroundColor: Colors.red,
                            content:
                                Text("all good, You can close the room now"));
                        Navigator.pop(context);
                      }
                    }),
                TextButton(
                  child: Text(
                    'No',
                    style: TextStyle(fontSize: 18, color: Colors.purple),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]

              ///nao mechas
              );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserKicked();
  }

  @override
  Widget build(BuildContext context) {
    // final isRecording= recorder.isRecording;
    return kickedUsers.contains(currentUserId)
        ? Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
                title: Text('Kicked out'),
                backgroundColor: Colors.transparent,
                leading: IconButton(
                    icon: new Icon(Icons.arrow_back_ios),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('usersinRoom')
                          .doc(widget.roomId)
                          .collection('list')
                          .doc(currentUserId)
                          .delete();
                      Navigator.pop(context);
                    })),
            body: Container(
              //alignment: Alignment.center,
              padding: EdgeInsets.only(top: 100),
              child: Column(
                children: [
                  Text(
                    'Page not found, reasons: ',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('''
              -you have been kicked out from this room.
              -Please think about your behavior.
              ''',
                      maxLines: 20,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white))
                ],
              ),
            ),
          )
        : Scaffold(
            extendBody: true,
            backgroundColor: Colors.black,
            appBar: AppBar(
              leading: IconButton(
                  icon: new Icon(Icons.clear),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomeScreen(widget.userModel,'searchScreen')));
                  }),
              title: TextButton(
                child: Text(
                  widget.roomTitle,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupDetails(widget.userModel,
                            widget.roomId, widget.roomTitle, widget.adim))),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              //title: Text('User Name',style: GoogleFonts.dongle(color: Colors.white),),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                      onTap: () => _dialog(),
                      child: Icon(
                        Icons.arrow_circle_left,
                        color: Colors.purple,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InviteScreen(
                                  widget.userModel,
                                  widget.roomTitle,
                                  widget.adim,
                                  widget.roomId))),
                      child: Icon(
                        Icons.person_add,
                        color: Colors.purple,
                      )),
                ),
              ],
            ),
            //body: InkWell(onTap: (){ FocusScope.of(context).requestFocus(new FocusNode());},),
            ///body
            body: Column(

              children: [
                Expanded(

                  child: GroupMessage((message) {
                    replyToMessage(message);
                    //focusNode.requestFocus();
                  }, widget.roomId),
                ),

                GroupBottomLayout(focusNode, replyMessage,
                    cancelReply, widget.roomId, widget.userModel, widget.roomTitle),


              ],
            ),




            /* _gif == null
          ? Container()
          : Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  image: DecorationImage(
                    image: NetworkImage(
                      _gif!.images.original!.url!,
                    ),
                    fit: BoxFit.fill,
                  )),
            ),*/
  );
  }

  void replyToMessage(MessageModel messages) {
    setState(() {
      replyMessage = messages;
    });

  }

  cancelReply() {
    setState(() {
      replyMessage = null;
    });
  }
}

///OUTRO WIDG|Et
