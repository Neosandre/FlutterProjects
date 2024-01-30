import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/bubbles/bubble_special_two.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../screens/profile_screen.dart';
import '../../screens/usernotfound_screen.dart';


class CommentBubble extends StatelessWidget {

  final String message;
  // final String userId;
  final String username;
  final String userImage;
  String time;
  final String commentId;
  final postOwnerId;
  final postId;
  final userId;
  final Key key;

  CommentBubble(
      this.message,
      // this.userId,
      this.username,
      this.userImage,
      this.time,
      this.commentId,
      this.postOwnerId,
      this.postId,
      this.userId,
      this.key
      );
  final currentUserId=FirebaseAuth.instance.currentUser!.uid;
  final String? currentUserName = FirebaseAuth.instance.currentUser?.displayName;

  report (context)async{
    showDialog(context: context, builder: (context){return AlertDialog(
        backgroundColor: Color(0xfff1efe5),
        title: Text('Report comment',style:TextStyle(color:Colors.red )),
        content: Text('are you sure you want to report this comment?'),
        actions: [
          TextButton(
              child: Text(
                'Yes',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              onPressed:  ()async{

                await FirebaseFirestore.instance.collection('reports').doc(commentId).collection('details').doc(currentUserId).set({
                  'reportedTime':DateTime.now(),
                  'reportedById':currentUserId,
                  'reportedBy':currentUserName,
                  'messageId':commentId,
                  'messageOwner':username,
                  'messageOwnerId':postOwnerId,
                  'type':'comment',
                  'message':message,

                });


                Navigator.of(context).pop();
                showDialog(context: context, builder: (context){return AlertDialog(
                    backgroundColor: Color(0xfff1efe5),
                    content: Text("Report sent",style: TextStyle(color: Colors.purple),));});
              }),



          TextButton(
            child: Text(
              'No',
              style: TextStyle(fontSize: 18,color: Colors.purple),
            ),
            onPressed: () {
              Navigator.of(context).pop();

            },
          ),
        ]

    );});

  }

  deletePost(context,commentId){
    showDialog(context: context, builder: (context){return AlertDialog(
        backgroundColor: Color(0xfff1efe5),

        title: Text('Delete Comment',style:TextStyle(color:Colors.red )),
        content: Text('are you sure you want to delete this comment?'),
        actions: [
          TextButton(
              child: Text(
                'Yes',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              onPressed:  ()async{
                print(commentId);
                await FirebaseFirestore.instance.collection('comments').doc(commentId).delete()/*.then((value) =>
                    FirebaseFirestore.instance.collection('post').doc(postId).update(
                        {
                          'commentCount':FieldValue.arrayRemove([postOwnerId])
                        })
                )*/;
                Navigator.of(context).pop();
                showDialog(context: context, builder: (context){return AlertDialog(
                    backgroundColor:Color(0xfff1efe5),
                    content: Text("Comment Deleted",style: TextStyle(color: Colors.purple),));});
              }),

          TextButton(
            child: Text(
              'No',
              style: TextStyle(fontSize: 18,color: Colors.purple),
            ),
            onPressed: () {
              Navigator.of(context).pop();

            },
          ),
        ]

    );});

  }


  UserModel? otherUser;
  final usersRef = FirebaseFirestore.instance.collection('users');
  _getAllUsers(userId) async {
    QuerySnapshot snapshot =
    await usersRef.where("id", isEqualTo: userId).get();
    snapshot.docs.forEach((doc) {
      otherUser = new UserModel.fromMap(doc);
    });
  }

  void sendToUserProfile(context) {
    if (otherUser != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ProfileScreen(otherUser!)));
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => UserNotFoundScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: GestureDetector(
        onLongPress:  currentUserId == "jLhQUkYfk2Nelc3H9aRn45FJpap2"?()=>deletePost(context, commentId):()=>report(context),
        onTap: ()async{
          await _getAllUsers(userId);
          sendToUserProfile(context);
        },
        child: Row(
            mainAxisAlignment:  MainAxisAlignment.start,
            children: <Widget> [
              CachedNetworkImage(
                imageUrl: userImage,
                imageBuilder: (context, imageProvider) => Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
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

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget> [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      username,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),

                    ),
                  ),


                  BubbleSpecialThree(
                    text: message,
                    tail: false,
                  ),


                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      time,
                      style:TextStyle(color: Colors.grey,fontSize: 10),
                      textAlign:  TextAlign.end,
                    ),
                  )

                ],
              ),

            ]),
      ),
    );



  }
}
