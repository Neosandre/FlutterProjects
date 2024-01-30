import 'dart:math';
import 'dart:ui';

import 'package:better_polls/better_polls.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinx/models/post_guess_model.dart';
import 'package:jinx/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:jinx/widgets/comment/comments.dart';
import 'package:jinx/widgets/votelist.dart';
import '../../models/post_model.dart';
import '../../widgets/comment/comment_button.dart';
import '../../widgets/like_button.dart';
import '../feed_screen.dart';
import '../home_screen.dart';
import '../profile_screen.dart';
import '../usernotfound_screen.dart';

class PostViewPoll extends StatefulWidget {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  PostModel post;
  String time;
  final userWhoVoted;
  final likedBy;
  final commentCount;
  UserModel user;
  //final Function updatefeed;
  PostViewPoll(this.post,this.time,this.userWhoVoted,this.likedBy,this.commentCount,this.user/*this.updatefeed*/);


  @override
  State<PostViewPoll> createState() => _PostViewPollState();
}

class _PostViewPollState extends State<PostViewPoll> {


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

  TextEditingController _controller = TextEditingController();

  var _enteredMessage = '';

  bool hasFocus=false;

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  final commentRef= FirebaseFirestore.instance.collection('comment');

  dynamic _postId;

  Random _rnd = Random();

  String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(length, (_) => PostViewPoll._chars.codeUnitAt(_rnd.nextInt( PostViewPoll._chars.length))));

  final String? currentUserName = FirebaseAuth.instance.currentUser?.displayName;
  //final commentRef= FirebaseFirestore.instance.collection('comment');


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




  void _sendMessage({ context}) async {
    FocusScope.of(context).unfocus();
    var commentId=getRandomString(10);
    widget.commentCount.add(currentUserId);

    //1f this substitute the FutureBuilder in message_bubble
    final userData = await FirebaseFirestore.instance.collection('users').doc(
        currentUserId).get();

    FirebaseFirestore.instance.collection('comments').doc(commentId).set({
      'text': _enteredMessage.trim(),
      'time': Timestamp.now(),
      'userId': currentUserId,
      'name': userData['name'],
      'photo': userData['photo'],
      'postOwnerName':widget.user.name,
      'postOwnerId': widget.user.id,
      'postId': widget.post.postId,
      'commentId':commentId,

    }).then((value) {FirebaseFirestore.instance.collection('post').doc(widget.post.postId).update({'commentCount':widget.commentCount});});

    if(currentUserId != widget.post.userId){
      FirebaseFirestore.instance
          .collection('feed')
          .doc(widget.user.id)
          .collection('feedItems')
      /*.doc(currentUserId)*/ .add({
        'type': 'comment',
        'uuid': currentUserId,
        'name': userData['name'],
        'photo': userData['photo'],
        'timestamp': DateTime.now(),
        'channel': '',
        'selected': false,
      });
    }

      //_controller ='';

      _controller.clear();
  _enteredMessage='';



  }


  report (context,reportedBy,postId,postOwner,postownerId,text,postViewImage )async{
    showDialog(context: context, builder: (context){return AlertDialog(
        backgroundColor: Color(0xfff1efe5),
        title: Text('Report post',style:TextStyle(color:Colors.red )),
        content: Text('are you sure you want to report this post?'),
        actions: [
          TextButton(
              child: Text(
                'Yes',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              onPressed:  ()async{

                await FirebaseFirestore.instance.collection('reports').doc(postId).collection('details').doc(currentUserId).set({
                  'reportedTime':DateTime.now(),
                  'reportedById':currentUserId,
                  'reportedBy':reportedBy,
                  'postId':postId,
                  'postOwner':postOwner,
                  'postOwnerId':postownerId,
                  'text':text,
                  'image':postViewImage,
                  'type':'post',



                });


                Navigator.of(context).pop();
                showDialog(context: context, builder: (context){return AlertDialog(
                    backgroundColor:Color(0xfff1efe5) ,
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

  deletePost(postId){
    showDialog(context: context, builder: (context){return AlertDialog(
        backgroundColor: Color(0xfff1efe5),

        title: Text('Delete Post',style:TextStyle(color:Colors.red )),
        content: Text('are you sure you want to delete this post?'),
        actions: [
          TextButton(
              child: Text(
                'Yes',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              onPressed:  ()async{
                await FirebaseFirestore.instance.collection('post').doc(postId).delete();
                Navigator.of(context).pop();
                showDialog(context: context, builder: (context){return AlertDialog(
                    backgroundColor:Color(0xfff1efe5),
                    content: Text("Post Deleted",style: TextStyle(color: Colors.purple),));});
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
  formatt(){
    if (widget.userWhoVoted.length >= 1000) {
      _formattedNumber = NumberFormat.compact().format(widget.userWhoVoted.length).toLowerCase();
      //print('Formatted Number is: ${_formattedNumber.toLowerCase()}');

    }

  }
  @override
  void initState() {
    update();
    formatt();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
          leading: IconButton(
              icon: new Icon(Icons.arrow_back_ios),
              onPressed: () async {
                Navigator.pushReplacement(context, PageRouteBuilder(
                    pageBuilder: (a, b, c) =>
                        HomeScreen(widget.user,'feedScreen'),
                    transitionDuration: Duration(seconds: 10)));
              }),

      ),
      body: ListView(
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
              GestureDetector(
                onTap: ()async{
                  await _getAllUsers(widget.post.userId);
                  sendToUserProfile();
                },
                child: Column(
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
                  ],),
              )
            ],),
          ),
          ///Change from here //////
          widget.post.postImage != null? SizedBox(height: 5,):Container(),
          widget.post.postImage != null? GestureDetector(
            onLongPress: currentUserId == widget.post.userId || currentUserId == "jLhQUkYfk2Nelc3H9aRn45FJpap2"? ()=>deletePost(widget.post.postId):()=>report(context, currentUserName, widget.post.postId, widget.post.name, widget.post.userId,widget.post.text,widget.post.postImage),

            child: ClipRRect(
              child:CachedNetworkImage(

                imageUrl: widget.post.postImage!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Text("loading...",style: TextStyle(color: Colors.grey),),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              borderRadius: BorderRadius.circular(20),

            ),
          ):Container(),
          Container(
            //height: 200,
            //width: 200,
            padding: EdgeInsets.all(10),
            child: GestureDetector(
              onLongPress: currentUserId == widget.post.userId || currentUserId == "jLhQUkYfk2Nelc3H9aRn45FJpap2"? ()=>deletePost(widget.post.postId):()=>report(context, currentUserName, widget.post.postId, widget.post.name, widget.post.userId,widget.post.text,widget.post.postImage),

              child: Polls(

                question: Text(
                  "${widget.post.text}",style: TextStyle(color: Colors.white),),
                outlineColor: Colors.purple,


                children: [
                  // This cannot be less than 2, else will throw an exception
                  if(widget.post.option1 != "")Polls.options(title: "${widget.post.option1}", value: option1),
                  if(widget.post.option2 != "")Polls.options(title: "${widget.post.option2}", value: option2),
                  //if(widget.post.option3 != "") Polls.options(title: "${widget.post.option3}", value: option3),

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
              ),
            ),
          ),
          ///change from here
          SizedBox(height: 5,),
          Row(children: [
            LikeButtonWidget(widget.post.postId,widget.likedBy,widget.post.userId,/*(){}*/),
            const SizedBox(width: 50,),
            Icon(Icons.comment,color: Colors.white,size: 25,),
            SizedBox(width: 10,),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text("${widget.commentCount.length}"

                ,style: TextStyle(color: Colors.white/*,fontSize: 18*/),),
            ),
            SizedBox(width: 50,),
            widget.post.poll ==true?
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: /*currentUserId != widget.post.userId?*/GestureDetector(
                onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (ctx)=>VoteList(widget.userWhoVoted,widget.post.option1,widget.post.option2,))),
                child: Icon(Icons.task_alt,color: Colors.white,),)
                  /*:Icon(Icons.task_alt,color: Colors.grey,)*/,
            ):Container(),
            widget.userWhoVoted.length >= 1000 && widget.post.poll ==true?Text(_formattedNumber

              ,style: TextStyle(color: Colors.white/*,fontSize: 18*/),) :widget.post.poll ==true? Text("${widget.userWhoVoted.length}",style: TextStyle(color: Colors.grey),):Container()

            //CommentButton(widget.post.postId,widget.post.name,widget.post.userId,widget.commentCount,widget.user.id)
          ],),
          Divider(color: Colors.purple,),
          Container(
              padding: EdgeInsets.only(
                left: 5, right: 5, top: 5, ),
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.6,
              width: double.infinity,
              child: GestureDetector(onTap:(){ FocusScope.of(context).requestFocus(new FocusNode());},
                  //Note: storyFile is actually storyId
                  child:  Comments(widget.post.postId,),

              )
          ),

          Row(
            children: [
              Expanded(
                child: Card(
                    margin: EdgeInsets.only(left: 5, right: 2,bottom: 20 ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextFormField(
                        autocorrect: false,
                        cursorColor: Colors.purple,
                        controller: _controller,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        minLines: 1,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'say something...',
                          //prefixIcon:Icon(Icons.emoji_emotions) ,

                          //contentPadding: EdgeInsets.all(5)
                        ),
                        onChanged: (value) {

                          setState(() {
                            _enteredMessage = value;
                            hasFocus=true;
                          });
                        },
                      ),
                    )
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 20),
                margin: EdgeInsets.all(3),
                child: CircleAvatar(
                  backgroundColor: Colors.purple,
                  radius: 20,
                  child: Center(child: IconButton(icon: Icon(
                    Icons.send, color: Colors.white,),
                      onPressed: _enteredMessage.trim().isEmpty ? null : ()=>_sendMessage(
                        /*storyCaption:storyCaption,
                                storyId: storyId,
                                storyOwnerName: storyOwnerName,
                                storyOwnerId: storyOwnerId,*/
                          context: context

                      )

                  )),
                ),
              ),
            ],
          ),

        ],),
    );
  }
}
