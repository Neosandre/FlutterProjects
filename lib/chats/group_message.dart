import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jinx/chats/group_message_bubles.dart';
import 'package:jinx/models/message_model.dart';

import 'package:jinx/widgets/audio_player/audioplayer.dart';
import 'package:jinx/widgets/urlbubble.dart';

import 'package:swipe_to/swipe_to.dart';

import '../widgets/groupbubbles/group_audio_message.dart';
import '../widgets/groupbubbles/group_image_message.dart';
import '../widgets/groupbubbles/group_url_message.dart';
import 'image_buble.dart';
import 'message_buble.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

import 'package:intl/intl.dart';

class GroupMessage extends StatelessWidget {
  final ValueChanged<MessageModel> onSwipedMessage;
  final roomId;
  GroupMessage(this.onSwipedMessage,this.roomId);

  // @override
  // State<Messages> createState() => _MessagesState();
//}

//class _MessagesState extends State<Messages> {
  //final ItemScrollController itemScrollController = ItemScrollController();

  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final currentUserId=FirebaseAuth.instance.currentUser!.uid;
  final storageRef = FirebaseStorage.instance.ref();


  @override
  Widget build(BuildContext context) {
    // var cdetails= new Club.fromMap(clubDetail.title);
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('groupChats').where('roomId',isEqualTo: roomId ).orderBy('time',descending: true).snapshots(),
      builder: (ctx,AsyncSnapshot<QuerySnapshot> chatSnapshot){
        if (chatSnapshot.hasData){

          final chatDocs=chatSnapshot.data!.docs;

          return ListView.builder(
            //initialScrollIndex: 0,

            /*  key: PageStorageKey<String>('message123'),
              itemPositionsListener:itemPositionsListener,
              itemScrollController: itemScrollController,*/
              padding: EdgeInsets.only(bottom: 0),
              reverse: true,
              itemCount: chatDocs.length,
              //Text(chatDocs[index]['text']
              itemBuilder: (ctx, index)
              {



                DateTime dateTime = DateTime.parse(
                    chatDocs[index]['time'].toDate().toString());
                var formattedTime = DateFormat.Hm().format(dateTime);

                if (DateTime
                    .now()
                    .difference(dateTime)
                    .inHours > 24) {
                  FirebaseFirestore.instance.collection('groupChats')
                      .doc(chatDocs[index].id)
                      .delete();


                  // Create a reference to the file to delete
                  final desertRef = storageRef.child("chat_image/${chatDocs[index].id}.jpg");
                  desertRef.delete();
                }

                final message=  MessageModel(
                  name:chatDocs[index]['name'],
                  userId:chatDocs[index]['userId'] ,
                  message:chatDocs[index]['text'],
                  replyMessage:chatDocs[index]['replyMessage'],
                  replyMessageTime: formattedTime,
                  replyMessageDuration: chatDocs[index]['replyMessageDuration'],
                  duration: chatDocs[index]['duration'],
                  displayMessageTime: chatDocs[index]['replyMessageTime'],
                  replyMessageName: chatDocs[index]['replyMessageName'],
                  photo: chatDocs[index]['photo'],
                  file:chatDocs[index]['file'],
                  type: chatDocs[index]['type'],
                    replyMessagefile: chatDocs[index]['replyMessagefile'],
                  messageId: chatDocs[index]['messageId']
                );



                switch (chatDocs[index]['type']){
                  case 't':
                    return  SwipeTo(
                      iconOnRightSwipe: Icons.reply,
                      //animationDuration: Duration(seconds: 2),
                      iconColor: Color(0xfff1efe5),
                      onRightSwipe: () => onSwipedMessage(message),
                      child: GroupMessageBubble(
                        message,
                        formattedTime,
                        chatDocs[index]['userId']==currentUserId,
                        ValueKey(chatDocs[index].id),
                      ),
                    );

                  case 'a':
                    return SwipeTo(
                      iconOnRightSwipe: Icons.reply,
                      //animationDuration: Duration(seconds: 2),
                      iconColor: Color(0xfff1efe5),
                      onRightSwipe: () => onSwipedMessage(message),
                      child: GroupAudioplayerMessage(
                        message,
                        formattedTime,
                        chatDocs[index]['userId']==currentUserId,
                        //chatDocs[index]['userId'] == user!.uid,
                        ValueKey(chatDocs[index].id),
                      ),
                    );
                case 'u':
                  return  SwipeTo(
                    iconOnRightSwipe: Icons.reply,
                    //animationDuration: Duration(seconds: 2),
                    iconColor: Color(0xfff1efe5),
                    onRightSwipe: () => onSwipedMessage(message),
                    child: GroupUrlBubble(
                      message,
                      formattedTime,
                      chatDocs[index]['userId']==currentUserId,
                      ValueKey(chatDocs[index].id),
                    ),
                  );
                  case 'i':
                    return  SwipeTo(
                      iconOnRightSwipe: Icons.reply,
                      //animationDuration: Duration(seconds: 2),
                      iconColor: Color(0xfff1efe5),
                      onRightSwipe: () => onSwipedMessage(message),
                      child: GroupImageBubble(
                        message,
                        formattedTime,
                        chatDocs[index]['userId']==currentUserId,
                        ValueKey(chatDocs[index].id),
                      ),
                    );
                }
                return Container();
              });
        } return Container();
      },
    );
  }
}
