import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jinx/models/post_guess_model.dart';
import 'package:jinx/models/user_model.dart';
import 'package:intl/intl.dart';
import '../screens/profile_screen.dart';
import '../screens/usernotfound_screen.dart';
import '../widgets/comment/comment_button.dart';
import '../widgets/like_button.dart';

class PostGuess extends StatefulWidget {
  UserModel user;
  PostGuessModel post;
  final time;
  final expireTime;
  final likedBy;
  List commentCount;
  PostGuess(
      this.user,
      this.post,
      this.time,
      this.expireTime,
      this.likedBy,
      this.commentCount
      );

  @override
  State<PostGuess> createState() => _PostGuessState();
}

class _PostGuessState extends State<PostGuess> {


  bool show=false;
  var expTime;

  //late DateTime dateTime;
 dynamic text="Expire on: ";
  showFunction(DateTime revealDate, ){
    if (DateTime.now().isAfter(revealDate)) {

      setState(() {
         show=true;
         text = "Expired on: ";
      });

    }

  }

  String? format;
  String fomatexp(DateTime date){
    return DateFormat('EEEE, d MMM').add_jm().format(date);
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
format=fomatexp(widget.expireTime);
    showFunction(widget.expireTime);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: ()async{
              await _getAllUsers(widget.post.userId);
              sendToUserProfile();
            },
            child: Row(children: [
              CachedNetworkImage(
                imageUrl: widget.post.photo,
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
                            text: '${widget.post.name}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ]),
                ),
                Text(
                  '${widget.time}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey),
                ),
              ],)
            ],),
          ),
             Text(widget.post.text,style: TextStyle(color: Colors.white),),
           SizedBox(height: 5,),
           show ==true? Container(child: Text(widget.post.secretWord,style: TextStyle(color: Colors.purple,fontSize: 30,fontWeight: FontWeight.bold),),):Container(
             decoration: BoxDecoration(shape: BoxShape.rectangle,
               color: Colors.purple,
               borderRadius:  BorderRadius.circular(5),
             ),
             height: 50,
             width: 150,
            /* color: Colors.orange,*/),
          SizedBox(height: 5,),
          Text(
            '$text$format',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 5,),
          Row(children: [
            LikeButtonWidget(widget.post.postId,widget.likedBy,widget.post.userId,),
            const SizedBox(width: 50,),
            CommentButton(widget.post.postId,widget.post.name,widget.post.userId,widget.commentCount,widget.user.id)
          ],)
      ],),
    );
  }
}
