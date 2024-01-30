import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinx/screens/zoomimage.dart';
import 'package:jinx/widgets/replymessagewidget.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../models/message_model.dart';




class GroupImageBubble extends StatelessWidget {


  final MessageModel message;
  final time;
  final bool isMe;
  final Key key;

  GroupImageBubble(
      this.message,
      this.time,
      this.isMe,
      this.key
      );

  final currentUserId=FirebaseAuth.instance.currentUser!.uid;
  final String? currentUserName = FirebaseAuth.instance.currentUser?.displayName;


  report (context)async{
    showDialog(context: context, builder: (context){return AlertDialog(
backgroundColor: Color(0xfff1efe5),
        title: Text('Report message',style:TextStyle(color:Colors.red )),
        content: Text('are you sure you want to report this message?'),
        actions: [
          TextButton(
              child: Text(
                'Yes',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              onPressed:  ()async{
                print(isMe);
                await FirebaseFirestore.instance.collection('reports').doc(message.messageId).collection('details').doc(currentUserId).set({
                  'reportedTime':DateTime.now(),
                  'reportedById':currentUserId,
                  'reportedBy':currentUserName,
                  'messageId':message.messageId,
                  'messageOwner':message.name,
                  'messageOwnerId':message.messageId,
                  'message':message.file,
                  'type':'messageGroup'


                });


                Navigator.of(context).pop();
                showDialog(context: context, builder: (context){return AlertDialog(
                    backgroundColor: Color(0xfff1efe5),
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



  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress:!isMe? ()=>report(context):null,
      onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>ZoomImage(message.file))),
      child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: isMe?MainAxisAlignment.end :MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            !isMe? Padding(
              padding: EdgeInsets.only(left: 5),
              child:CachedNetworkImage(
                imageUrl: message.photo,
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
            ):Container(),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                !isMe?Padding(

                  padding: EdgeInsets.only(left: 20,top:2),
                  child: Text(
                    //5f use username straight in here
                    //display min&sec only: ${_position.toString().split(':')[1]}:${_position.toString().split(':')[2].split('.')[0]}
                      message.name,
                      style: TextStyle(//fontSize: ,
                          fontWeight: FontWeight.bold,color: Colors.white

                      )
                  ),
                ):Container(),

                if (message.replyMessage != null)Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: buildReply(),
                ),
                //if (message.replyMessage != null)SizedBox(height:5,),
                Container(
                  //key: key,
                  decoration: BoxDecoration(
                    color: isMe?Colors.purple:Colors.brown,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: !isMe? Radius.circular(0):Radius.circular(12),
                      bottomRight: isMe? Radius.circular(0):Radius.circular(12),

                    ),


                  ),
                  // width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(
                      vertical: 1,
                      horizontal: 1
                  ),
                  margin: const EdgeInsets.symmetric(
                      vertical: 1,
                      horizontal:5
                  ),

                  child: Column(

                    //putting the text to on the corner of the bubble
                    crossAxisAlignment: CrossAxisAlignment.start,
                    //mainAxisAlignment:MainAxisAlignment.start ,
                    children: <Widget> [

                      Container(
                          height: 305,
                          width: 205,

                          child: ClipRRect(
                            child:CachedNetworkImage(

                              imageUrl: message.file,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Text("loading...",style: TextStyle(color: Colors.grey),),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                            borderRadius: BorderRadius.circular(5),

                          )),
                    ],
                  ) ,
                ),
                Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Text('${time}',style: TextStyle(color: Colors.white,fontSize: 8),)),

              ],
            ),

          ]),
    );



  }
  Widget buildReply() => Container(

    //color: Colors.grey,
      width: 100,
      decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all( Radius.circular(10),
            //topRight:  Radius.circular(10)
          )
      ),
      child:DisplayReplyMessageWidget(
        message,
      ));
}
