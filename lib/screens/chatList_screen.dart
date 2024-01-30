import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinx/models/user_model.dart';
import 'package:jinx/widgets/user_details.dart';
import 'package:provider/provider.dart';

import 'chat_screen.dart';

class ChatList extends StatefulWidget {
  final UserModel userModel;

  ChatList(this.userModel);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  //final usersRef = FirebaseFirestore.instance.collection('users');

  //UserModel? otherUser;

  //bool selected = false;


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
              'chat empty...\n',
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
  var formattedTime;
  getTimeDifferenceFromNow(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 5) {
      formattedTime= "Just now";
    } else if (difference.inMinutes < 1) {
      formattedTime= "${difference.inSeconds}s";
    } else if (difference.inHours < 1) {
      formattedTime= "${difference.inMinutes}m";
    } else if (difference.inHours < 24) {
      formattedTime= "${difference.inHours}h";
    } else {
      formattedTime= "${difference.inDays}d";
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          //automaticallyImplyLeading: false,
          title: Text(
            'Chats', /*style: GoogleFonts.dongle(color: Colors.white,),*/
          ),
          backgroundColor: Colors.transparent,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chatList')
              .doc(currentUserId)
              .collection('userChatList')
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {

            if (snapshot.hasData) {
              if (snapshot.data?.docs.length != 0)
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index];

                      final user = UserModel(
                name: data['name'],
                id: data['userId'],
                photo: data['photo'],
                status: '',
                        dob: Timestamp.now(),
                        email: '',
                        instagram: '',
                        bio: '',

                        //followers: [],
                        //following: []

              );
                      //Divider(color: Colors.white,),
                      DateTime dateTime = DateTime.parse(
                          data['time'].toDate().toString());

                      getTimeDifferenceFromNow(dateTime);

                      return UserDetails(user,data["selected"],data['chatId'],data['text'],formattedTime);
                    });
              else {
                return buildNoContent();
              }
            }

            return Container(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              ),
            );

          },
        ));
  }
}
