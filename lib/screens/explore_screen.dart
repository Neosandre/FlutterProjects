import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jinx/creation/create_postguess.dart';
import 'package:jinx/creation/create_postquiz.dart';
import 'package:jinx/models/post_guess_model.dart';
import 'package:jinx/models/post_model.dart';
import 'package:jinx/models/post_quiz_model.dart';
import 'package:jinx/models/user_model.dart';
import 'package:jinx/posts/postguess.dart';
import 'package:jinx/posts/postpoll.dart';
import 'package:jinx/posts/postquiz.dart';
import 'package:jinx/screens/chatList_screen.dart';
import 'package:jinx/screens/exploreviews/explorequizview.dart';
import 'package:jinx/screens/home_screen.dart';
import 'package:jinx/screens/postviews/postviewguess.dart';
import 'package:jinx/screens/postviews/postviewpoll.dart';
import 'package:jinx/screens/postviews/postviewquiz.dart';
import 'package:jinx/screens/test.dart';
import 'package:jinx/widgets/delete_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../creation/create_post_screen.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

import 'exploreviews/explorepollview.dart';





class ExploreScreen extends StatefulWidget {
  UserModel user;

  ExploreScreen(this.user);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {


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

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final String? currentUserName =
      FirebaseAuth.instance.currentUser?.displayName;
  final String? currentUserphoto = FirebaseAuth.instance.currentUser?.photoURL;

  List<String> followingList = [];




  report (context,reportedBy,postId,postOwner,postownerId,text,image )async{
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
                  'image':image
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

  //Refreshers
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()


    //  await Future.delayed(Duration(milliseconds: 1500));

    Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (a, b, c) =>
            HomeScreen(widget.user,'exploreScreen'),
        transitionDuration: Duration(seconds: 10)));
    _refreshController.refreshCompleted();
    return Future.value(false);

    //if (mounted) setState(() {});
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

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
              'Not posts...\n',
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
  void initState() {

    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: RichText(
            text: TextSpan(
              style: GoogleFonts.mochiyPopPOne(fontSize: 30),
              children: const <TextSpan>[
                TextSpan(
                    text: 'jin',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                TextSpan(
                    text: 'X',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.purple)),
              ],
            )),
        backgroundColor: Colors.transparent,
        actions: [
          //DeleteButton(),

          PopupMenuButton<int>(
              color:Color(0xfff1efe5) ,
              offset: Offset.zero,
              icon: Icon(
                Icons.add,
                color:  Colors.white ,
              ) ,
              onSelected: (item)=> _onselected(context, item),
              itemBuilder: (context)=>[
                PopupMenuItem(
                  value: 0,
                  child:Text("Post"),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 1,
                  child:Text("Guess"),

                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 2,
                  child:Text("Question"),

                ),

              ])
        ],
      ),
      body:StreamBuilder(
          stream: FirebaseFirestore.instance.collection("post").orderBy('time',descending: true).snapshots(),
          builder: (context,AsyncSnapshot<QuerySnapshot> snapshot ){

            if(snapshot.hasData){
              if (snapshot.data?.docs.length != 0){
                final postDocs=snapshot.data!.docs;
                // if(postDocs.length != 0){}
                return SmartRefresher(

                  controller: _refreshController,
                  onLoading: _onLoading,
                  onRefresh: _onRefresh,
                  enablePullDown: true,
                  enablePullUp: true,
                  footer: ClassicFooter(),
                  header: WaterDropMaterialHeader(
                    backgroundColor: Colors.purple,
                    color: Colors.white,
                  ),
                  child: ListView.builder(
                      key: PageStorageKey<String>('feed'),
                      //shrinkWrap: true,
                      itemCount: postDocs.length,
                      itemBuilder: (ctx, index) {


                        ///allow users to see only posts from users their follow Next Version
                        //if (followingList.contains(postDocs[index]['userId']) ||  postDocs[index]['userId'] == currentUserId  ){
                        switch (postDocs[index]['type']) {
                          case 'pp':
                            DateTime dateTime = DateTime.parse(
                                postDocs[index]['time'].toDate().toString());
                            getTimeDifferenceFromNow(dateTime);

                            final post= PostModel(
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
                              option1P:postDocs[index]["option1P"]+.0,
                              option2P:postDocs[index]["option2P"]+.0,
                              option3P: postDocs[index]["option3P"]+.0,
                              //userWhoVoted: postDocs[index]["userWhoVoted"]
                            );
                            // print(postDocs[index]['option1']);
                            //print(postDocs[index]['option2']);

                            Map<String, int> converted = {};
                            var st=postDocs[index]["userWhoVoted"];
                            for (final mapEntry in st.entries) {
                              final key = mapEntry.key;
                              final value = mapEntry.value;
                              converted[key]=value;

                            }
                            return GestureDetector(
                              onLongPress: currentUserId == postDocs[index]['userId'] || currentUserId == "jLhQUkYfk2Nelc3H9aRn45FJpap2"? ()=>deletePost(postDocs[index]['postId'])
                                  :()=>report(context, currentUserName, postDocs[index]['postId'], post.name, post.userId,post.text,post.postImage),
                              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>ExplorePollView(post,getTimeDifferenceFromNow(dateTime),converted,postDocs[index]["likedBy"],postDocs[index]['commentCount'],widget.user))),

                              child: Card(
                                  color: Colors.black,
                                  shadowColor: Colors.purple,
                                  elevation: 30,
                                  child: PostPoll(post,formattedTime,converted,postDocs[index]["likedBy"],postDocs[index]['commentCount'],widget.user, )
                              ),
                            );

                          case 'pq':
                            DateTime dateTime = DateTime.parse(
                                postDocs[index]['time'].toDate().toString());
                            getTimeDifferenceFromNow(dateTime);
                            final postQuiz= PostQuizModel(
                              name: postDocs[index]['name'],
                              userId: postDocs[index]['userId'],
                              photo: postDocs[index]['photo'],
                              postId: postDocs[index]['postId'],
                              text: postDocs[index]['text'],
                              createdBy: postDocs[index]['createdBy'],
                              type: postDocs[index]['type'],
                            );
                            var answers=postDocs[index]["answers"];
                            Map<String, dynamic> converted = {};

                            for (final mapEntry in answers.entries) {
                              final key = mapEntry.key;
                              final value = mapEntry.value;
                              converted[key]=value;

                              //answerList.add(key);
                              //print(answerList);
                              //print(converted);
                            }

                            //answerList=converted.keys.toList();
                            //print(answerList);



                            return GestureDetector(
                              onLongPress:  currentUserId == postDocs[index]['userId'] || currentUserId == "jLhQUkYfk2Nelc3H9aRn45FJpap2"?()=>deletePost(postDocs[index]['postId']): ()=>report(context, currentUserName, postDocs[index]['postId'], postQuiz.name, postQuiz.userId,postQuiz.text,''),

                              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>ExploreQuizView(widget.user, postQuiz,getTimeDifferenceFromNow(dateTime),converted,postDocs[index]['userWhoAnswered'],postDocs[index]["likedBy"],postDocs[index]["commentCount"]))),

                              child: Card(
                                  color: Colors.black,
                                  shadowColor: Colors.purple ,
                                  elevation: 30,
                                  child: PostQuiz(widget.user, postQuiz,formattedTime,converted,answerList,postDocs[index]['userWhoAnswered'],postDocs[index]["likedBy"],postDocs[index]["commentCount"])),
                            );

                          case 'pg':
                            DateTime dateTime = DateTime.parse(
                                postDocs[index]['time'].toDate().toString());
                            DateTime expireTime = DateTime.parse(postDocs[index]['expireDate'].toDate().toString());
                            getTimeDifferenceFromNow(dateTime);
                            final postGuess= PostGuessModel(
                                name: postDocs[index]['name'],
                                userId: postDocs[index]['userId'],
                                photo: postDocs[index]['photo'],
                                postId: postDocs[index]['postId'],
                                text: postDocs[index]['text'],
                                createdBy: postDocs[index]['createdBy'],
                                type: postDocs[index]['type'],
                                secretWord: postDocs[index]['secretWord']
                            );

                            return GestureDetector(
                              onLongPress:currentUserId == postDocs[index]['userId'] || currentUserId == "jLhQUkYfk2Nelc3H9aRn45FJpap2"?
                                  ()=>deletePost(postDocs[index]['postId']):()=>report(context, currentUserName, postDocs[index]['postId'], postGuess.name, postGuess.userId,postGuess.text,''),
                              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>PostViewGuess(widget.user,postGuess,getTimeDifferenceFromNow(dateTime),expireTime,postDocs[index]["likedBy"],postDocs[index]['commentCount']))),
                              child: Card(
                                  color: Colors.black,
                                  shadowColor: Colors.purple,
                                  elevation: 30,
                                  child:PostGuess(widget.user,postGuess,formattedTime,expireTime,postDocs[index]["likedBy"],postDocs[index]['commentCount'])
                              ),
                            );

                        }
                        //}
                        return Container();
                      }),
                );

              }
              /*if(snapshot.connectionState == ConnectionState.waiting){
              Future.delayed(Duration(seconds: 3), () async{
                return Text('loading...',style: TextStyle(color: Colors.purple),);
              });

            }*/
              return buildNoContent();


            }
            return Container();
          }),

    );


  }
  void _onselected (BuildContext context, int item){
    switch (item){
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreatePostScreen(
                  widget.user,
                )));
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>CreatePostGuess(
                  widget.user,
                )));
        break;
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>  CreatePostQuiz(
                  widget.user,
                )));
        break;

    /* case 3:
       Navigator.push(
           context,
           MaterialPageRoute(
               builder: (context) =>  Test(

               )));
       break;*/


    }

  }
}

