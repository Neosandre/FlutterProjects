import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jinx/screens/home_screen.dart';
import 'package:jinx/screens/postviews/postviewguess.dart';
import 'package:jinx/screens/postviews/postviewpoll.dart';
import 'package:jinx/screens/postviews/postviewquiz.dart';
import 'package:jinx/screens/profile_screen.dart';
import 'package:jinx/screens/rooms_screen.dart';
import 'package:jinx/screens/usernotfound_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../models/post_guess_model.dart';
import '../models/post_model.dart';
import '../models/post_quiz_model.dart';
import '../models/user_model.dart';
import 'group_chat_screen.dart';

class NotificationScreen extends StatefulWidget {
  final user;

  NotificationScreen(this.user);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final feedRef = FirebaseFirestore.instance.collection('feed');
  final usersRef = FirebaseFirestore.instance.collection('users');
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final String? currentUsername =
      FirebaseAuth.instance.currentUser?.displayName;
  final String? currentUserphoto = FirebaseAuth.instance.currentUser?.photoURL;


  var activityItemText;
  bool selected = false;
  UserModel? otherUser;

  List<String> answerList=[];
  var formattedTime;


  List<String> followingList = [];

  //change the text based on notification type
  handleNotificationType(notificationType) {
    switch (notificationType) {
      case 'follow':
        {
          activityItemText = 'started following you';
        }
        break;
      case 'invite':
        {
          activityItemText = 'invited you to join ';
        }
        break;
      case 'comment':
        {
          activityItemText = 'commented on your post';
        }
        break;
      case 'like':
        {
          activityItemText = 'liked your post';
        }
        break;
    }
  }

  //Refreshers
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();

    /* await Future.delayed(Duration(milliseconds: 1500));
    //items.add((items.length + 1).toString());
    Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (a, b, c) =>
            NotificationScreen(widget.user),
        transitionDuration: Duration(seconds: 10)));
    return Future.value(false);*/

    if (mounted) setState(() {});
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  //function to send user to the right user profile
  _getAllUsers(userId) async {
    QuerySnapshot snapshot =
        await usersRef.where("id", isEqualTo: userId).get();
    snapshot.docs.forEach((doc) {
      otherUser = new UserModel.fromMap(doc);
    });
  }


  getTimeDifferenceFromNow(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 5) {
      formattedTime= "Just now";
    } else if (difference.inMinutes < 1) {
      formattedTime= "${difference.inSeconds}s ago";
    } else if (difference.inHours < 1) {
      formattedTime= "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      formattedTime= "${difference.inHours}h ago";
    } else {
      formattedTime= "${difference.inDays}d ago";
    }
  }

//sending to user profile
  void tapOnFollowNotification() {
    if (otherUser != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ProfileScreen(otherUser!)));
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => UserNotFoundScreen()));
    }
  }

  void tapOnInviteNotification(title, roomId, adim) async {
    await FirebaseFirestore.instance
        .collection('roomuserin')
        .doc(widget.user.id)
        .set({
          'userId': currentUserId,
          'title': title,
          'roomId': roomId,
          "adim": adim,
        })
        .then((value) {
          FirebaseFirestore.instance
              .collection('usersinRoom')
              .doc(roomId)
              .collection("list")
              .doc(currentUserId)
              .set({
            'userId': currentUserId,
            'title': title,
            'roomId': roomId,
            "name": currentUsername,
            "photo": currentUserphoto
          }).then((value) =>
                  FirebaseMessaging.instance.subscribeToTopic(roomId));

          ///aaaaaaaaaaaa
          //add tbm aqui
          //aad
        })
        .then((value) => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    GroupChatScreen(title, roomId, widget.user, adim))))

        ///#3 last step add this to change value when click and done try it now
        .then((value) =>
            Provider.of<userInRoom>(context, listen: false).changeValue(
              true, /*roomId*/
            ));
  }

   tapOnLikeNotification(postId)async{
   DocumentSnapshot post= await FirebaseFirestore.instance.collection('post').doc(postId).get();

   if (post.exists){

     String type=post.get('type');

     switch(type) {
       case 'pp':
         DateTime dateTime = DateTime.parse(
             post['time'].toDate().toString());
         getTimeDifferenceFromNow(dateTime);
         final postM = PostModel(
           name: post['name'],
           userId: post['userId'],
           photo: post['photo'],
           anonymous: post['anonymous'],
           //time: postDocs[index]['time'],
           postImage: post['postImage'],
           type: post['type'],
           postId: post['postId'],
           createdBy: post['createdBy'],
           option1: post['option1'],
           option2: post['option2'],
           option3: post['option3'],
           text: post['text'],
           poll: post['poll'],
           option1P: post["option1P"] + .0,
           option2P: post["option2P"] + .0,
           option3P: post["option3P"] + .0,
           //userWhoVoted: postDocs[index]["userWhoVoted"]
         );

         Map<String, int> converted = {};
         var st = post["userWhoVoted"];
         for (final mapEntry in st.entries) {
           final key = mapEntry.key;
           final value = mapEntry.value;
           converted[key] = value;
         }


         return Navigator.push(context, MaterialPageRoute(
             builder: (context) =>
                 PostViewPoll(postM, formattedTime, converted, post["likedBy"],
                     post['commentCount'], widget.user)));

      /* case 'pq':
         DateTime dateTime = DateTime.parse(
             post['time'].toDate().toString());
         getTimeDifferenceFromNow(dateTime);
         final postQuiz = PostQuizModel(
           name: post['name'],
           userId: post['userId'],
           photo: post['photo'],
           postId: post['postId'],
           text: post['text'],
           createdBy: post['createdBy'],
           type: post['type'],
         );
         var answers = post["answers"];
         Map<String, dynamic> converted = {};

         for (final mapEntry in answers.entries) {
           final key = mapEntry.key;
           final value = mapEntry.value;
           converted[key] = value;
           answerList.add(key);
         }

         return Navigator.push(context, MaterialPageRoute(
             builder: (context) =>
                 PostViewQuiz(
                     widget.user,
                     postQuiz,
                     formattedTime,
                     converted,
                     answerList,
                     post['userWhoAnswered'],
                     post["likedBy"],
                     post["commentCount"])));*/

       case 'pg':
         DateTime dateTime = DateTime.parse(
             post['time'].toDate().toString());
         DateTime expireTime = DateTime.parse(
             post['expireDate'].toDate().toString());
         getTimeDifferenceFromNow(dateTime);
         final postGuess = PostGuessModel(
             name: post['name'],
             userId: post['userId'],
             photo: post['photo'],
             postId: post['postId'],
             text: post['text'],
             createdBy: post['createdBy'],
             type: post['type'],
             secretWord: post['secretWord']
         );

         return Navigator.push(context, MaterialPageRoute(builder: (context) =>
             PostViewGuess(widget.user, postGuess, formattedTime, expireTime,
                 post["likedBy"], post['commentCount'])));
     }


   }

   else{
    Navigator.push(context,
    MaterialPageRoute(builder:  (context) => UserNotFoundScreen()));

    }


   }
  

//functions for invite
  Future<void> _handleMicPermission() async {
    //Permission.microphone.request() like this in actual versions
    final status = Permission.microphone.request();
  }

  buildNoContent() {
    return Container(
      padding: EdgeInsets.only(top: 200),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.emoji_emotions,
              size: 100,
              color: Colors.purple,
            ),
            Text(
              'notifications empty...\n',
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
    _handleMicPermission();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _refreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: feedRef
          .doc(currentUserId)
          .collection('feedItems')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data?.docs.length != 0)
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                  title: Text('Notifications'),
                  backgroundColor: Colors.transparent),
              body: SmartRefresher(
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
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index];

                      handleNotificationType(data['type']);

                      DateTime dateTime =
                          DateTime.parse(data['timestamp'].toDate().toString());
                      //dateAndTime = DateFormat.MMMd().add_jm().format(dateTime);
                      getTimeDifferenceFromNow(dateTime);
                      selected = data['selected'];

                      if (DateTime.now().difference(dateTime).inHours > 24) {
                        FirebaseFirestore.instance
                            .collection('feed')
                            .doc(currentUserId)
                            .collection("feedItems")
                            .doc(data.id)
                            .delete();
                      }

                      return Container(


                        //margin: EdgeInsets.only(bottom: 3),
                        color: selected == false
                            ? Colors.purple
                            : Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await _getAllUsers(data['uuid']);

                            switch (data['type']) {
                              case 'follow':
                                tapOnFollowNotification();
                                break;
                              case 'invite':
                                tapOnInviteNotification(
                                  data['channel'],
                                  data['roomId'],
                                  data["adim"],
                                );
                                //Navigator.push(context, MaterialPageRoute(builder: (context)=> GroupChatScreen(data['channel'], data['roomId'] ,widget.user,data["adim"])));
                                //tapOnInviteNotification( data['channel'],data['roomId'], data["adim"],);

                                break;
                              case 'like':
                                tapOnLikeNotification(
                                    data['postId']
                                );
                                break;
                              case 'comment':
                                tapOnLikeNotification(
                                    data['postId']
                                );
                                break;
                            }
                            feedRef
                                .doc(currentUserId)
                                .collection('feedItems')
                                .doc(data.id)
                                .update({'selected': true});

                            setState(() {
                              selected = true;
                              //_isLoading=false;
                            });
                            Provider.of<isSelected>(context, listen: false)
                                .changeValue(true);
                          },
                          child: ListTile(
                            title: RichText(
                              overflow: TextOverflow.clip,
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14.0,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: data['name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    TextSpan(
                                        text: ' $activityItemText ',
                                        style: TextStyle(color: Colors.white)),
                                    TextSpan(
                                        text: data['channel'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white))
                                  ]),
                            ),
                            leading: CachedNetworkImage(
                              imageUrl: data['photo'],
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
                            subtitle: Text(
                              formattedTime,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      );

                      return Container();
                    }),
              ),
            );
          else {
            return buildNoContent();
          }
        }

        return Container(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.purple,
            ),
          ),
        );
        ;
      },
    );
  }
}
