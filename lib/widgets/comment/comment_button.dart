import 'dart:math';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinx/models/user_model.dart';

import 'comments.dart';

class CommentButton extends StatefulWidget {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final postId;
  final name;
  //final photo;
  final postOwnerId;
  List commentCount;
  final userId;
   CommentButton(this.postId,this.name,/*this.photo,*/this.postOwnerId,this.commentCount,this.userId);

  @override
  State<CommentButton> createState() => _CommentButtonState();
}

class _CommentButtonState extends State<CommentButton> {
  TextEditingController _controller = TextEditingController();

  //var _enteredMessage;

  bool hasFocus=false;
  //int countLocal=0;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  final commentRef= FirebaseFirestore.instance.collection('comment');



    Random _rnd = Random();

    String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => CommentButton._chars.codeUnitAt(_rnd.nextInt(CommentButton._chars.length))));

  void _sendMessage({ context}) async {
   /* setState(() {
      countLocal ++;
    });*/
    FocusScope.of(context).unfocus();
    var commentId=getRandomString(10);
    widget.commentCount.add(currentUserId);

    //1f this substitute the FutureBuilder in message_bubble
    final userData = await FirebaseFirestore.instance.collection('users').doc(
        currentUserId).get();

    FirebaseFirestore.instance.collection('comments').doc(commentId).set({
      'text': _controller.text.trim(),
      'time': Timestamp.now(),
      'userId': currentUserId,
      'name': userData['name'],
      'photo': userData['photo'],
      'postOwnerName':widget.name ,
      'postOwnerId': widget.postOwnerId,
      'postId': widget.postId,
      'commentId':commentId,

    }).then((value) {FirebaseFirestore.instance.collection('post').doc(widget.postId).update({'commentCount':widget.commentCount});});

    if(currentUserId != widget.postOwnerId){
     await FirebaseFirestore.instance
          .collection('feed')
          .doc(widget.postOwnerId)
          .collection('feedItems')
          /*.doc(currentUserId)*/ .add({
        'type': 'comment',
        'uuid': currentUserId,
        'name': userData['name'],
        'photo': userData['photo'],
        'timestamp': DateTime.now(),
        'channel': '',
        'selected': false,
        'postId':widget.postId
      });
    }

     _controller.clear();

  }

  _commentsList(/*storyCaption,storyId, storyOwnerName, storyOwnerId,*/ context) async {
    //storyId = storyId;
    await showModalBottomSheet(
      //constraints: BoxConstraints.expand(),
        backgroundColor: /*Color(0xfff1efe5)*/Colors.black,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('close keyboard to send comment',style: TextStyle(color: Colors.purple),),
              Container(
                  padding: EdgeInsets.only(
                      left: 5, right: 5, top: 5,),
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.4,
                  width: double.infinity,
                  child: GestureDetector(onTap:(){ FocusScope.of(context).requestFocus(new FocusNode());},
                    //Note: storyFile is actually storyId
                    child:  Comments(widget.postId,)
                  )
              ),


              Container(
                padding: EdgeInsets.only(bottom: MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                          margin: EdgeInsets.only(left: 5, right: 2, bottom: 20),
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

                               /* setState(() {
                                 // _enteredMessage = value;
                                  hasFocus=true;
                                });*/

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
                            onPressed: /*_controller.text.length <=0?null:*/ ()
                            {
                              if(_controller.text.length <=0){return print('empty');}
                            _sendMessage(
                            /*storyCaption:storyCaption,
                                storyId: storyId,
                                storyOwnerName: storyOwnerName,
                                storyOwnerId: storyOwnerId,*/
                            context: context

                            );
                        }

                        )),
                      ),
                    ),
                  ],
                ),
              )

            ],
          );
        }
    );
  }
/*var c=0;
  countComment()async{
   QuerySnapshot l= await FirebaseFirestore.instance.collection('comments').where('postId',isEqualTo: widget.postId).get();

    setState(() {
      c=l.docs.length;
    });
   //return l.docs.length;
  }*/
  var _formattedNumber;
  format(){
    if (widget.commentCount.length >= 1000) {
   _formattedNumber = NumberFormat.compact().format(widget.commentCount.length).toLowerCase();
  //print('Formatted Number is: ${_formattedNumber.toLowerCase()}');

  }

  }


  @override
  void initState() {
    format();
    //countLocal = widget.commentComment.length;
    //countComment();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
      InkWell(
          onTap: () { _commentsList(context );}
          ,
          child: Ink(child: Icon(Icons.comment,color: Colors.white,size: 25,),)),
      SizedBox(width: 10,),
      Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child:widget.commentCount.length >= 1000?Text(_formattedNumber

    ,style: TextStyle(color: Colors.white/*,fontSize: 18*/),) :Text("${widget.commentCount.length}"

          ,style: TextStyle(color: Colors.white/*,fontSize: 18*/),),
      ),
      //const SizedBox(width: 15,),

      /*InkWell(
          onTap: (){},
          child: Ink(child: Icon(Icons.share_outlined,color: Colors.white,size: 25,),)),*/
     /* GestureDetector(
          onTap: (){},
          child: Ink(child: Icon(*//*Icons.more_horiz*//*Icons.arrow_drop_down_outlined,color: Colors.white,size: 25,),)),*/

    ],);
  }
}
