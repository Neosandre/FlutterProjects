import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jinx/chats/image_buble.dart';
import 'package:jinx/models/message_model.dart';

import 'package:jinx/widgets/audio_player/audioplayer.dart';

import 'package:swipe_to/swipe_to.dart';

import '../widgets/urlbubble.dart';
import 'message_buble.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:intl/intl.dart';

class Messages extends StatefulWidget {
  final ValueChanged<MessageModel> onSwipedMessage;
  final String chatId;
  Messages(this.onSwipedMessage,this.chatId);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  //final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  final currentUserId=FirebaseAuth.instance.currentUser!.uid;

  final storageRef = FirebaseStorage.instance.ref();

  @override
  Widget build(BuildContext context) {
    // var cdetails= new Club.fromMap(clubDetail.title);
    return StreamBuilder(

      stream: FirebaseFirestore.instance.collection('chats').where('chatId',isEqualTo:widget.chatId).orderBy('time',descending: true).snapshots(),
      builder: (ctx,AsyncSnapshot<QuerySnapshot> chatSnapshot){
        if (chatSnapshot.hasData){


          final chatDocs=chatSnapshot.data!.docs;

          return /*ScrollablePositionedList.builder*/ ListView.builder(

            //initialScrollIndex: 0,

            // key: PageStorageKey<String>('message123'),
            //itemPositionsListener:itemPositionsListener,
            //itemScrollController: itemScrollController,
              padding: EdgeInsets.only(bottom: 1),
              reverse: true,

              addAutomaticKeepAlives:true ,

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
                  FirebaseFirestore.instance.collection('chats')
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
                      onRightSwipe: () => widget.onSwipedMessage(message),
                      child:
                          MessageBubble(
                          message,
                          formattedTime,
                          chatDocs[index]['userId']==currentUserId,
                          ValueKey(chatDocs[index].id),
                        )


                    );

                  case 'a':
                    return SwipeTo(
                      iconOnRightSwipe: Icons.reply,
                      //animationDuration: Duration(seconds: 2),
                      iconColor: Color(0xfff1efe5),
                      onRightSwipe: () => widget.onSwipedMessage(message),


                        child: AudiopayerMessage(
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
                      onRightSwipe: () => widget.onSwipedMessage(message),
                      child: UrlBubble(
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
                      onRightSwipe: () => widget.onSwipedMessage(message),
                      child: ImageBubble(
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

