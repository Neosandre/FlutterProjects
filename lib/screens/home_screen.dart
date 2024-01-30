import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:jinx/models/user_model.dart';
import 'package:jinx/screens/explore_screen.dart';
import 'package:jinx/screens/notification_screen.dart';
import 'package:jinx/screens/profile_screen.dart';
import 'package:jinx/screens/rooms_screen.dart';
import 'package:jinx/screens/search_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'chatList_screen.dart';
import 'feed_screen.dart';

bool? selected;


class HomeScreen extends StatefulWidget {
  final UserModel userModel;
  final to;

  HomeScreen(this.userModel,this.to);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  /*UserModel user;
  HomeScreen(this.user);*/

  var _selectedTab=_enumList.home;
  bool hasInternet = false;
  final storageRef = FirebaseStorage.instance.ref();
  final feedRef = FirebaseFirestore.instance.collection('feed');
   String? currentUserphoto = FirebaseAuth.instance.currentUser?.photoURL;

  handleHomeIndex(String sentTo){
    switch(sentTo){
      case 'feedScreen':
        setState(() {
          _selectedTab=_enumList.home;
        });

        break;
      case 'searchScreen':
        setState(() {
          _selectedTab=_enumList.search;
        });

        break;
      case 'profile':
        setState(() {
          _selectedTab=_enumList.person;
        });
      break;
     case 'exploreScreen':
        setState(() {
          _selectedTab=_enumList.explore;
        });


    }

  }

  void _handleIndexChanged(int i) {
    setState(() {
      _selectedTab = _enumList.values[i];
    });
  }

  bool? isEmailVerified = false;
  Timer? timer;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified;
    });
  }

  Future<void> hasConnection() async {
    hasInternet = await InternetConnectionChecker().hasConnection;
    final text =
        hasInternet ? "Connected to Internet" : "No Internet Connection";
    final color = hasInternet ? Colors.green : Colors.red;
    if (hasInternet == false) {
      showSimpleNotification(
        Text(
          "$text",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        background: color,
      );
    }
  }

  notifications() async {
    QuerySnapshot snapshot = await feedRef
        .doc(currentUserId)
        .collection('feedItems')
        .where('selected', isEqualTo: false)
        .get();

    /*snapshot.docs.forEach((doc){
      bool selec= json.decode(json.encode(doc['selected']));*/

    if (snapshot.docs.isNotEmpty) {
      selected = false;
    } else {
      selected = true;
    }
  }



  void setStatusmanual(String status) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .update({'status': status});
  }

  //late final screens;

  @override
  void initState() {
    handleHomeIndex(widget.to);
    notifications();

    // TODO: implement initState
    //getToken(widget.userModel.id);
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified;
    if (!isEmailVerified!) {
      timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
    }
    hasConnection();
    //notifications();
    WidgetsBinding.instance.addObserver(this);
    setStatusmanual('online');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      //online
      setStatusmanual('online');
    } else {
      //offline
      setStatusmanual('offline');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    notifications();


    final screens = [
      ///2#Create this then add new value on click in notification and rooms creen
     FeedScreen(widget.userModel),
      Provider(
          create: (context) => UserModel, child: ExploreScreen(widget.userModel)),
    ChangeNotifierProvider(
    create: (_) => userInRoom(), child: SearchScreen(widget.userModel)),
      ChangeNotifierProvider(
        create: (_) => userInRoom(),
        child: NotificationScreen(widget.userModel),
      ),

      ProfileScreen(widget.userModel),

    ];

    ///AAAAAAAAAAaaactivateporta
    return isEmailVerified == false
        ? Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title:
                  Text("confirm email", style: TextStyle(color: Colors.white)),
            ),
            body: Padding(
              padding: EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  Text(
                    "A confirmation link was sent to ${widget.userModel.email} check your inbox  & junk or spam folder.",
                    style: TextStyle(color: Colors.white),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Color(0xfff1efe5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Resend',style: TextStyle(color: Colors.black),),
                      ),
                      onPressed: () {
                        try {
                          FirebaseAuth.instance.currentUser
                              ?.sendEmailVerification()
                              .then((value) => showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text(
                                          "Link sent! check your inbox & junk  or spam folder"),
                                    );
                                  }));
                        } on FirebaseAuthException catch (e) {
                          print(e);
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content:
                                      Text("error:${e.message.toString()}"),
                                  backgroundColor: Colors.red,
                                );
                              });
                        }
                      }),
                  TextButton(
                      child: Text(
                        'change email',
                        style: TextStyle(
                            color: Colors.purple,
                            decoration: TextDecoration.underline),
                      ),
                      onPressed: () async {
                        try {

                          final desertRef =
                              storageRef.child("user_image/$currentUserId.jpg");
                          desertRef.delete();

                          await FirebaseFirestore.instance
                              .collection("deleted")
                              .doc(currentUserId)
                              .set({
                            "id": currentUserId,
                            "email": widget.userModel.email,
                            "signUp": true
                          });
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUserId)
                              .delete();
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUserId)
                              .delete();
                          FirebaseAuth.instance.currentUser?.delete();
                          FirebaseAuth.instance.signOut();

                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AuthScreen()));
                        } catch (e) {
                          SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(e.toString()));
                        }
                      }),
                ],
              ),
            ),
          )
        : Scaffold(
      backgroundColor: Colors.transparent,
            extendBody: true,
            bottomNavigationBar: DotNavigationBar(
              backgroundColor: Color(0xfff1efe5),
//unselectedItemColor: Colors.white,
              //enableFloatingNavBar: false,
              currentIndex: _enumList.values.indexOf(_selectedTab),
              onTap: _handleIndexChanged,
              // dotIndicatorColor: Colors.black,
              items: [
                /// Home
                DotNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                  ),
                  selectedColor: Colors.lightBlue,
                ),

                /// Explore
                DotNavigationBarItem(
                    icon: Icon(CupertinoIcons.globe),
                    selectedColor: Colors.brown,
                    unselectedColor: Colors.black),

                /// Search
                DotNavigationBarItem(
                  icon: Icon(Icons.search),
                  selectedColor: Colors.orange,
                ),

                ///notifications
                DotNavigationBarItem(
                    icon: /* selected==false?*/ Icon(
                      Icons.notifications,
                    ),
                    //:Icon(Icons.notifications,),
                    selectedColor: Colors.green,
                    unselectedColor: selected == false ? Colors.purple : null),

                /// Profile
                DotNavigationBarItem(

                  icon: InkWell(child: CachedNetworkImage(
                    imageUrl:'$currentUserphoto',
                    imageBuilder: (context, imageProvider) => Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    placeholder: (context, url) => Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage('assets/defaultprofile.jpeg'), fit: BoxFit.cover),
                        )),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )),
                  selectedColor: Colors.teal,
                ),
              ],
              marginR: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
            ),
            //backgroundColor: Colors.black,
            body: screens[_selectedTab.index],
          );
  }
}

enum _enumList { home, explore, search, notifications, person }

class isSelected extends ChangeNotifier {
  void changeValue(bool newValue) {
    selected = newValue;
    notifyListeners();
  }
}


