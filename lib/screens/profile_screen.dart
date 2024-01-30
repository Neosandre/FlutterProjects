import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:jinx/main.dart';
import 'package:jinx/screens/aboutandcontact_screen.dart';
import 'package:jinx/screens/blacklist_screen.dart';
import 'package:jinx/screens/chat_screen.dart';
import 'package:jinx/screens/home_screen.dart';
import 'package:jinx/screens/loading_screen.dart';
import 'package:jinx/screens/usernotfound_screen.dart';
import 'package:jinx/screens/zoomimage.dart';
import 'package:jinx/widgets/indexchange.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import 'editprofile_screen.dart';
import 'followers_list.dart';
import 'following_list.dart';
import 'package:flutter/foundation.dart' as fd;
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final UserModel userModel;

  //const ProfileScreen({Key? key,required this.userModel}) : super(key: key);
  ProfileScreen(this.userModel);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final followersRef = FirebaseFirestore.instance.collection('followers');
  final followingRef = FirebaseFirestore.instance.collection('following');
  final activityFeedRef = FirebaseFirestore.instance.collection('feed');

  int followerCount = 0;
  int followingCount = 0;
  bool isFollowing = false;

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final String? currentUserName = FirebaseAuth.instance.currentUser?.displayName;
  final String? currentUserphoto = FirebaseAuth.instance.currentUser?.photoURL;
  final storageRef = FirebaseStorage.instance.ref();

  var userStatus;
  var userBio;
  var userPhoto;
  dynamic chatId;
  String? chatIdf;

  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length,
          (_) => ProfileScreen._chars
          .codeUnitAt(_rnd.nextInt(ProfileScreen._chars.length))));

  ///Follow Button functions

  editProfile() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditProfileScreen(widget.userModel)));
  }

  Container buildButton({required String text, required Function function}) {
    return Container(
      child: ElevatedButton(

        style: ElevatedButton.styleFrom(primary: Colors.purple,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),),

        onPressed: () => function(),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    ///TTTTTTTTTTTTOOOOOOOOOOOOOCHQAN////
    bool isprofileOwner = currentUserId == widget.userModel.id;
    if (isprofileOwner) {
      return buildButton(text: 'Edit Profile', function: editProfile);
    } else if (isFollowing) {
      followerCount--;
      return buildButton(text: 'Unfollow', function: handleUnfollowUser);
    } else if (!isFollowing) {
      followerCount++;
      return buildButton(text: 'Follow', function: handleFollowUser);
    }
  }

  ///user following and follower count and check is current user is following
  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.userModel.id)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  deleteFollowing() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('followers')
        .doc(currentUserId)
        .collection("userFollowers")
        .get();
    snapshot.docs.forEach((element) {
      FirebaseFirestore.instance
          .collection('following')
          .doc(element.id)
          .collection("userFollowing")
          .doc(currentUserId)
          .delete().then((value) {
        FirebaseFirestore.instance
            .collection('followers')
            .doc(currentUserId)
            .collection("userFollowers")
            .doc(element.id).delete();

      });
    });
  }

  deleteFollowers() async {
    ///deletefollowings
    QuerySnapshot snapshot2 = await FirebaseFirestore.instance
        .collection('following')
        .doc(currentUserId)
        .collection("userFollowing")
        .get();
    snapshot2.docs.forEach((element) {
      FirebaseFirestore.instance
          .collection('followers')
          .doc(element.id)
          .collection("userFollowers")
          .doc(currentUserId)
          .delete();
    });
  }

  deletefeedfollowers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('followers')
        .doc(currentUserId)
        .collection("userFollowers")
        .get();

    snapshot.docs.forEach((element) async {
      final el = element.id;
      QuerySnapshot _snapshot = await FirebaseFirestore.instance
          .collection('feed')
          .doc(element.id)
          .collection("feedItems")
          .where("uuid", isEqualTo: currentUserId)
          .get();
      _snapshot.docs.forEach((element) {

        FirebaseFirestore.instance
            .collection('feed')
            .doc(el)
            .collection("feedItems")
            .doc(element.id)
            .delete();
      });
    });
  }

  deletefeedFollowing() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('following')
        .doc(currentUserId)
        .collection("userFollowing")
        .get();

    snapshot.docs.forEach((element) async {
      final el = element.id;
      QuerySnapshot _snapshot = await FirebaseFirestore.instance
          .collection('feed')
          .doc(element.id)
          .collection("feedItems")
          .where("uuid", isEqualTo: currentUserId)
          .get();
      _snapshot.docs.forEach((element) {

        FirebaseFirestore.instance
            .collection('feed')
            .doc(el)
            .collection("feedItems")
            .doc(element.id)
            .delete();
      });
    });
  }

  ///here here ///
  final _num = 150000;
  String? numfollower = '0';
  String? numfollowing = '0';

  /* convertnum(){
    // In this you won't have to worry about the symbol of the currency.
    var _formattedNumber = NumberFormat.compact().format(_num);
    print('Formatted Number is: ${_formattedNumber.toLowerCase()}');
  }*/
  getFollowers() async {
    QuerySnapshot snapshot = await followersRef.doc(widget.userModel.id)
        .collection('userFollowers')
        .get();

    if (snapshot.docs.length >= 1000) {
      var _formattedNumber =
      NumberFormat.compact().format(snapshot.docs.length).toLowerCase();
      //print('Formatted Number is: ${_formattedNumber.toLowerCase()}');
      setState(() {
        numfollower = _formattedNumber;
      });

    } else {

      setState(() {
        followerCount = snapshot.docs.length;
      });

    }

/*setState(() {
      followerCount = snapshot.docs.length;
    });*/
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.userModel.id)
        .collection('userFollowing')
        .get();

    if (snapshot.docs.length >= 1000) {
      var _formattedNumber =
      NumberFormat.compact().format(snapshot.docs.length).toLowerCase();
      //print('Formatted Number is: ${_formattedNumber.toLowerCase()}');
  setState(() {
    numfollowing = _formattedNumber;
  });

    } else {
      setState(() {
        followingCount = snapshot.docs.length;
      });

    }

    /*setState(() {
      followingCount = snapshot.docs.length;
    });*/
  }

  //Blocking user functions
  alertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Color(0xfff1efe5),
            title: Text('Block', style: TextStyle(color: Colors.red)),
            content: Text('are you sure you want to Block this user?'),
            actions: [
              TextButton(
                child: Text(
                  'Yes',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('block')
                      .doc(currentUserId)
                      .collection('userBlocked')
                      .doc(widget.userModel.id)
                      .set({
                    'userId': widget.userModel.id,
                    'userName': widget.userModel.name,
                    'userImage': widget.userModel.photo
                  }).then((value) async {
                    await FirebaseFirestore.instance
                        .collection('blockedUsers')
                        .doc(widget.userModel.id)
                        .collection('blockedBy')
                        .doc(currentUserId)
                        .set({
                      'userId': currentUserId,
                      'userName': currentUserName,
                      'userImage': currentUserphoto
                    });
                  }).then((value) async {
                    ///removing blocked user
                    await FirebaseFirestore.instance
                        .collection('following')
                        .doc(currentUserId)
                        .collection('userFollowing')
                        .doc(widget.userModel.id)
                        .delete()
                        .then((value) => FirebaseFirestore.instance
                        .collection('followers')
                        .doc(currentUserId)
                        .collection('userFollowers')
                        .doc(widget.userModel.id)
                        .delete());

                    ///removing user who blocked
                    await FirebaseFirestore.instance
                        .collection('following')
                        .doc(widget.userModel.id)
                        .collection('userFollowing')
                        .doc(currentUserId)
                        .delete()
                        .then((value) => FirebaseFirestore.instance
                        .collection('followers')
                        .doc(widget.userModel.id)
                        .collection('userFollowers')
                        .doc(currentUserId)
                        .delete());
                  });

                  //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NewsFeed(user: widget.user,)));

                  ///removing blocked user from private chatList of both users
                  await FirebaseFirestore.instance
                      .collection('chatList')
                      .doc(currentUserId)
                      .collection('userChatList')
                      .doc(widget.userModel.id)
                      .delete()
                      .then((_) => FirebaseFirestore.instance
                      .collection('chatList')
                      .doc(widget.userModel.id)
                      .collection('userChatList')
                      .doc(currentUserId)
                      .delete());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('You blocked ${widget.userModel.name}')));
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreen(widget.userModel,'feedScreen')));
                },
              ),
              TextButton(
                child: Text(
                  'No',
                  style: TextStyle(fontSize: 18, color: Colors.purple),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _bottomSheet(context) async {
    await showModalBottomSheet(
        backgroundColor: Color(0xfff1efe5),
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        builder: (context) => Container(
          height: 90,
          child: Column(
            children: [

              TextButton(
                child: Text(
                  'Block',
                  style: TextStyle(color:widget.userModel.id != 'jLhQUkYfk2Nelc3H9aRn45FJpap2'? Colors.red:Colors.grey, fontSize: 20),
                ),
                onPressed:  widget.userModel.id != 'jLhQUkYfk2Nelc3H9aRn45FJpap2'? () {
                  Navigator.pop(context);
                  alertDialog(context);
                }:null,
              ),
              Divider()
            ],
          ),
        ));
  }

  _bottomSheetSettings(context) async {
    await showModalBottomSheet(
        backgroundColor: Color(0xfff1efe5),
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        builder: (context) => Container(
          height: 400,
          child: Column(
            children: [
              TextButton(
                child: Text(
                  'Block List',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BlackListScreen())),
              ),
              Divider(),
              TextButton(
                child: Text(
                  'Terms & Conditions',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                onPressed: () =>_launchUrl('https://www.dropbox.com/s/dy3bssoxtwayeae/Terms%26conditionsJinx.pages?dl=0'),/*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TermsAndConditionsScreens())),*/
              ),
              Divider(),
              TextButton(
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                onPressed: () =>_launchUrl('https://www.dropbox.com/s/a0vf8aqyip02ro3/PrivacyPolicyjinx.pages?dl=0'),
                /* Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PrivacyPolicyScreen())),*/
              ),
              Divider(),
              TextButton(
                child: Text(
                  'Contact Us',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AboutAndContactScreen())),
              ),
              Divider(),
              TextButton(
                  child: Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            title: Text('Sign out',
                                style: TextStyle(color: Colors.red)),
                            content:
                            Text('are you sure you want to Sign out?'),
                            actions: [
                              TextButton(
                                  child: Text(
                                    'Yes',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.red),
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(currentUserId)
                                        .update({'status': 'offline'});
                                    FirebaseAuth.instance.signOut();
                                    await Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AuthScreen()));
                                  }),
                              TextButton(
                                child: Text(
                                  'No',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.purple),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ]
                          ///nao mechas
                        );
                      })),
              Divider(),
              TextButton(
                  child: Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            backgroundColor: Color(0xfff1efe5),
                            title: Text('Delete My Account',
                                style: TextStyle(color: Colors.red)),
                            content: Text(
                                "account will be visible to users up to 24h "
                                    'are you sure you want to permanently Delete your Account?'),
                            actions: [
                              TextButton(
                                  child: Text(
                                    'Yes',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.red),
                                  ),
                                  onPressed: () async {
                                    try {
                                      setState(() {
                                        isLoading == true;
                                      });

                                      ///deleting from other follwers & follwing list
                                      await deleteFollowing();
                                      await deleteFollowers();

                                      ///deleting from other's feed
                                      await deletefeedFollowing();
                                      await deletefeedfollowers();
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(currentUserId)
                                          .delete();
                                      FirebaseFirestore.instance
                                          .collection('rooms')
                                          .where("userId",
                                          isEqualTo: currentUserId)
                                          .get()
                                          .then((snapshot) {
                                        for (DocumentSnapshot ds
                                        in snapshot.docs) {
                                          ds.reference.delete();
                                        }
                                      });

                                      FirebaseFirestore.instance
                                          .collection('followers')
                                          .doc(currentUserId)
                                          .collection('userFollowers')
                                          .get()
                                          .then((snapshot) {
                                        for (DocumentSnapshot ds
                                        in snapshot.docs) {
                                          ds.reference.delete();
                                        }
                                      });
                                      FirebaseFirestore.instance
                                          .collection('following')
                                          .doc(currentUserId)
                                          .collection("userFollowing")
                                          .get()
                                          .then((snapshot) {
                                        for (DocumentSnapshot ds
                                        in snapshot.docs) {
                                          ds.reference.delete();
                                        }
                                      });
                                      FirebaseFirestore.instance
                                          .collection('chatList')
                                          .doc(currentUserId)
                                          .collection("userChatList")
                                          .get()
                                          .then((snapshot) {
                                        for (DocumentSnapshot ds
                                        in snapshot.docs) {
                                          ds.reference.delete();
                                        }
                                      });

                                      FirebaseFirestore.instance
                                          .collection('roomuserin')
                                          .doc(currentUserId)
                                          .delete();
                                      FirebaseFirestore.instance
                                          .collection('feed')
                                          .doc(currentUserId)
                                          .collection("feedItems")
                                          .get()
                                          .then((snapshot) {
                                        for (DocumentSnapshot ds
                                        in snapshot.docs) {
                                          ds.reference.delete();
                                        }
                                      });

                                      /// Create a reference to the file to deletefor next app version
                                      /*final desertRef = storageRef.child("user_image/$currentUserId.jpg");
                                desertRef.delete();*/

                                      await FirebaseFirestore.instance
                                          .collection("deleted")
                                          .doc(currentUserId)
                                          .set({
                                        "id": currentUserId,
                                        "email": widget.userModel.email,
                                        "name": currentUserName
                                      });
                                      // await FirebaseAuth.instance.currentUser?.delete();
                                      FirebaseAuth.instance.signOut();
                                      setState(() {
                                        isLoading == true;
                                      });

                                      ///oldversion not longer needed
                                      /* FirebaseAuth.instance.currentUser?.delete();
                                    await FirebaseAuth.instance.signOut()
                                    .then((value) => FirebaseFirestore.instance.collection('users').doc(widget.userModel.id).delete());*/

                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AuthScreen()));
                                    } on FirebaseException catch (e) {
                                      SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(e.message.toString()));
                                    }
                                  }),
                              TextButton(
                                child: Text(
                                  'No',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.purple),
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ]

                          ///nao mechas
                        );
                      })),
            ],
          ),
        ));
  }

  ///Follow button handlers
  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });

    followersRef
        .doc(widget.userModel.id)
        .collection('userFollowers')
        .doc(currentUserId)
    //note it could have just been .delete()
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.userModel.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //removing notification
    /* activityFeedRef.doc(widget.user.uuid).collection('feedItems')
    .doc(currentUserId).get().then((doc) {
      if(doc.exists){
        doc.reference.delete();
      }
    });*/
  }
  var _token;
  void _getToken()async{
    DocumentSnapshot users = await FirebaseFirestore.instance.collection('users').doc(widget.userModel.id).get();
    var t= users.get('token').toString();
    _token = t;

  }
  handleFollowUser() {
    // DocumentSnapshot me = FirebaseFirestore.instance.collection('users').doc(currentUserId).get().toString() as DocumentSnapshot<Object?>;

    setState(() {
      isFollowing = true;
    });
    //tring to correct the following count from updating all the time
    /* FirebaseFirestore.instance.collection('users').doc(widget.userModel.id).update({
      'followers':[currentUserId]
    });*/
    //make user follow another user and update their followers collection

    followersRef
        .doc(widget.userModel.id)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({
      'name': currentUserName,
      'photo': currentUserphoto,
      'uuid': currentUserId,
      'status': userStatus
    });
    //tring to correct the following count from updating all the time
    /*FirebaseFirestore.instance.collection('users').doc(widget.userModel.id).update({
      'followers':[currentUserId]
    });*/
    //putting that  user on your following collection (update your following collection)


    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.userModel.id)
        .set({
      'name': widget.userModel.name,
      'photo': widget.userModel.photo,
      'uuid': widget.userModel.id,
      'status': userStatus
    });

    //sending activity feed/ notification about new user
    activityFeedRef
        .doc(widget.userModel.id)
        .collection('feedItems')
    /*.doc(currentUserId)*/ .add({
      'type': 'follow',
      'uuid': currentUserId,
      'name': currentUserName,
      'photo': currentUserphoto,
      'timestamp': DateTime.now(),
      'channel': '',
      'selected': false,
    });
    sendPushMessage(currentUserName, 'is following you on jinX');
  }

  ///URL lancher
  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceWebView: true,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'can\'t launch Link up, please make sure it contains https//:...'),
      ));
    }
  }

  List<String> blockedUsersByCurrentUser = [];

  _getBlockedUsersByCurrentUser() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('block')
        .doc(currentUserId)
        .collection('userBlocked')
        .get();
    snapshot.docs.forEach((doc) => blockedUsersByCurrentUser.add(doc.id));
  }

  List<String> usersBlockedCurrentUser = [];

  _getUsersBlockedCurrentUser() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('blockedUsers')
        .doc(currentUserId)
        .collection('blockedBy')
        .get();
    snapshot.docs.forEach((doc) => usersBlockedCurrentUser.add(doc.id));
  }

  ///pushnotification
  ///firebasemessageing
  //String?_token;
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  ///firebase messaging to be deleted
  void loadFCM() async {
    if (!fd.kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
        showBadge: true,
        sound: RawResourceAndroidNotificationSound('ringandroid'),
        playSound: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    // _number= random.nextInt(1000000);
  }

  void listenFCM() async {
    //final rings = 'rinios.m4r';
    //final ringa = 'ringandroid';
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      //AndroidNotificationSound sound='ringandroid';
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null && !fd.kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  //channel.description,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  channelDescription: 'channel description',
                  importance: Importance.max,
                  priority: Priority.max,
                  icon: '@drawable/ic_jinx',
                  sound: RawResourceAndroidNotificationSound('ringandroid'),
                  subText: 'jinX',
                  playSound: true),
              iOS: DarwinNotificationDetails(
                  sound: 'rinios.m4r',
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                  subtitle: "jinX")),
        );
      }
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);
  }

  /*void getToken()async{
    await FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        _token=value;
        print("token: $value");
      });}

    );
  }*/

  void sendPushMessage(name, msg) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
            'key=AAAAqzRiIhI:APA91bF7X0RPFktJ6cU6gxWvx9sPpLWdJKlI7ujaiAl5mC62aAb0JIGwVNp_Hln5-TJLbRTI2gO9SuCghqaiCKGNzvI9nS-AAcAtxWg_j3Qm3tIUDe-9hhUYKtlyRFL0TOs56GojOIui',
          },
          body: jsonEncode(<String, dynamic>{
            'notification': <String, dynamic>{'body': msg, 'title': name},
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              "sound": "ringandroid.mp3",
            },
            "to": _token
          }));
    } catch (e) {
      print("error push notification: ${e.toString()}");
    }
  }

///helpupdatedatabase functions

/*updateUsers()async{
     ///Note: change the rules for users in firebase
    QuerySnapshot users = await FirebaseFirestore.instance.collection('users').get();
    users.docs.forEach((element) {
      FirebaseFirestore.instance.collection('users').doc(element.id).update({
        'followers':[],
        'following':[]
      });

    });
}

makeUsersFollowJinx()async{
 ///Note: change the rules for users in firebase
  DocumentSnapshot jinx = await FirebaseFirestore.instance.collection('users').doc("jLhQUkYfk2Nelc3H9aRn45FJpap2").get();
  QuerySnapshot users = await FirebaseFirestore.instance.collection('users').get();
  users.docs.forEach((element) {
    followersRef
        .doc(jinx.id)
        .collection('userFollowers')
        .doc(element.id)
        .set({
      'name': element['name'],
      'photo': element['photo'],
      'uuid': element['id'],
      'status': element['status']
    });

    followingRef
        .doc(element.id)
        .collection('userFollowing')
        .doc(jinx.id)
        .set({
      'name': jinx['name'],
      'photo': jinx['photo'],
      'uuid': jinx['id'],
      'status': jinx['status']
    });

  });

}*/

  @override
  void initState() {
    //updateUsers();
    //makeUsersFollowJinx();
    // TODO: implement initState
    super.initState();
    checkIfFollowing();
    getFollowers();
    getFollowing();
    _getUsersBlockedCurrentUser();
    _getBlockedUsersByCurrentUser();
    _getToken();
    loadFCM();
    listenFCM();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    return blockedUsersByCurrentUser.contains(widget.userModel.id) ||
        usersBlockedCurrentUser.contains(widget.userModel.id)
        ? UserNotFoundScreen()
        : isLoading == false
        ? Scaffold(
      backgroundColor: Colors.black,
      appBar:AppBar(
        //automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Text('Profile'),
        actions:  [
          currentUserId == widget.userModel.id
              ? IconButton(
            icon: Icon(
              Icons.settings_rounded,
              color: Colors.purple,
            ),
            onPressed: () => _bottomSheetSettings(context),
          )
              : IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => _bottomSheet(context))
        ],
      ),
      body: SingleChildScrollView(
        key: PageStorageKey<String>('profile'),
        //physics: NeverScrollableScrollPhysics(),
        child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.,
            //physics: BouncingScrollPhysics(),
            children: [
              Row(
                children: [
                  Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FollowersList(widget.userModel)));
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                followerCount < 1000
                                    ? '$followerCount'
                                    : '$numfollower' '$followerCount',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white)),
                            InkWell(
                              child: Text(
                                'followers',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                      )),
                  Column(
                    children: [
                      ProfileWidget(
                          user: widget.userModel,
                          onClicked: ()  async{
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ZoomImage(
                                        widget.userModel.photo)));
                          }),
                      SizedBox(
                        height: 9,
                      ),
                      Center(
                          child: Text(
                            widget.userModel.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Row(children: [
                        widget.userModel.id == "jLhQUkYfk2Nelc3H9aRn45FJpap2"? Container():buildProfileButton(),
                        SizedBox(width: 10,),
                        widget.userModel.id != currentUserId? Container(
                          child: ElevatedButton(

                            style: ElevatedButton.styleFrom(primary: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),),

                            onPressed: () async {
                              QuerySnapshot userList = await FirebaseFirestore.instance
                                  .collection('chatList')
                                  .doc(currentUserId)
                                  .collection('userChatList')
                                  .get();

                              userList.docs.forEach((element) {
                                if (element.id == widget.userModel.id) {
                                  chatIdf = element['chatId'];
                                }
                              });

                              if (chatIdf != null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ChatScreen(widget.userModel, chatIdf!)));
                              } else {
                                chatId = getRandomString(10);
                                FirebaseFirestore.instance
                                    .collection('privatechat')
                                    .doc(chatId)
                                    .set({
                                  //'createdby':currentUserName,
                                  //'creatorId':currentUserId,
                                  'chatId': chatId,
                                  'userList': [currentUserId, widget.userModel.id]
                                  //'to': widget.userModel.name,
                                  //'receiverId':widget.userModel.id
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            widget.userModel,
                                            chatId /* widget.userModel.id,widget.userModel.name,widget.userModel.photo,*/)));
                              }
                            },
                            child: Text(
                              "Message",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ):Container()
                      ],),

                      //##########################
                    ],
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FollowingList(widget.userModel)));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                              followingCount < 1000
                                  ? '$followingCount'
                                  : '$numfollowing' '$followingCount',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white)),
                          Text('following',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bio',
                      style: TextStyle(
                        /*fontWeight: FontWeight.bold*/
                          color: Colors.grey,
                          fontSize: 20),
                    ),
                    Text(
                      widget.userModel.bio,
                      style: TextStyle(
                        /*fontStyle: FontStyle.italic,*/
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    ///Instagram launcher
                    Row(
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /* Container(

                        child:IconButton(icon: Icon(FontAwesomeIcons.link),onPressed:(){
                          _launchUrl('${widget.userModel.instagram}');
                        } ,iconSize: 18,) ,
                      ),*/
                        GFButton(
                          onPressed:
                          widget.userModel.instagram.isNotEmpty
                              ? () {
                            _launchUrl(
                                '${widget.userModel.instagram}');
                          }
                              : null,
                          text: "Social",
                          icon: Icon(Icons.share),
                          shape: GFButtonShape.pills,
                          color: widget.userModel.instagram != ''
                              ? Colors.purple
                              : Colors.grey,
                          padding:
                          EdgeInsets.symmetric(horizontal: 5),
                          splashColor: Colors.grey,
                          //animationDuration: Duration(seconds: 30),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.purple,),
              IndexChange(widget.userModel)
            ],
          ),


      ),
    )
        : LoadingScreen();
  }
}

class ProfileWidget extends StatelessWidget {
  final VoidCallback onClicked;
  final UserModel user;

  const ProfileWidget({required this.onClicked, required this.user});

  Widget buildImage() {
    //final image = Icon(Icons.person);

    return GestureDetector(
      onTap: onClicked,
      child: CachedNetworkImage(
        imageUrl: user.photo,
        imageBuilder: (context, imageProvider) => Container(
          width: 128.0,
          height: 128.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (context, url) => Container(
            width: 128.0,
            height: 128.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: AssetImage('assets/defaultprofile.jpeg'), fit: BoxFit.cover),
            )),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    /* final color = Theme.of(context).colorScheme.primary;*/
    return Center(
        child:
        Container(padding: EdgeInsets.only(top: 50), child: buildImage()));
  }
}


