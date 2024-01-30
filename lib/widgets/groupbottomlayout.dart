import 'dart:async';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jinx/models/message_model.dart';
import 'package:jinx/widgets/replymessagewidget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

//gifs
import 'package:emojis/emojis.dart';
import 'package:jinx/chats/messages.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:string_validator/string_validator.dart';

//messageing
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' as fd;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class GroupBottomLayout extends StatefulWidget {
  final FocusNode focusNode;
  final MessageModel? replyMessage;
  final VoidCallback onCancelReply;
  final roomId;
  final UserModel userModel;
  final roomTitle;

  //const BottomLayout({Key? key}) : super(key: key);
  const GroupBottomLayout(this.focusNode, this.replyMessage, this.onCancelReply,
      this.roomId, this.userModel, this.roomTitle);

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  @override
  _GroupBottomLayoutState createState() => _GroupBottomLayoutState();
}

class _GroupBottomLayoutState extends State<GroupBottomLayout> {
  ///Message reply

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  //GiphyGif? _gif;
  bool emojiShowing = false;
  int maxLength = 3;
  bool isRecording = false;

  ///audio record
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;
  final _audioRecorder = Record();
  Amplitude? _amplitude;
  dynamic fileId;

  //bool _isUploading = false;
  var path;
  var saveDuration;
  Duration maxDuration = Duration(seconds: 3);
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final String? currentUserName =
      FirebaseAuth.instance.currentUser?.displayName;
  final String? currentUserphoto = FirebaseAuth.instance.currentUser?.photoURL;
  bool _isLoading = false;
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length,
      (_) => GroupBottomLayout._chars
          .codeUnitAt(_rnd.nextInt(GroupBottomLayout._chars.length))));

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

  /*void getToken()async{
    await FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        _token=value;
        print("token: $value");
      });}

    );
  }*/

  void sendPushMessage(name, msg, roomId) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAAqzRiIhI:APA91bF7X0RPFktJ6cU6gxWvx9sPpLWdJKlI7ujaiAl5mC62aAb0JIGwVNp_Hln5-TJLbRTI2gO9SuCghqaiCKGNzvI9nS-AAcAtxWg_j3Qm3tIUDe-9hhUYKtlyRFL0TOs56GojOIui',
          },
          body: jsonEncode(<String, dynamic>{
            'notification': <String, dynamic>{
              'body': msg,
              'title': "$name to ${widget.roomTitle}"
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              //"sound": "ringandroid.mp3",
            },
            "to": "/topics/$roomId"
          }));
    } catch (e) {
      print("error push notification: ${e.toString()}");
    }
  }

  ///Imagepicker
  File? _pickedImage;

  _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
      source: ImageSource.gallery, /*imageQuality: 50,maxWidth: 150*/
    );
    final pickedImageFile = File(pickedImage!.path);

    setState(() {
      _pickedImage = File(pickedImageFile.path);
    });
    _sendImage();
  }

  _sendImage() async {
    setState(() {
      _isLoading = true;
    });
    fileId = getRandomString(10);
    print(_pickedImage);
    if (_pickedImage != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_image')
          .child(fileId + '.jpg');
      await ref.putFile(_pickedImage!).whenComplete(() => null);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('groupChats')
          .doc(fileId)
          .set({
        'messageId': fileId,
        'userId': currentUserId,
        'text': "image",
        'time': Timestamp.now(),
        'roomId': widget.roomId,
        'name': currentUserName,
        'photo': currentUserphoto,
        'replyMessage': widget.replyMessage?.message,
        'replyMessageTime': widget.replyMessage?.replyMessageTime,
        'replyMessageDuration': widget.replyMessage?.duration,
        'replyMessageName': widget.replyMessage?.name,
        'file': url,
        'duration': '',
        'type': 'i',
        'chatId': widget.roomId,
        "replyMessagefile": widget.replyMessage?.file
      });
    }
    sendPushMessage(currentUserName, 'image...', widget.roomId);
    widget.onCancelReply();
    setState(() {
      _isLoading = false;
    });
  }

  ///slide key
  final GlobalKey<SlideActionState> _key = GlobalKey();

  ///text animation colors & style

  final colorizeColors = const [
    Colors.black54,
    Colors.white38,
    Colors.black54,
    Colors.white12,
    Colors.black54,
  ];

  final colorizeTextStyle = const TextStyle(
      fontSize: 15.0,
      //fontFamily: 'Horizon',
      color: Colors.black);

  ///sending
  final sendingColors = const [
    Colors.grey,
    Colors.white,
    Colors.grey,
  ];
  final sendingColorized = const TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.bold,
      //fontFamily: 'Horizon',
      color: Colors.grey);

  ///emoji
  _onEmojiSelected(Emoji emoji) {
    _controller
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
  }

  _onBackspacePressed() {
    _controller
      ..text = _controller.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
  }

  ///messaging
  void _sendMessage() async {
    //Future.delayed(Duration(milliseconds: 200));
    emojiShowing = false;
    fileId = getRandomString(10);

    //**Improment NOTE: you can make user and userdata variable global because we need the same detail in _stop function,so we dont call them twice

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    try {
      await FirebaseFirestore.instance
          .collection('groupChats')
          .doc(fileId)
          .set({
        'messageId': fileId,
        'text': _controller.text.trim(),
        'time': Timestamp.now(),
        'userId': currentUserId,
        'name': userData['name'],
        'photo': userData['photo'],
        'replyMessage': widget.replyMessage?.message,
        'replyMessageTime': widget.replyMessage?.replyMessageTime,
        'replyMessageDuration': widget.replyMessage?.duration,
        'replyMessageName': widget.replyMessage?.name,
        'file': '',
        'duration': '',
        'type': 't',
        'roomId': widget.roomId,
        "replyMessagefile": widget.replyMessage?.file
      });
    } on FirebaseException catch (e) {
      print(e.message);
    }

    sendPushMessage(currentUserName, _controller.text, widget.roomId);
    widget.onCancelReply();
    _controller.clear();
  }

  ///Audio record

  Future<void> _start() async {
    // if ( await Permission.microphone.request().isGranted)

    if (await Permission.microphone.request().isGranted) {
      fileId = getRandomString(10);

      Platform.isAndroid
          ? await _audioRecorder
              .start(path: '/data/user/0/com.jinxmenow/cache/$fileId.m4a')
              .then((_) {
              Future.delayed(Duration(minutes: 2)).then((_) async {
                isRecording ? _stop() : null;
              });
            })

          ///IOS Paths Note file name is included
          //simulator path
//path:'/Users/neosandredasilva/Library/Developer/CoreSimulator/Devices/FB844A55-0B5F-4F01-AC6C-7B18B28BF182/data/Containers/Data/$fileId.m4a'
          //real device path
          //path: '/private/var/mobile/Containers/Data/Application/47C5F143-5C90-4394-BF37-EA612A7A733B/tmp/$fileId.m4a'
          : await _audioRecorder.start();
      //stopping the record after 2 minutes
      /* .then((_){
      Future.delayed(Duration(minutes: 2)).then((_) async{
        isRecording? _stop():null;
      });
    } );*/

      // await _audioRecorder.isRecording();
      setState(() {
        isRecording = true;
        _recordDuration = 0;
      });

      _startTimer();
      // }

    } else {
      print('mic permission denied');
    }
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: TextStyle(color: Colors.white),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }

    return numberStr;
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });

    _ampTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      _amplitude = await _audioRecorder.getAmplitude();
      setState(() {});
    });
  }

  Future<void> _stop() async {
    setState(() {
      _isLoading = true;
    });
    _timer?.cancel();
    _ampTimer?.cancel();
    final path = await _audioRecorder.stop();

    //print(path);
    //if (mounted) {

    setState(() {
      isRecording = false;
    });
    // }

    //IMPORtant improvement make user and userdata glogal because we use it in send message function as well

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    try {
      final ref = await firebaseStorage
          .ref()
          .child('group_audio_messages')
          .child(fileId! + '.mp3');
      await ref
          .putFile(File.fromUri(Uri.parse(path!)))
          .whenComplete(() => null);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('groupChats')
          .doc(fileId) /*.doc(user.uid)*/ .set({
        'messageId': fileId,
        'userId': currentUserId,
        'text': 'audio message...',
        'name': userData['name'],
        'photo': userData['photo'],
        'type': 'a',
        'file': url,
        'replyMessage': widget.replyMessage?.message,
        'replyMessageTime': widget.replyMessage?.replyMessageTime,
        'replyMessageDuration': widget.replyMessage?.duration,
        'replyMessageName': widget.replyMessage?.name,
        'time': Timestamp.now(),
        'duration':
            '${_formatNumber(_recordDuration ~/ 60)}:${_formatNumber(_recordDuration % 60)}',
        'roomId': widget.roomId,
        "replyMessagefile": widget.replyMessage?.file
      });
      sendPushMessage(currentUserName, 'audio message', widget.roomId);
      widget.onCancelReply();
    } catch (error) {
      print('error occurred while uploading to firebase ${error.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('error occurred audio not sent'),
      ));
    } finally {
      /*   setState(() {
      _isUploading=false;
    });*/
      _audioRecorder.dispose();
    }
    setState(() {
      _isLoading = false;
    });
  }

  ///delete audio
  Future<File> get _localFile async {
    var _path = await _audioRecorder.stop();
    print('this the real device path $_path');
    return File.fromUri(Uri.parse(_path!));
  }

  deleteFile() async {
    final file = await _localFile;

    await file.delete();
    setState(() {
      isRecording = false;
    });
//print( '${_formatNumber(_recordDuration ~/ 60)}:${_formatNumber(_recordDuration % 60)}');
  }

  ///GIf
  Future<void> _saveGif(gif) async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    await FirebaseFirestore.instance
        .collection('chats') /*.doc(user.uid)*/ .add({
      'id': currentUserId,
      'name': userData['name'],
      'photo': userData['photo'],
      'type': 'g',
      'file': gif,
      'time': Timestamp.now(),
    });
  }

  ///Date

  @override
  void initState() {
    //isRecording = false;
    // TODO: implement initState
    super.initState();
    //recorder.init();
  }

  ///buttom sheet
  _bottomSheet(context) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (context) => Container(
        height: 300,
        width: 100,
        child: TextFormField(
          focusNode: widget.focusNode,
          onTap: () {},

          maxLines: 1,
          minLines: 1,

          //maxLength: 3,
          keyboardType: TextInputType.none,
          controller: _urlController,
          style: const TextStyle(fontSize: 20.0, color: Colors.black87),
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.purple,
              ),
              borderRadius: BorderRadius.circular(25.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.purple,
              ),
              onPressed: () {
                if (_urlController.text.isNotEmpty &&
                    isURL(_urlController.text)) {
                  _sendUrl();
                }
              },
            ),
            prefixIcon: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () => _urlController.clear()),
            hintText: 'https//:',
            hintStyle: TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.only(
              //left: 0.0,
              //bottom: 8.0,
              top: 15.0,
              // right: 16.0
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
        ),
      ),
    );
  }



  ///sendURL
  void _sendUrl() async {
    //Future.delayed(Duration(milliseconds: 200));
    emojiShowing = false;
    fileId = getRandomString(10);

    //**Improment NOTE: you can make user and userdata variable global because we need the same detail in _stop function,so we dont call them twice
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    FirebaseFirestore.instance.collection('groupChats').doc(fileId).set({
      'messageId': fileId,
      'text': _urlController.text,
      'time': Timestamp.now(),
      'userId': currentUserId,
      'name': userData['name'],
      'photo': userData['photo'],
      'replyMessage': widget.replyMessage?.message,
      'replyMessageTime': widget.replyMessage?.replyMessageTime,
      'replyMessageDuration': widget.replyMessage?.duration,
      'replyMessageName': widget.replyMessage?.name,
      'file': '',
      'duration': '',
      'type': 'u',
      'chatId': widget.roomId,
      'roomId': widget.roomId,
      "replyMessagefile": widget.replyMessage?.file
    });
    sendPushMessage(currentUserName, 'link...', widget.roomId);
    widget.onCancelReply();
    _urlController.clear();
    Navigator.pop(context);

  }

_sendEffects(String name)async{
  //Future.delayed(Duration(milliseconds: 200));
  emojiShowing = false;
  fileId = getRandomString(10);

  //**Improment NOTE: you can make user and userdata variable global because we need the same detail in _stop function,so we dont call them twice
  final userData = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .get();

  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  try {
    final ref = await firebaseStorage
        .ref();
  /*      .child('effects')
        .child('laughing1' + '.mp3');
    await ref
        .putFile(File.fromUri(Uri.parse(path!)))
        .whenComplete(() => null);*/
    final url =  await ref.child("effects/$name.mp3").getDownloadURL();;

    await FirebaseFirestore.instance
        .collection('groupChats')
        .doc(fileId) /*.doc(user.uid)*/ .set({
      'messageId': fileId,
      'userId': currentUserId,
      'text': 'audio $name...',
      'name': userData['name'],
      'photo': userData['photo'],
      'type': 'a',
      'file': url,
      'replyMessage': widget.replyMessage?.message,
      'replyMessageTime': widget.replyMessage?.replyMessageTime,
      'replyMessageDuration': widget.replyMessage?.duration,
      'replyMessageName': widget.replyMessage?.name,
      'time': Timestamp.now(),
      'duration':
      '${_formatNumber(_recordDuration ~/ 60)}:${_formatNumber(_recordDuration % 60)}',
      'roomId': widget.roomId,
      "replyMessagefile": widget.replyMessage?.file
    });

  } catch (error) {
    print('error occurred while uploading to firebase ${error.toString()}');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('error occurred audio not sent'),
    ));
  }
  sendPushMessage(currentUserName,'audio $name...' /*'link...'*/, widget.roomId);
  widget.onCancelReply();
  Navigator.pop(context);
}


  ///buttom sheet
  _bottomSheetEfects(context) async {
    await showModalBottomSheet(
      backgroundColor: Color(0xfff1efe5),
      isScrollControlled: false,
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (context) => Container(
        height: 225,
        width: double.infinity,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: ()=> _sendEffects('laughing1'), child: Text("Laugh",style: TextStyle(color: Colors.blue),overflow: TextOverflow.ellipsis,)),
              TextButton(onPressed: ()=> _sendEffects('laughing2'), child: Text("LaughHard",style: TextStyle(color: Colors.red),overflow: TextOverflow.ellipsis,)),
              TextButton(onPressed: ()=> _sendEffects('Cash'), child: Text("Cash",style: TextStyle(color: Colors.purple),overflow: TextOverflow.ellipsis,)),
              TextButton(onPressed: ()=> _sendEffects('Crickets'), child: Text("Crickets",style: TextStyle(color: Colors.black),overflow: TextOverflow.ellipsis,)),
              TextButton(onPressed: ()=> _sendEffects('Duck'), child: Text("Duck",style: TextStyle(color: Colors.green),overflow: TextOverflow.ellipsis,)),
              //TextButton(onPressed: ()=> _sendEffects('Fail2'), child: Text("Fail",style: TextStyle(color: Colors.blue),)),
            ],),
  Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: ()=> _sendEffects('Fail2'), child: Text("Fail",style: TextStyle(color: Colors.brown),overflow: TextOverflow.ellipsis,)),
              TextButton(onPressed: ()=> _sendEffects('Fart2'), child: Text("Fart",style: TextStyle(color: Colors.orange),overflow: TextOverflow.ellipsis,)),
              TextButton(onPressed: ()=> _sendEffects('Heartbeat'), child: Text("Heartbeat",style: TextStyle(color: Colors.blueGrey),overflow: TextOverflow.ellipsis,)),
              TextButton(onPressed: ()=> _sendEffects('Kids Cheering'), child: Text("Cheering",style: TextStyle(color: Colors.cyan),overflow: TextOverflow.ellipsis,)),
              TextButton(onPressed: ()=> _sendEffects('Painful Scream'), child: Text("Scream",style: TextStyle(color: Colors.grey),overflow: TextOverflow.ellipsis,)),


            ],),
          Container(

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(onPressed: ()=> _sendEffects('People Clapping'), child: Text("Clap",style: TextStyle(color: Colors.blue),overflow: TextOverflow.ellipsis,)),
                TextButton(onPressed: ()=> _sendEffects('Punch1'), child: Text("Punch",style: TextStyle(color: Colors.grey),overflow: TextOverflow.ellipsis,)),
                TextButton(onPressed: ()=> _sendEffects('Reloading'), child: Text("Reload",style: TextStyle(color: Colors.brown),overflow: TextOverflow.ellipsis,)),
                TextButton(onPressed: ()=> _sendEffects('SadMusic'), child: Text("SadMusic",style: TextStyle(color: Colors.green),overflow: TextOverflow.ellipsis,)),
                TextButton(onPressed: ()=> _sendEffects('Scratch2'), child: Text("Scratch",style: TextStyle(color: Colors.blueGrey),overflow: TextOverflow.ellipsis,)),


              ],),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: ()=> _sendEffects('Slap'), child: Text("Slap",style: TextStyle(color: Colors.black),overflow: TextOverflow.ellipsis,)),
              TextButton(onPressed: ()=> _sendEffects('Wrong'), child: Text("Wrong",style: TextStyle(color: Colors.purple),overflow: TextOverflow.ellipsis,)),
              TextButton(onPressed: ()=> _sendEffects('djhorn'), child: Text("DjHorn",style: TextStyle(color: Colors.orange),overflow: TextOverflow.ellipsis,)),
              TextButton(onPressed: ()=> _sendEffects('kiss'), child: Text("Kiss",style: TextStyle(color: Colors.red),overflow: TextOverflow.ellipsis,)),
              TextButton(onPressed: ()=> _sendEffects('stupid'), child: Text("Stupid",style: TextStyle(color: Colors.grey),overflow: TextOverflow.ellipsis,)),


            ],),

        ],)
      ),
    );
  }



  @override
  void dispose() {
    _timer?.cancel();
    _ampTimer?.cancel();
    _audioRecorder.dispose();
    // recorder.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final isreplying= widget.replyMessage !='';

    return Column(

        children: [
          //Expanded(child: Container()),
          _isLoading ? buildSending() : Container(),
          if (widget.replyMessage != null) buildReply(),
          Container(
              height: 50,
              width: 400,
              margin:/* FocusScope.of(context).hasFocus? EdgeInsets.only(bottom:1): */EdgeInsets
                  .only(bottom: 20),
              decoration: BoxDecoration(

                  color: isRecording ? Colors.red : Color(0xfff1efe5),
                  borderRadius: BorderRadius.circular(40)),
              child: isRecording
                  ?

              ///Recording layout

              Center(
                child: Builder(
                  builder: (context) {
                    return Container(
                      ///width:0.1 got deleted
                      //width: 0.1,
                      ///add padding 20 back
                      //padding: EdgeInsets.all(20),
                      child: SlideAction(

                        elevation: 0,
                        outerColor: Colors.transparent,
                        innerColor:
                        isRecording ? Colors.purple : Colors.transparent,
                        reversed: true,

                        ///add row back
                        child: Row(
                          //crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: InkWell(
                                    onTap: () async {
                                      await _stop();
                                    },
                                    child: Icon(
                                      Icons.send,
                                      color: Colors.purple,
                                    ))),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: _buildTimer(),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Icon(
                              Icons.arrow_back_ios,
                              size: 20,
                            ),
                            SizedBox(
                              //width: 250.0,
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  ColorizeAnimatedText(
                                    'Slide to cancel',
                                    //speed:Duration(seconds: 2),

                                    textStyle: colorizeTextStyle,
                                    colors: colorizeColors,
                                  ),
                                ],
                                repeatForever: true,
                                onTap: null,
                              ),
                            ),
                          ],
                        ),

                        ///delete text

                        sliderButtonIcon: Icon(Icons.mic),

                        submittedIcon: const Icon(
                          Icons.delete,
                          color: Colors.black,
                        ),

                        key: _key,
                        onSubmit: () {
                          Future.delayed(
                            Duration(microseconds: 20),
                                () => deleteFile(),
                            /* Future.delayed(
                          Duration(seconds: 1),
                              () => _key.currentState?.reset(),*/
                          );
                        },
                      ),
                    );
                  },
                ),
              )
                  :

              ///Normal layout
              Row(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 1),
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: () => _bottomSheet(context),
                        icon: const Icon(
                          Icons.link,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  /* Material(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            emojiShowing = !emojiShowing;
                          });
                        },
                        icon: const Icon(
                          Icons.emoji_emotions,
                          color: Colors.black,
                        ),
                      ),
                    ),*/

                  GestureDetector(

                    onTap:  () => _pickFromGallery(),
                    child: Icon(

                      Icons.image,
                      color: Colors.black,
                      size:20,
                    ),
                  ),

                  Container(
                    height: 40,
                    width: 200,
                    padding: EdgeInsets.only(left: 10),
                    //margin: EdgeInsets.only(top: 10),
                    child:

                    ///textfield

                    Column(
                      children: [
                        Expanded(
                          child: TextField(
                            enableInteractiveSelection: false,
                            //focusNode: focusNodelocal,
                            onTap: () {

                              if (FocusScope.of(context).hasFocus){

                                FocusScope.of(context).unfocus();
                              }

                            },

                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
                            minLines: 1,
                            autocorrect: false,
                            cursorColor: Colors.purple,
                            controller: _controller,
                            /* style: const TextStyle(
                                  fontSize: 20.0, color: Colors.black87),*/
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.purple,
                                ),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              prefixIcon:   GestureDetector(
                                onTap: ()=>_bottomSheetEfects(context) ,
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.purple,
                                  size: 15,
                                ),
                              ),



                              // alignLabelWithHint: true,
                              hintText: 'speak your mind...',
                              hintStyle: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 15),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.only(
                                //left: 0.0,
                                //bottom: 8.0,
                                  top: 15.0,
                                  right: 5.0
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: /*_controller.text.trim().isEmpty ? null:*/ () {
                        if (_controller.text.isEmpty) {
                        } else {
                          _sendMessage();
                          // widget.onSendMessageClick();
                        }
                      },
                      icon: const Icon(
                        Icons.send,
                        color: /*_controller.text.trim().isEmpty ? Colors.grey:*/ Colors
                            .purple,
                      )),

                  ///Icon Mic
                  Platform.isAndroid
                      ? Expanded(
                      child: Container(
                        padding: EdgeInsets.only(right: 20),
                        child: IconButton(
                          icon: Icon(
                            Icons.mic,
                          ),
                          color: Colors.black,
                          onPressed: () {

                            _start();

                          },
                        ),
                      ))
                      : IconButton(
                    icon: Icon(
                      Icons.mic,
                    ),
                    color: Colors.black,
                    onPressed: () {
                      _start();
                    },
                  ),
                ],
              )),
          /*Offstage(
        offstage: !emojiShowing,
        child: SizedBox(
          height: 250,

        ),
      ),*/
        ]);
  }

  Widget buildReply() => Container(

      //color: Colors.grey,
      width: 400,
      decoration: BoxDecoration(
          color: Color(0xfff1efe5),
          borderRadius: BorderRadius.all( Radius.circular(10) )),
           child: ReplyMessageWidget(widget.replyMessage!, widget.onCancelReply));

  Widget buildSending() => Container(
        //color: Colors.grey,

        child: AnimatedTextKit(
          animatedTexts: [
            ColorizeAnimatedText(
              'Sending...',
              //speed:Duration(seconds: 2),

              textStyle: sendingColorized,
              colors: sendingColors,
            ),
          ],
          repeatForever: true,
          onTap: null,
        ),
      );
}
