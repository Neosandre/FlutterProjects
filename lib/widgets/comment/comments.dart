import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'comment_bubble.dart';


class Comments extends StatelessWidget {

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final postId;

  Comments(this.postId);

  var formattedTime;
  getTimeDifferenceFromNow(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 5) {
      formattedTime= "Just now";
    } else if (difference.inMinutes < 1) {
      formattedTime= "${difference.inSeconds}s";
    } else if (difference.inHours < 1) {
      formattedTime= "${difference.inMinutes}m";
    } else if (difference.inHours < 24) {
      formattedTime= "${difference.inHours}h";
    } else {
      formattedTime= "${difference.inDays}d";
    }
  }
  @override
  Widget build(BuildContext context) {


    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('comments').where('postId',isEqualTo: postId).orderBy('time',descending: true).snapshots(),
      builder: (ctx,AsyncSnapshot<QuerySnapshot> chatSnapshot){


        if (chatSnapshot.hasData){

          /*if (chatSnapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }*/
          final chatDocs=chatSnapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 0),
              reverse: true,
              itemCount: chatDocs.length,
              //Text(chatDocs[index]['text']
              itemBuilder: (ctx, index){

                DateTime dateTime = DateTime.parse(
                    chatDocs[index]['time'].toDate().toString());
                //var formattedTime =/*DateFormat('EEEE, d MMM, yyyy').format(dateTime)*/ DateFormat.MMMd().add_jm().format(dateTime);
                getTimeDifferenceFromNow(dateTime);
                 return CommentBubble(
                    chatDocs[index]['text'],
                    chatDocs[index]['name'],
                    chatDocs[index]['photo'],
                   formattedTime,
                   chatDocs[index]['commentId'],
                    chatDocs[index]['postOwnerId'],
                    postId,
                   chatDocs[index]['userId'],
                    //chatDocs[index]['userId'] == user!.uid,
                    ValueKey(chatDocs[index].id),

                  );}

          );


        } return Container();},
    );
  }
}

class CommentCount extends StatefulWidget {

  final storyId;
  CommentCount(this.storyId);


  @override
  State<CommentCount> createState() => _CommentCountState();
}

class _CommentCountState extends State<CommentCount> {
  var ess=0;

  List <String> comLen=[];
  getComments()async{

    QuerySnapshot snapshot=await FirebaseFirestore.instance.collection('comments').where('storyId',isEqualTo: widget.storyId).get();

    snapshot.docs.forEach((doc){

      comLen.add(doc.id);

    });
    if(mounted)
      setState(() {
        ess = comLen.length;
      });
  }


  @override
  void initState() {
    getComments();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Text('$ess',
        style: TextStyle(color: Colors.white));
  }
}
