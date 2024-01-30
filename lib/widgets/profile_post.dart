import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinx/models/user_model.dart';
import 'package:jinx/screens/profilepostviews/pollview.dart';
import 'package:jinx/screens/profilepostviews/quizview.dart';

import '../models/post_guess_model.dart';
import '../models/post_model.dart';
import '../models/post_quiz_model.dart';
import '../posts/postguess.dart';
import '../posts/postpoll.dart';
import '../posts/postquiz.dart';
import '../screens/postviews/postviewguess.dart';
import '../screens/postviews/postviewpoll.dart';
import '../screens/postviews/postviewquiz.dart';

class ProfilePost extends StatelessWidget {
  UserModel userModel;
  ProfilePost(this.userModel);

 // @override
  //State<ProfilePost> createState() => _ProfilePostState();
//}

//class _ProfilePostState extends State<ProfilePost> {

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final String? currentUserName =
      FirebaseAuth.instance.currentUser?.displayName;
  final String? currentUserphoto = FirebaseAuth.instance.currentUser?.photoURL;

  List<String> answerList=[];
  var formattedTime;
  getTimeDifferenceFromNow(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 5) {
     return formattedTime= "Just now";
    } else if (difference.inMinutes < 1) {
     return formattedTime= "${difference.inSeconds}s ago";
    } else if (difference.inHours < 1) {
     return formattedTime= "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
     return formattedTime= "${difference.inHours}h ago";
    } else {
     return formattedTime= "${difference.inDays}d ago";
    }
  }

  report (context,reportedBy,postId,postOwner,postownerId,text,image )async{
    showDialog(context: context, builder: (context){return AlertDialog(

        title: Text('Report message',style:TextStyle(color:Colors.red )),
        content: Text('are you sure you want to report this message?'),
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
                  'image':image


                });


                Navigator.of(context).pop();
                showDialog(context: context, builder: (context){return AlertDialog(content: Text("Report sent",style: TextStyle(color: Colors.purple),),);});
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

  deletePost(postId,context){
    showDialog(context: context, builder: (context){return AlertDialog(

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
                showDialog(context: context, builder: (context){return AlertDialog(content: Text("Post Deleted",style: TextStyle(color: Colors.purple),));});
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('post')
          .where('userId', isEqualTo: userModel.id).orderBy('time',descending: true)
          .snapshots(),
      builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
     if(snapshot.hasData) {
       final postDocs = snapshot.data!.docs;
       return ListView.builder(
         key: PageStorageKey<String>('profilePost'),
         physics: NeverScrollableScrollPhysics(),
         shrinkWrap: true,
         itemCount: postDocs.length,
         itemBuilder: (context, index) {
          if(postDocs[index]['anonymous'] == false) {
                switch (postDocs[index]['type']) {
                  case 'pp':
                    DateTime dateTime = DateTime.parse(
                        postDocs[index]['time'].toDate().toString());
                    getTimeDifferenceFromNow(dateTime);
                    final post = PostModel(
                      name: postDocs[index]['name'],
                      userId: postDocs[index]['userId'],
                      photo: postDocs[index]['photo'],
                      anonymous: postDocs[index]['anonymous'],
                      //time: postDocs[index]['time'],
                      postImage: postDocs[index]['postImage'],
                      type: postDocs[index]['type'],
                      postId: postDocs[index]['postId'],
                      createdBy: postDocs[index]['createdBy'],
                      option1: postDocs[index]['option1'],
                      option2: postDocs[index]['option2'],
                      option3: postDocs[index]['option3'],
                      text: postDocs[index]['text'],
                      poll: postDocs[index]['poll'],
                      option1P: postDocs[index]["option1P"] + .0,
                      option2P: postDocs[index]["option2P"] + .0,
                      option3P: postDocs[index]["option3P"] + .0,
                      //userWhoVoted: postDocs[index]["userWhoVoted"]
                    );

                    Map<String, int> converted = {};
                    var st = postDocs[index]["userWhoVoted"];
                    for (final mapEntry in st.entries) {
                      final key = mapEntry.key;
                      final value = mapEntry.value;
                      converted[key] = value;
                    }
                    return GestureDetector(
                      onLongPress: currentUserId == postDocs[index]['userId'] ||
                              currentUserId == "jLhQUkYfk2Nelc3H9aRn45FJpap2"
                          ? () => deletePost(postDocs[index]['postId'], context)
                          : () => report(
                              context,
                              currentUserName,
                              postDocs[index]['postId'],
                              post.name,
                              post.userId,
                              post.text,
                              post.postImage),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PollView(
                                  post,
                                  getTimeDifferenceFromNow(dateTime),
                                  converted,
                                  postDocs[index]["likedBy"],
                                  postDocs[index]['commentCount'],
                                  userModel))),
                      child: Card(
                          color: Colors.black,
                          shadowColor: Colors.purple,
                          elevation: 30,
                          child: PostPoll(
                              post,
                              formattedTime,
                              converted,
                              postDocs[index]["likedBy"],
                              postDocs[index]['commentCount'],
                              userModel)),
                    );

                  case 'pq':
                    DateTime dateTime = DateTime.parse(
                        postDocs[index]['time'].toDate().toString());
                    getTimeDifferenceFromNow(dateTime);
                    final postQuiz = PostQuizModel(
                      name: postDocs[index]['name'],
                      userId: postDocs[index]['userId'],
                      photo: postDocs[index]['photo'],
                      postId: postDocs[index]['postId'],
                      text: postDocs[index]['text'],
                      createdBy: postDocs[index]['createdBy'],
                      type: postDocs[index]['type'],
                    );
                    var answers = postDocs[index]["answers"];
                    Map<String, dynamic> converted = {};

                    for (final mapEntry in answers.entries) {
                      final key = mapEntry.key;
                      final value = mapEntry.value;
                      converted[key] = value;
                      answerList.add(key);
                    }

                    return GestureDetector(
                      onLongPress: currentUserId == postDocs[index]['userId'] ||
                              currentUserId == "jLhQUkYfk2Nelc3H9aRn45FJpap2"
                          ? () => deletePost(postDocs[index]['postId'], context)
                          : () => report(
                              context,
                              currentUserName,
                              postDocs[index]['postId'],
                              postQuiz.name,
                              postQuiz.userId,
                              postQuiz.text,
                              ''),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QuizView(
                                  userModel,
                                  postQuiz,
                                  getTimeDifferenceFromNow(dateTime),
                                  converted,
                                  postDocs[index]['userWhoAnswered'],
                                  postDocs[index]["likedBy"],
                                  postDocs[index]["commentCount"]))),
                      child: Card(
                          color: Colors.black,
                          shadowColor: Colors.purple,
                          elevation: 30,
                          child: PostQuiz(
                              userModel,
                              postQuiz,
                              formattedTime,
                              converted,
                              answerList,
                              postDocs[index]['userWhoAnswered'],
                              postDocs[index]["likedBy"],
                              postDocs[index]["commentCount"])),
                    );

                  case 'pg':
                    DateTime dateTime = DateTime.parse(
                        postDocs[index]['time'].toDate().toString());
                    DateTime expireTime = DateTime.parse(
                        postDocs[index]['expireDate'].toDate().toString());
                    getTimeDifferenceFromNow(dateTime);
                    final postGuess = PostGuessModel(
                        name: postDocs[index]['name'],
                        userId: postDocs[index]['userId'],
                        photo: postDocs[index]['photo'],
                        postId: postDocs[index]['postId'],
                        text: postDocs[index]['text'],
                        createdBy: postDocs[index]['createdBy'],
                        type: postDocs[index]['type'],
                        secretWord: postDocs[index]['secretWord']);

                    return GestureDetector(
                      onLongPress: currentUserId == postDocs[index]['userId'] ||
                              currentUserId == "jLhQUkYfk2Nelc3H9aRn45FJpap2"
                          ? () => deletePost(postDocs[index]['postId'], context)
                          : () => report(
                              context,
                              currentUserName,
                              postDocs[index]['postId'],
                              postGuess.name,
                              postGuess.userId,
                              postGuess.text,
                              ''),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostViewGuess(
                                  userModel,
                                  postGuess,
                                  getTimeDifferenceFromNow(dateTime),
                                  expireTime,
                                  postDocs[index]["likedBy"],
                                  postDocs[index]['commentCount']))),
                      child: Card(
                          color: Colors.black,
                          shadowColor: Colors.purple,
                          elevation: 30,
                          child: PostGuess(
                              userModel,
                              postGuess,
                              formattedTime,
                              expireTime,
                              postDocs[index]["likedBy"],
                              postDocs[index]['commentCount'])),
                    );
                }
              }
              return Container();
         },
       );
     }
     return Container();
      },
    );
  }
}
