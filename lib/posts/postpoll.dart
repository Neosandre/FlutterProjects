import 'package:better_polls/better_polls.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinx/models/user_model.dart';
import 'package:jinx/widgets/votelist.dart';
import '../models/post_model.dart';
import '../screens/profile_screen.dart';
import '../screens/usernotfound_screen.dart';
import '../widgets/comment/comment_button.dart';
import '../widgets/like_button.dart';
import 'package:intl/intl.dart';

class PostPoll extends StatefulWidget {
  PostModel post;
  String time;
  final userWhoVoted;
  final likedBy;
  final commentCount;
  UserModel user;
  //final Function updatefeed;
  PostPoll(this.post,this.time,this.userWhoVoted,this.likedBy,this.commentCount,this.user/*this.updatefeed*/);

  @override
  State<PostPoll> createState() => _PostPollState();
}

class _PostPollState extends State<PostPoll> {

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;


  //late Map<String, int> usersWhoVoted;
  String creator = "eddy@mail.com";
  var user;
  var option1;
  var option2;
  var option3;
  late Map<String, int> usersWhoVoted;
  update(){

    user = currentUserId;
     usersWhoVoted = widget.userWhoVoted;
     option1 = widget.post.option1P;
    option2 = widget.post.option2P;
     option3 = widget.post.option3P;
  }


 /* Map<String, int> usersWhoVoted = {
    'sam@mail.com': 1,
    'mike@mail.com': 1,
    'john@mail.com': 1,
    'kenny@mail.com': 1,
    "king@mail.com":1
  };*/

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

  var _formattedNumber;
  format(){
    if (widget.userWhoVoted.length >= 1000) {
      _formattedNumber = NumberFormat.compact().format(widget.userWhoVoted.length).toLowerCase();
      //print('Formatted Number is: ${_formattedNumber.toLowerCase()}');

    }

  }

  @override
  void initState() {
    format();
    update();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {



    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        GestureDetector(
          onTap: ()async{
            await _getAllUsers(widget.post.userId);
            sendToUserProfile();
          },
          child: Row(children: [
           widget.post.name == 'anonymous'?Container(
               width: 40.0,
               height: 40.0,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 image: DecorationImage(
                     image: AssetImage('assets/defaultprofile.jpeg'), fit: BoxFit.cover),
               )):CachedNetworkImage(
              imageUrl: widget.post.photo,
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
        widget.post.postImage != null? SizedBox(height: 5,):Container(),
        widget.post.postImage != null? ClipRRect(
          child:CachedNetworkImage(

          imageUrl: widget.post.postImage!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Text("loading...",style: TextStyle(color: Colors.grey),),
           errorWidget: (context, url, error) => Icon(Icons.error),
      ),
          borderRadius: BorderRadius.circular(20),

        ):Container(),
        Container(
          //height: 200,
          //width: 200,
          padding: EdgeInsets.all(10),
          child:  widget.post.poll == true? Polls(

            question: Text(
                "${widget.post.text}",style: TextStyle(color: Colors.white),),
            outlineColor: Colors.purple,


            children: [
              // This cannot be less than 2, else will throw an exception
             Polls.options(title: "${widget.post.option1}", value: option1),
              Polls.options(title: "${widget.post.option2}", value: option2),
              //if(widget.post.option3. != "") Polls.options(title: "${widget.post.option3}", value: option3),

            ],

            currentUser: user,
            creatorID: creator,
            voteData: usersWhoVoted,
            userChoice: usersWhoVoted[user],
            onVoteBackgroundColor: Colors.purple,
            leadingBackgroundColor: Colors.purple,
            backgroundColor: Colors.black,


            onVote: (choice)async{

              setState(() {
                usersWhoVoted[user] = choice;
              });
              if (choice == 0) {
                setState(() {
                 option1 += 1.0;

                });
                print(option1);
                usersWhoVoted["$currentUserId"]=0;
                await FirebaseFirestore.instance
                    .collection('post').doc(widget.post.postId).update({
                   'option1P': option1,
                  'userWhoVoted': usersWhoVoted

                 });

              }
              if (choice ==1) {
                setState(() {
                  option2 += 1.0;

                });
                usersWhoVoted["$currentUserId"]=1;
                await FirebaseFirestore.instance
                    .collection('post').doc(widget.post.postId).update({
                  'option2P': option2,
                  'userWhoVoted':usersWhoVoted
                });

              }
              if ((widget.post.option3 != "") && choice == 2) {
                setState(() {
                  option3 += 1.0;

                });
                usersWhoVoted["$currentUserId"]=2;
                await FirebaseFirestore.instance
                    .collection('post').doc(widget.post.postId).update({
                  'option3P': option3,
                  'userWhoVoted':{usersWhoVoted}
                });
              }


            },
          ):Text("${widget.post.text}",style: TextStyle(color: Colors.white),),
        ),
        //SizedBox(height: 5,),
        Row(children: [
          LikeButtonWidget(widget.post.postId,widget.likedBy,widget.post.userId,),
          const SizedBox(width: 50,),
          CommentButton(widget.post.postId,widget.post.name,widget.post.userId,widget.commentCount,widget.user.id),
          SizedBox(width: 50,),
         widget.post.poll ==true? Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
                onTap: /*widget.post.userId == currentUserId || widget.post.name == 'anonymous'?*/(){
                  Navigator.push(context, MaterialPageRoute(builder: (ctx)=>VoteList(usersWhoVoted, widget.post.option1, widget.post.option2)));
                },
                child: Icon(Icons.task_alt,color: /*widget.post.userId == currentUserId || widget.post.name == 'anonymous'?*/Colors.white ,)),
          ):Container(),
          widget.userWhoVoted.length >= 1000 && widget.post.poll ==true?Text(_formattedNumber

            ,style: TextStyle(color: Colors.white/*,fontSize: 18*/),) :widget.post.poll ==true? Text("${widget.userWhoVoted.length}",style: TextStyle(color: Colors.grey),):Container()
        ],)
      ],),
    );

  }
}
