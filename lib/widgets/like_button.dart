import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinx/widgets/likelist.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';


class LikeButtonWidget extends StatefulWidget {
  final postId;
  final  likedBy;
  final userId;
  //final VoidCallback onClicked;
  LikeButtonWidget(this.postId,this.likedBy,this.userId,/*this.onClicked*/);

  @override
  State<LikeButtonWidget> createState() => _LikeButtonWidgetState();
}

class _LikeButtonWidgetState extends State<LikeButtonWidget> {

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  List likesList=[];
  ///foumula tgo format numbers to show 1k
  /*final _num = 150000;

 int? count;
fomartCount(length){
  if (length >= 1000) {
    var _formattedNumber = NumberFormat.compact().format(length).toLowerCase();

   return  _formattedNumber;
  } else {


    return length;

  }


}*/



  Future<bool> onLikeButtonTapped(bool isLiked) async{

    if(widget.likedBy.contains(currentUserId) == false)
    {
     onLike();

    }
    else{
      onDislike();
    }

    return isLiked=!isLiked;
  }

  onLike()async{
    print("User: ${widget.userId}");
    print("current: ${currentUserId}");
    Future.delayed(Duration(milliseconds: 500), () async{
      await FirebaseFirestore.instance.collection('post').doc(widget.postId).update({
        "likedBy":FieldValue.arrayUnion([currentUserId])
      });
      final userData = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
      FirebaseFirestore.instance.collection('likes').doc(widget.postId).collection('userLiked').doc(currentUserId).set({
        'time': Timestamp.now(),
        'userId': currentUserId,
        'name': userData['name'],
        'photo': userData['photo'],
        'postId': widget.postId,
      });


      if(currentUserId != widget.userId)  {

       await FirebaseFirestore.instance
            .collection('feed')
            .doc(widget.userId)
            .collection('feedItems')
            .doc(currentUserId) .set({
          'type': 'like',
          'uuid': currentUserId,
          'name': userData['name'],
          'photo': userData['photo'],
          'timestamp': DateTime.now(),
          'channel': '',
          'selected': false,
          'postId': widget.postId,
        });
      }
      // Do something
    });


  }

  onDislike()async{
   /* setState(() {

      widget.likedBy.remove(currentUserId);
    });*/

    Future.delayed(Duration(milliseconds: 500), ()async {
      var val=[];   //blank list for add elements which you want to delete
      val.add(currentUserId);

      await FirebaseFirestore.instance.collection('post').doc(widget.postId).update({
        "likedBy":FieldValue.arrayRemove(val)
      }).then((value) => FirebaseFirestore.instance.collection('likes').doc(widget.postId).collection('userLiked').doc(currentUserId).delete());
      // Do something
    });



  }

  _likeList( context) async {
    //storyId = storyId;
    await showModalBottomSheet(
      //constraints: BoxConstraints.expand(),
        backgroundColor: /*Color(0xfff1efe5)*/Colors.black,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('close keyboard to send comment',style: TextStyle(color: Colors.purple),),
              Container(
                  padding: EdgeInsets.only(
                    left: 5, right: 5, top: 5,),
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.4,
                  width: double.infinity,
                  child: GestureDetector(onTap:(){ FocusScope.of(context).requestFocus(new FocusNode());},
                      //Note: storyFile is actually storyId
                      
                  )
              ),
            ],
          );
        }
    );
  }



  @override
  void initState() {
   //fomartCount(widget.likedBy.length);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        LikeButton(
          size: 25,
          circleColor:
          CircleColor(start: Colors.white, end: Colors.purple),
          bubblesColor: BubblesColor(
            dotPrimaryColor: Colors.purple,
            dotSecondaryColor: Colors.white,
          ),
          isLiked:widget.likedBy.contains(currentUserId) ,
          onTap: onLikeButtonTapped,
          //animationDuration: Duration(milliseconds: 500),
          likeBuilder: (bool isLiked) {
            //isLiked = widget.likedBy.contains(currentUserId);
            return Icon(
              Icons.favorite,
              color: isLiked ? Colors.purple : Colors.white,
              size: 25,
            );
          },
          likeCount: widget.likedBy.length,

          countBuilder: (int? count, bool isLiked, String text) {
             //isLiked = widget.likedBy.contains(currentUserId);
            var color = isLiked ? Colors.white : Colors.white;
            Widget result;
            //count = widget.likedBy.length;

            if (count! >=1000) {
              //count++;
              var num= NumberFormat.compact().format(count).toLowerCase();
              result = Text(num,
                style: TextStyle(color: color),
              );
            } else
              result = Text(
                text,
                style: TextStyle(color: color),
              );
            return result;
          },
        ),
SizedBox(width: 5,),
GestureDetector(
    onTap:()=>Navigator.push(context, MaterialPageRoute(builder: (ctx)=>LikeList(widget.postId))),
    child: Text('likes',style: TextStyle(color: Colors.white),))
        /*widget.likedBy.contains(currentUserId)  ? IconButton(
          padding: EdgeInsets.only(left: 3),
          color: Colors.white,
          icon:  Icon(Icons.favorite_outlined, size: 30,color: Colors.purple,),
          //onPressed:  widget.onClicked
          onPressed:() async{
          //print('dislike in likebutton');

            setState(() {

            });
            widget.likedBy.remove(currentUserId);
   var val=[];   //blank list for add elements which you want to delete
   val.add(currentUserId);
   await FirebaseFirestore.instance.collection('post').doc(widget.postId).update({
     "likedBy":FieldValue.arrayRemove(val)
   });
            await FirebaseFirestore.instance.collection('likes').doc(widget.postId).collection('userLiked').doc(currentUserId).delete();
          },
        ):IconButton(
          padding: EdgeInsets.only(left: 3),
          color: Colors.white,
          icon:  Icon(Icons.favorite_outlined, size: 30,color: Colors.white,),
          onPressed:() async {
            print('like in likebutton');
            likesList=widget.likedBy;
            likesList.add(currentUserId);
            setState(() {

            });


            FirebaseFirestore.instance.collection('post').doc(widget.postId).update({
              'likedBy':likesList
            });
            final userData = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
            FirebaseFirestore.instance.collection('likes').doc(widget.postId).collection('userLiked').doc(currentUserId).set({
              'time': Timestamp.now(),
              'userId': currentUserId,
              'name': userData['name'],
              'photo': userData['photo'],
              'postId': widget.postId,
            });

    if(currentUserId != widget.userId)  {
                    FirebaseFirestore.instance
                        .collection('feed')
                        .doc(widget.userId)
                        .collection('feedItems')
                        *//*.doc(currentUserId)*//* .add({
                      'type': 'like',
                      'uuid': currentUserId,
                      'name': userData['name'],
                      'photo': userData['photo'],
                      'timestamp': DateTime.now(),
                      'channel': '',
                      'selected': false,
                      'postId': widget.postId,
                    });
                  }
                },
        ),*/

       /* InkWell(
            onTap: (){Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>  LikeList(
                      widget.postId,
                    )));},
            child: Text(  '${widget.likedBy.length}'  //widget.likedBy.length <1000?'${widget.likedBy.length}':'${fomartCount(widget.likedBy.length)}'
              , style:  TextStyle(color: Colors.white),)
        ),*/
      ],
    );
  }
}
