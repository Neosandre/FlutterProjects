import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jinx/chats/messages.dart';
import 'package:jinx/main.dart';
import 'package:jinx/models/message_model.dart';
import 'package:jinx/models/user_model.dart';
import 'package:jinx/screens/chatList_screen.dart';
import 'package:jinx/screens/profile_screen.dart';
import 'package:jinx/screens/usernotfound_screen.dart';
import 'package:jinx/widgets/audio_player/audioplayer.dart';
import 'package:jinx/widgets/bottomlayout.dart';

import '../chats/test.dart';

class ChatScreen extends StatefulWidget {
  UserModel userModel;
  String chatId;

/*
  final id;
  final name;
  final photo;
*/

  ChatScreen(this.userModel, this.chatId /*,this.id, this.name, this.photo,*/);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  MessageModel? replyMessage;
  final focusNode = FocusNode();
  UserModel? user;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  String? exist;

  /*findUser(id, userModelId) {
    if (id == userModelId) {
      user = widget.userModel;
    }
  }*/

  UserModel? otherUser;
  final usersRef = FirebaseFirestore.instance.collection('users');
  _getAllUsers(userId) async {
    QuerySnapshot snapshot =
    await usersRef.where("id", isEqualTo: userId).get();
    snapshot.docs.forEach((doc) {
      otherUser = new UserModel.fromMap(doc);
    });
  }

  void sendToUserProfile() {
    if (otherUser != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ProfileScreen(otherUser!)));
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => UserNotFoundScreen()));
    }
  }

  @override
  void initState() {
    //findUser(currentUserId, widget.userModel.id);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final isRecording= recorder.isRecording;

    return Scaffold(

      //extendBody: true,
      //resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(

        leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios),
            onPressed: () async {

              QuerySnapshot userList = await FirebaseFirestore.instance
                  .collection('chatList')
                  .doc(currentUserId)
                  .collection('userChatList')
                  .get();
              userList.docs.forEach((element) {
                if (element.id == widget.userModel.id) {
                  exist = element.id;
                }
              });
              if (exist == null) {
                await FirebaseFirestore.instance
                    .collection('privatechat')
                    .doc(widget.chatId)
                    .delete();
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            }),

        title: InkWell(
            onTap: () async{
                 await _getAllUsers(widget.userModel.id);
                 sendToUserProfile();
            },
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('id', isEqualTo: widget.userModel.id)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {

                if (snapshot.data != null)
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(right: 15),
                          child:CachedNetworkImage(
                          imageUrl: widget.userModel.photo,
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
                          ),
                     Container(
                       padding: EdgeInsets.only(bottom: 15),
                       child: Column(

                         children: [
                         /*Text('Neo',style: TextStyle(fontSize: 25),),
                        Text('online',style: TextStyle(fontSize: 12),),*/

                         Container(
                           height: 25,
                           child: Text(

                             snapshot.data?.docs.first['name'],
                             style: GoogleFonts.dongle(

                               color: Colors.white,
                               fontWeight: FontWeight.bold,
                               fontSize: 25,
                               height: 0),
                           ),
                         ),


                         Text(snapshot.data?.docs.first['status'],
                             style: snapshot.data?.docs.first['status'] ==
                                 'online'
                                 ? TextStyle(
                                 color: Colors.green, fontSize: 12)
                                 : TextStyle(
                                 color: Colors.grey, fontSize: 12)),
                       ],),
                     ),

                    ],
                  );
                return Container();
              },
            )),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        //title: Text('User Name',style: GoogleFonts.dongle(color: Colors.white),),
        actions: [],
      ),
      //body: InkWell(onTap: (){ FocusScope.of(context).requestFocus(new FocusNode());},),
      ///body
      body: Column(

        children: [
         Expanded(

            child: Messages((message) {
              replyToMessage(message);

            }, widget.chatId,),
          ),
          BottomLayout( replyMessage, cancelReply,
            widget.userModel, widget.chatId,)

        ],
      ),
       /* bottomSheet: BottomLayout( replyMessage, cancelReply,
      widget.userModel, widget.chatId,*//*onSendMessageClick*//*) ,*/



    );
  }

  void replyToMessage(MessageModel messages) {

    setState(() {
      replyMessage = messages;
    });
print(messages.message);

  }

  cancelReply() {
    setState(() {
      replyMessage = null;
    });
  }

/* onSendMessageClick(){
setState(() {

});*/


}

///OUTRO WIDG|Et

