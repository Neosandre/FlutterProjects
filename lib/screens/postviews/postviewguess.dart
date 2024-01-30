import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinx/models/post_guess_model.dart';
import 'package:jinx/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:jinx/widgets/comment/comments.dart';
import '../../widgets/comment/comment_button.dart';
import '../../widgets/like_button.dart';
import '../profile_screen.dart';
import '../usernotfound_screen.dart';

class PostViewGuess extends StatefulWidget {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  UserModel user;
  PostGuessModel post;
  final time;
  final expireTime;
  final likedBy;
  List commentCount;
  PostViewGuess(
      this.user,
      this.post,
      this.time,
      this.expireTime,
      this.likedBy,
      this.commentCount
      );

  @override
  State<PostViewGuess> createState() => _PostViewGuessState();
}

class _PostViewGuessState extends State<PostViewGuess> {


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

  final _controller = TextEditingController();

  var _enteredMessage = '';

  bool hasFocus=false;

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final String? currentUserName = FirebaseAuth.instance.currentUser?.displayName;
  final commentRef= FirebaseFirestore.instance.collection('comment');



  dynamic _postId;

  Random _rnd = Random();

  String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(length, (_) => PostViewGuess._chars.codeUnitAt(_rnd.nextInt( PostViewGuess._chars.length))));

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

    _controller.clear();
    _enteredMessage='';
  }

  report (context,reportedBy,postId,postOwner,postownerId,text, )async{
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



  @override
  void initState() {
    print("liked by ini ${widget.likedBy}");
    print("coment by ini ${widget.commentCount}");

    format=fomatexp(widget.expireTime);
    showFunction(widget.expireTime);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,

      
      ),
      body: GestureDetector(
        onLongPress: currentUserId == widget.user.id || currentUserId == "jLhQUkYfk2Nelc3H9aRn45FJpap2"? ()=>deletePost(widget.post.postId):()=>report(context, currentUserName, widget.post.postId, widget.post.name, widget.post.userId,widget.post.text,),

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
            ///Change from here //////
            Text(widget.post.text,style: TextStyle(color: Colors.white),),
            SizedBox(height: 5,),
            show ==true? Container(child: Text(widget.post.secretWord,style: TextStyle(color: Colors.purple,fontSize: 30,fontWeight: FontWeight.bold),),)
                :Container(
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
            ///change from here
            SizedBox(height: 5,),
            Row(children: [
              LikeButtonWidget(widget.post.postId,widget.likedBy,widget.post.userId,),
              const SizedBox(width: 50,),
           ///here here
           Icon(Icons.comment,color: Colors.white,size: 25,),
              SizedBox(width: 10,),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text("${widget.commentCount.length}"

                  ,style: TextStyle(color: Colors.white/*,fontSize: 18*/),),
              ),
              ///here here
              //CommentButton(widget.post.postId,widget.post.name,widget.post.userId,widget.commentCount,widget.user.id)
            ],),
            Divider(color: Colors.purple,),
            Expanded(
              child: Container(
                  padding: EdgeInsets.only(
                      left: 5, right: 5, top: 5, ),
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.6,
                  width: double.infinity,
                  child: GestureDetector(onTap:(){ FocusScope.of(context).requestFocus(new FocusNode());},
                      //Note: storyFile is actually storyId
                      child:  Comments(widget.post.postId,)
                  )
              ),
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
          hasFocus=true;
          _enteredMessage = value;

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
      ),
    );
  }
}
