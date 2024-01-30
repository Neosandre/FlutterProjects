import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jinx/models/user_model.dart';
import 'package:provider/provider.dart';

import '../screens/chat_screen.dart';
import '../screens/feed_screen.dart';
import '../screens/home_screen.dart';
import '../screens/usernotfound_screen.dart';

class UserDetails extends StatelessWidget {
  UserModel user;
  bool selected;
  final chatId;
  String text;
  final time;
  UserDetails(this.user,this.selected,this.chatId,this.text,this.time);
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

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
              'empty, send message to someone...\n',
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').where("id", isEqualTo: user.id).get() ,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){

    if (snapshot.hasData) {
        if (snapshot.data?.docs.length != 0)
      {
              final allusers = UserModel(
                name: snapshot.data?.docs.first['name'],
                id: snapshot.data?.docs.first['id'],
                photo: snapshot.data?.docs.first['photo'],
                status: '',
                dob: Timestamp.now(),
                email: '',
                instagram: '',
                bio: '',
                  //followers: [],
                  //following: []
              );
              return InkWell(
                onTap: ()async {
      // setState(() {
      selected = true;
      // });
      Provider.of<chatselected>(context, listen: false)
          .changeValue(true);

      if (user != null) {
      FirebaseFirestore.instance
          .collection("chatList")
          .doc(currentUserId)
          .collection('userChatList')
          .doc(user.id)
          .update({"selected": true});

      Navigator.push(
      context,
      MaterialPageRoute(
      builder: (context) =>
      ChatScreen(allusers, chatId),
      ));
      } else {
      FirebaseFirestore.instance
          .collection("chatList")
          .doc(currentUserId)
          .collection('userChatList')
          .doc(user.id)
          .delete();
      Navigator.push(
      context,
      MaterialPageRoute(
      builder: (context) => UserNotFoundScreen()));
      }},
                child: Container(

                  color:selected == false ? Colors.purple : Colors.transparent ,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        //Divider(color: Colors.white,),

                        Row(children: [
                          CachedNetworkImage(
                            imageUrl: allusers.photo,
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


                          Row(
                            children: [
                              RichText(
                                overflow: TextOverflow.clip,
                                text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),

                                    children: [
                                      TextSpan(
                                          text: allusers.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,/*fontSize: 15*/)),

                                    ]),
                              ),
                             SizedBox(width: 10,),
                            Text(
                              time,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey,fontSize: 13),
                            ),
                          ],),
                              Container(
                                width: 300,
                                child: Text(
                                  text.trim(),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14, /*fontStyle: FontStyle.italic*/
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],)
                        ],),


                       /* ListTile(
                          //trailing: data['time'],
                          tileColor:
                              selected == false ? Colors.purple : Colors.transparent,
                          onTap: () async {
                            // setState(() {
                            selected = true;
                            // });
                            Provider.of<chatselected>(context, listen: false)
                                .changeValue(true);

                            if (user != null) {
                              FirebaseFirestore.instance
                                  .collection("chatList")
                                  .doc(currentUserId)
                                  .collection('userChatList')
                                  .doc(user.id)
                                  .update({"selected": true});

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChatScreen(allusers, chatId),
                                  ));
                            } else {
                              FirebaseFirestore.instance
                                  .collection("chatList")
                                  .doc(currentUserId)
                                  .collection('userChatList')
                                  .doc(user.id)
                                  .delete();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserNotFoundScreen()));
                            }
                          },
                          title: RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                                children: [
                                  TextSpan(
                                      text: allusers.name,
                                      style: GoogleFonts.dongle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          height: 0)),
                                ]),
                          ),
                          horizontalTitleGap: 3,
                          leading: CircleAvatar(
                            maxRadius: 30,
                            backgroundImage: NetworkImage(allusers.photo),
                          ),
                          subtitle: Text(
                            text.trim(),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18, *//*fontStyle: FontStyle.italic*//*
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),*/
                        //Divider(color: Colors.white,)
                      ],
                    ),
                  ),
                ),
              );
            }
          }
    return Container();
        });


  }
}
