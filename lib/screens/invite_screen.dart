import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinx/screens/profile_screen.dart';
import '../models/user_model.dart';
//messageing
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' as fd;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class InviteScreen extends StatefulWidget {
  final UserModel user;
  final title;
  final adim;
  final roomId;

  InviteScreen(this.user, this.title, this.adim, this.roomId);

  @override
  _InviteScreenState createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  List<String> blockedUsersByCurrentUser = [];
  List<String> usersBlockedCurrentUser = [];

  handleSearch(String query) {
    Future<QuerySnapshot> users = FirebaseFirestore.instance
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query.toLowerCase())
        .get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  _getBlockedUsersByCurrentUser() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('block')
        .doc(currentUserId)
        .collection('userBlocked')
        .get();
    snapshot.docs.forEach((doc) => blockedUsersByCurrentUser.add(doc.id));
  }

  _getUsersBlockedCurrentUser() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('blockedUsers')
        .doc(currentUserId)
        .collection('blockedBy')
        .get();
    snapshot.docs.forEach((doc) => usersBlockedCurrentUser.add(doc.id));
  }

  buildSearchField() {
    return AppBar(
      backgroundColor: Colors.transparent, //.withOpacity(0.8),
      title: Container(
        height: 50,
        child: TextFormField(
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: Colors.white),
          controller: searchController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(30))),
            hintText: 'Search user',
            hintStyle: TextStyle(color: Colors.white),
            filled: true,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.purple,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.purple,
              ),
              onPressed: () {
                searchController.clear();
              },
            ),
          ),
          //onFieldSubmitted: handleSearch,
          onChanged: (text){if(text.isNotEmpty){
            handleSearch(text);
          }}
        ),
      ),
    );
  }

  buildNoContent() {
    //orientation to fix image in landscape mode
    //final Orientation orientation=MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          //shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 150),
          children: [
            Icon(
              Icons.emoji_emotions,
              size: 100,
              color: Colors.purple,
            ),
            Text(
              'search for a friend...',
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

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        //test mode/ before adding user image in search and etc
        /* List<Text> searchResults = [];
        snapshot.data!.docs.forEach((doc) {
          UserModel user = new UserModel.fromMap(doc);
          searchResults.add(Text(user.name));*/

        List<UserResult> searchResults = [];
        snapshot.data!.docs.forEach((doc) {
          ///function to avoid user to find themselfs or blocked user in search
          if (!blockedUsersByCurrentUser.contains(doc.id) &&
              !usersBlockedCurrentUser.contains(doc.id) &&
              doc.id != currentUserId) {
            UserModel user = new UserModel.fromMap(doc);
            UserResult search =
                UserResult(user, widget.title, widget.adim, widget.roomId);

            searchResults.add(search);
          }
          //function to not show the current user in the search list
          //searchResults.removeWhere((element)=>element.user.uuid==currentUserId );
        });
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ListView(
            children: searchResults,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _getBlockedUsersByCurrentUser();
    _getUsersBlockedCurrentUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: buildSearchField(),
        body: searchResultsFuture == null
            ? buildNoContent()
            : buildSearchResults(),
      ),
    );
  }
}

class UserResult extends StatefulWidget {
  final UserModel user;
  final title;
  final adim;
  final roomId;

  UserResult(this.user, this.title, this.adim, this.roomId);

  @override
  State<UserResult> createState() => _UserResultState();
}

class _UserResultState extends State<UserResult> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  final String? currentUserName =
      FirebaseAuth.instance.currentUser?.displayName;

  final String? currentUserPhoto = FirebaseAuth.instance.currentUser?.photoURL;

  final activityFeedRef = FirebaseFirestore.instance.collection('feed');

  final String? currentUserphoto = FirebaseAuth.instance.currentUser?.photoURL;

  bool isInvited = false;

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
    final rings = 'rinios.m4r';
    final ringa = 'ringandroid';
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
              android: AndroidNotificationDetails(channel.id, channel.name,
                  //channel.description,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  channelDescription: 'channel description',
                  importance: Importance.max,
                  priority: Priority.max,
                  icon: '@drawable/ic_jinx',
                  sound: RawResourceAndroidNotificationSound(ringa),
                  subText: 'jinX',
                  playSound: true),
              iOS: DarwinNotificationDetails(
                  sound: rings,
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
  var _token;
   getToken()async{
    DocumentSnapshot users = await FirebaseFirestore.instance.collection('users').doc(widget.user.id).get();

    var t= users.get('token').toString();


    return _token = t ;

  }

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
              //"sound": "ringandroid.mp3",
            },
            "to":_token
          }));
    } catch (e) {
      print("error push notification: ${e.toString()}");
    }
  }


  @override
  void initState() {
    // TODO: implement initState

    loadFCM();
    listenFCM();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.purple, borderRadius: BorderRadius.circular(30)),
          child: Column(children: [
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(widget.user))),
              child: ListTile(
                leading:
                  //CachedNetworkImageProvider store the image so it doesnt have load the image every time we need to load it
                  CachedNetworkImage(
                    imageUrl: widget.user.photo,
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
                  //COLOr##################

                title: Text(
                  widget.user.name,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                trailing: TextButton(
                  onPressed: isInvited
                      ? null
                      : () async{
                          // DocumentSnapshot me = FirebaseFirestore.instance.collection('users').doc(currentUserId).get().toString() as DocumentSnapshot<Object?>;
                    await getToken();
                          setState(() {
                            isInvited = true;
                          });

                          //sending activity feed/ notification about new user
                          activityFeedRef
                              .doc(widget.user.id)
                              .collection('feedItems')
                              //Note delete currentUserId inside of doc to create another notification
                              .doc(currentUserId)
                              .set({
                            'type': 'invite',
                            'uuid': currentUserId,
                            'name': currentUserName,
                            'photo': currentUserphoto,
                            'timestamp': DateTime.now(),
                            'channel': widget.title,
                            'selected': false,
                            "roomId": widget.roomId,
                            "adim": widget.adim
                          });

                          sendPushMessage(currentUserName, 'invited you to join ${widget.title}');
                        },
                  child: Text("Invite"),
                ),
              ),
            )
          ]),
        ));
  }
}
