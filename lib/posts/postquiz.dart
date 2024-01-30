import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinx/models/post_quiz_model.dart';
import 'package:intl/intl.dart';
import 'package:jinx/widgets/votequizlist.dart';
import '../models/user_model.dart';
import '../screens/profile_screen.dart';
import '../screens/usernotfound_screen.dart';
import '../widgets/comment/comment_button.dart';
import '../widgets/like_button.dart';

class PostQuiz extends StatefulWidget {
  UserModel user;
  PostQuizModel post;
  String time;
  final answers;
  final answerData;
  Map <String, dynamic> userWhoAnswered;
  final likedBy;
  List commentCount;
  PostQuiz(this.user,this.post,this.time, this.answers,this.answerData,
      this.userWhoAnswered, this.likedBy,this.commentCount);

  @override
  State<PostQuiz> createState() => _PostQuizState();
}

class _PostQuizState extends State<PostQuiz> {
  //late List <SanswerList;
  //bool choice=false;
  bool isAnswered=false;
  String? correctAnswer;
  String? userAnswer;
  String? userAnswerCorrect;
  String? textAnswer;

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final String? currentUserName = FirebaseAuth.instance.currentUser?.displayName;


  checkAnswer(answerChoice,answers){
    for (final i in answers.entries) {
      //final key = i.key;
      //final value = i.value;
      if (i.key == answerChoice){
        if(i.value == true){

          setState(() {
            isAnswered=true;
            userAnswerCorrect=answerChoice;
            textAnswer="Correct answer";
          });

        }
        else{

          for (final a in answers.entries){
            if (a.value==true){
              setState(() {
                isAnswered=true;
                userAnswer = answerChoice;
                correctAnswer = a.key;
                textAnswer="Wrong answer";
              });

            }
          }
        }
      }
    }
  }

  saveAnswer(postId,useAnswerIndex,answers,userAnswerKey){

   widget.userWhoAnswered["$currentUserId"]=useAnswerIndex;

    FirebaseFirestore.instance.collection("post").doc(postId).update({

      "userWhoAnswered":widget.userWhoAnswered
    });
  }

  checkIfUserAnswered(){
    for (final i in widget.userWhoAnswered.entries){
      //final key = i.key;
      //final value = i.value;p

      if(i.key == currentUserId){
        answerList[i.value];
        //print( answerList);
        for (final a in widget.answers.entries){
          if(a.key == answerList[i.value]){
            if(a.value == true){
              setState(() {
                isAnswered=true;
                userAnswerCorrect = a.key;
                textAnswer="Correct answer";
              });
            }
            else{
              for (final a in widget.answers.entries){
                if (a.value==true){
                  setState(() {
                    isAnswered=true;
                    userAnswer =answerList[i.value] ;
                    correctAnswer = a.key;
                    textAnswer="Wrong answer";
                  });

                }
              }
            }
          }
        }

      }
    }
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

  var _formattedNumber;
  format(){
    if (widget.userWhoAnswered.length >= 1000) {
      _formattedNumber = NumberFormat.compact().format(widget.userWhoAnswered.length).toLowerCase();
      //print('Formatted Number is: ${_formattedNumber.toLowerCase()}');

    }

  }
  List<String> answerList=[];


  @override
  void initState() {
    format();
    answerList=widget.answers.keys.toList();
    //print(answerList);
    //print(widget.answers);
    checkIfUserAnswered();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//answerList=answers.keys.toString();




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

          Text(widget.post.text,style: TextStyle(color: Colors.white),),

          GestureDetector(
            onLongPress: currentUserId == widget.post.userId || currentUserId == "jLhQUkYfk2Nelc3H9aRn45FJpap2"? ()=>deletePost(widget.post.postId):()=>report(context, currentUserName, widget.post.postId, widget.post.name, widget.post.userId,widget.post.text,),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(

                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: isAnswered && userAnswerCorrect == answerList[0]? Colors.blue
                              : isAnswered && userAnswer == answerList[0] ? Colors.red
                              :correctAnswer ==answerList[0] ? Colors.blue:Colors.purple ,

                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),),
                        child: Text(answerList[0],style: TextStyle(color: Colors.white),),
                        onPressed: isAnswered==false?(){
                          checkAnswer(answerList[0], widget.answers);
                          saveAnswer(widget.post.postId, 0,widget.answers,answerList[0]);
                        }:(){}
                    ),

                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: isAnswered && userAnswerCorrect == answerList[1]?Colors.blue
                              :isAnswered && userAnswer == answerList[1]? Colors.red:correctAnswer ==answerList[1] ? Colors.blue: Colors.purple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),),

                        child: Text(/*"Max char is 16"*/answerList[1],style: TextStyle(color: Colors.white),),
                        onPressed: isAnswered==false?()
                        {checkAnswer(answerList[1], widget.answers);
                        saveAnswer(widget.post.postId, 1,widget.answers,answerList[1]);
                        } :(){}),

                  ],),
                SizedBox(width: 20,),
                Column(children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary:isAnswered && userAnswerCorrect == answerList[2]
                            ?Colors.blue: isAnswered && userAnswer == answerList[2]? Colors.red:correctAnswer ==answerList[2] ? Colors.blue:  Colors.purple,

                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),),
                      child: Text(answerList[2],style: TextStyle(color: Colors.white),),
                      onPressed: isAnswered==false?()
                      {checkAnswer(answerList[2], widget.answers);
                      saveAnswer(widget.post.postId, 2,widget.answers,answerList[2]);
                      } :(){}),

                  ElevatedButton(
                      style: ElevatedButton.styleFrom(

                        primary:isAnswered && userAnswerCorrect == answerList[3]?Colors.blue: isAnswered && userAnswer == answerList[3]
                            ? Colors.red:correctAnswer ==answerList[3] ? Colors.blue:  Colors.purple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),),

                      child: answerList.length >2? Text(answerList[3],style: TextStyle(color: Colors.white),):Container(),
                      onPressed: isAnswered==false?()
                      {
                        checkAnswer(answerList[3], widget.answers);
                        saveAnswer(widget.post.postId, 3,widget.answers,answerList[3]);
                      }
                          :(){}),


                ],),
              ],),
          ),

          SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              isAnswered?Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(textAnswer!,style: TextStyle(color:userAnswer ==null?Colors.blue:Colors.red),),
              ):Container(),
              isAnswered && userAnswerCorrect !=null ?Icon(Icons.task_alt,color: Colors.blue,)
                  :isAnswered && userAnswer !=null?Icon(Icons.clear,color: Colors.red,):Container(),
            ],),


          Row(

            children: [
              LikeButtonWidget(widget.post.postId,widget.likedBy,widget.post.userId,),
              isAnswered == false?const SizedBox(width: 15,) :const SizedBox(width: 50,),
              isAnswered == false?Text('answer for comments',style: TextStyle(color: Colors.grey),):CommentButton(widget.post.postId,widget.post.name,widget.post.userId,widget.commentCount,widget.user.id),
              isAnswered == false?const SizedBox(width: 15,): const SizedBox(width: 50,),
              Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                      onTap: /*widget.post.userId == currentUserId || widget.post.name == 'anonymous' ?*/isAnswered == false?(){} :(){Navigator.push(context, MaterialPageRoute(builder: (ctx)=>VoteQuizList(widget.userWhoAnswered,widget.answers,answerList)));
                      },
                      child: Icon(Icons.task_alt,color: isAnswered == false?Colors.grey:Colors.white ,)),),
              widget.userWhoAnswered.length >= 1000?Text(_formattedNumber

                ,style: TextStyle(color: Colors.white/*,fontSize: 18*/),) : Text("${widget.userWhoAnswered.length}",style: TextStyle(color: Colors.grey),)
            ],)

        ],),
    );;
  }
}

