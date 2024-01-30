
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:jinx/models/message_model.dart';


import '../replymessagewidget.dart';
class GroupAudioplayerMessage extends StatefulWidget {


  final MessageModel message;

  final time;
  final bool isMe;
  final Key key;
/*
  AudiopayerMessage(

      this.message,
      this.time,
      this.isMe,
      this.key
      );*/
  GroupAudioplayerMessage(  this.message,
      this.time,
      this.isMe,
      this.key):super(key:ValueKey(key));

  @override
  _GroupAudioplayerMessageState createState() => _GroupAudioplayerMessageState();
}

class _GroupAudioplayerMessageState extends State<GroupAudioplayerMessage> {
  AudioPlayer _audioPlayer = new AudioPlayer();
  Duration _duration = new Duration();
  Duration _position = new Duration();


  bool _isPlaying =false;
  bool _isPaused =false;
  int? tempo;



  final currentUserId=FirebaseAuth.instance.currentUser!.uid;
  final String? currentUserName = FirebaseAuth.instance.currentUser?.displayName;


  report (context)async{
    showDialog(context: context, builder: (context){return AlertDialog(

        title: Text('Report message',style:TextStyle(color:Colors.red )),
        backgroundColor: Color(0xfff1efe5),
        content: Text('are you sure you want to report this message?'),
        actions: [
          TextButton(
              child: Text(
                'Yes',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              onPressed:  ()async{

                await FirebaseFirestore.instance.collection('reports').doc(widget.message.messageId).collection('details').doc(currentUserId).set({
                  'reportedTime':DateTime.now(),
                  'reportedById':currentUserId,
                  'reportedBy':currentUserName,
                  'messageId':widget.message.messageId,
                  'messageOwner':widget.message.name,
                  'messageOwnerId':widget.message.messageId,
                  'message':widget.message.file,
                  'type':'messageGroup'


                });


                Navigator.of(context).pop();
                showDialog(context: context, builder: (context){return AlertDialog(
                  backgroundColor: Color(0xfff1efe5),
                  content: Text("Report sent",style: TextStyle(color: Colors.purple),),);});
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



  // var url= 'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3';
  @override
  void initState() {

    // TODO: implement initState
    super.initState();

    _audioPlayer.onDurationChanged.listen((Duration dd) {
      //print('essa ea dueraceo: $dd');
      if(mounted)
        setState(() {
          _duration = dd;
        });
    });

    _audioPlayer.onPositionChanged.listen((Duration dd) {
      if(mounted)
        setState(() {
          _position = dd;
        });
    });

    // _audioPlayer.setUrl(widget.file);
  }
  @override
  void didUpdateWidget(covariant GroupAudioplayerMessage oldWidget) {


    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }
  ///DURATION





  @override
  Widget build(BuildContext context) {

    return InkWell(
      onLongPress:!widget.isMe? ()=>report(context):null,
      child: Row(
          mainAxisSize: MainAxisSize.min,
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: widget.isMe?MainAxisAlignment.end :MainAxisAlignment.start,
          children: <Widget> [
            !widget.isMe? Padding(
              padding: EdgeInsets.only(left: 5),
              child: CachedNetworkImage(
                imageUrl: widget.message.photo,
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
                !widget.isMe? Padding(

                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    //5f use username straight in here
                    //display min&sec only: ${_position.toString().split(':')[1]}:${_position.toString().split(':')[2].split('.')[0]}
                      widget.message.name,
                      style: TextStyle(//fontSize: ,
                          fontWeight: FontWeight.bold,color: Colors.white

                      )
                  ),
                ):Container(),
                if (widget.message.replyMessage != null)Padding(

                  padding: EdgeInsets.only(left: 7),
                  child: buildReply(),
                ),

                Container(

                  /*  height: widget.message.replyMessage != null && widget.message.replyMessage =="image"?165
                      :widget.message.replyMessage != null? 135:45,*/
                  width: 300,
                  decoration: BoxDecoration(
                      color: widget.isMe?Colors.purple:Colors.brown,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: !widget.isMe? Radius.circular(0):Radius.circular(12),
                        bottomRight: widget.isMe? Radius.circular(0):Radius.circular(12),

                      )),
                  // width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(
                      vertical: 1,
                      horizontal: 1
                  ),
                  margin: const EdgeInsets.symmetric(
                      vertical: 1,
                      horizontal:5
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      playIcon(),
                      Text(//5f use username straight in here
                        //display min&sec only: ${_position.toString().split(':')[1]}:${_position.toString().split(':')[2].split('.')[0]}
                          /*!_isPlaying?
                          //note:release setURl in Initstate
                          *//*'${_duration.toString().split(':')[1]}:${_duration.toString().split(':')[2].split('.')[0]}'*//*
                          '${widget.message.duration}'
                              :*/'${_position.toString().split(':')[1]}:${_position.toString().split(':')[2].split('.')[0]}',
                          style: TextStyle(//fontSize: ,
                            color: Colors.black,

                          )
                      ),
                      SizedBox(
                          width: 200,
                          //height: 60,
                          child: slider()),

                    ],),

                ),

                Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Text('${widget.time}',style: TextStyle(color: Colors.white,fontSize: 8),)),
              ],
            ),

          ]),
    );

  }
  Widget slider (){
    return FittedBox(
      alignment: Alignment.center,
      fit: BoxFit.fill,
      child: SliderTheme(
        key: widget.key,
        data:SliderThemeData(
          trackHeight: 2,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius:5 ),
          /* thumbColor: Colors.black,
          activeTrackColor: Colors.black*/
        ) ,
        child: Slider(

            min: 0.0,
            value:_position.inSeconds.toDouble(),
            max:  _duration.inSeconds.toDouble(),
            onChanged: (double value){

                setState(() {
                  _audioPlayer.seek(Duration(seconds: value.toInt()));

                });

            }),
      ),
    );
  }

  Widget playIcon (){

    return  InkWell(
      onTap: (){
        getAudio();
        setState(() {
          _isPlaying=!_isPlaying;
        });


      },
      child: Icon(

        _isPlaying?Icons.pause_circle_outline:Icons.play_circle_outline,key: widget.key,color: Colors.blue,),);
  }

  void getAudio()async {
    // var url = widget.file;
    //'https://www.kozco.com/tech/WAV-MP3.wav';
    //'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3';
    //tempo= await _audioPlayer.setUrl(url);

///############flutter new v error audio###################
    if (_isPlaying) {
      var res = /*await*/ _audioPlayer.pause();
      if (res == 1) {
        if(mounted)
          setState(() {
            _isPlaying = false;
            _isPaused = true;
          });
      }
    } else {
      var res = _isPaused ? /*await*/ _audioPlayer.resume() : /*await*/ _audioPlayer
          .play(UrlSource(widget.message.file));
      //await Future.delayed(Duration(milliseconds: 200));

      if (res == 1) {
        if(mounted)
          setState(() {
            _isPlaying = true;
            _isPaused = false;
          });
      }
    }
    _audioPlayer.onPlayerStateChanged.listen((PlayerState s)  {
      //print('Current player state: $s');
      if( s ==PlayerState.completed){
        if(mounted)
          setState(() {
            _isPlaying=false;
            _isPaused=false;
          });
      }
    });

    await _audioPlayer.setReleaseMode(ReleaseMode.stop,);
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
        widget.message,

      ));

}


