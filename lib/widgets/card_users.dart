import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jinx/models/room_model.dart';
import 'package:jinx/models/usercarddetails_model.dart';

class CardUsers extends StatelessWidget {
  RoomModel room;

  CardUsers(this.room);

  late UserCardDetails user;
  int coutUsers = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('usersinRoom')
            .doc(room.roomId)
            .collection("list")
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            coutUsers = snapshot.data!.docs.length;
            return Padding(
              padding: EdgeInsets.only(left: 7, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title,
                    style: GoogleFonts.dongle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(
                    height: 2,
                  ),

                  ///stream
                  Container(
                    height: 90,
                    child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          var data = snapshot.data!.docs[index];
                          user = UserCardDetails(
                              name: data["name"],
                              id: data["userId"],
                              photo: data["photo"],
                              roomId: room.roomId);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Column(
                                      children: [
                                       /* CircleAvatar(
                                          radius: 30.0,
                                          backgroundColor: Colors.blue,
                                          backgroundImage:
                                              NetworkImage(user.photo),
                                        ),*/
                                        CachedNetworkImage(
                                          imageUrl: user.photo,
                                          imageBuilder: (context, imageProvider) => Container(
                                            width: 50.0,
                                            height: 50.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                            ),
                                          ),
                                          placeholder: (context, url) => Container(
                                              width: 50.0,
                                              height: 50.0,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: AssetImage('assets/defaultprofile.jpeg'), fit: BoxFit.cover),
                                              )),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        ),
                                        SizedBox(
                                          height: 1,
                                        ),
                                        Text(
                                          user.name,
                                          style: GoogleFonts.dongle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                  ),

                  ///end
                 /* SizedBox(
                    height: 1,
                  ),*/
                  Row(
                    children: [
                      Text(
                        coutUsers.toString(),
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.people,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '|',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        room.type,
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(
                        width: 80,
                      ),
                      Icon(Icons.language, color: Colors.grey),
                      Text(
                        room.language,
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  )
                ],
              ),
            );
          }
          return Container();
        });
  }
}

///aigerigq78wg897rtg98wq3490twqt
/*
Container(
height: 90,
child: ListView.builder( itemCount: snapshot.data!.docs.length,

shrinkWrap: true,
scrollDirection:Axis.horizontal ,
itemBuilder: (context,index){
var data = snapshot.data!.docs[index];
user = UserCardDetails(
name:data["name"],
id: data["userId"],
photo: data["photo"],
roomId: room.roomId);

return Column(crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(

children: [
Container(
padding: EdgeInsets.only(left:10),
child: Column(children: [
CircleAvatar(
radius: 30.0,
backgroundColor: Colors.blue,
backgroundImage: NetworkImage(user.photo),
),
SizedBox(height: 1,),

Text(user.name,style: GoogleFonts.dongle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),

],),
),


],),
],);
}

),
)*/
