import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../screens/profile_screen.dart';
import '../screens/usernotfound_screen.dart';

class LikeList extends StatelessWidget {
  final postId;

  LikeList(this.postId);
  final usersRef = FirebaseFirestore.instance.collection('users');

  final usersinRoomRef = FirebaseFirestore.instance.collection('usersinRoom');

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  UserModel? _user;

  ///UUUUUUUUUUUUSSSSSSSII$$$$$$$$$$$$
  /////seeeendd user to right profile
  _getAllUsers(userId) async {
    QuerySnapshot snapshot = await usersRef.get();
    snapshot.docs.forEach((doc) {
      if (doc.id == userId) {
        UserModel user = new UserModel.fromMap(doc);
        _user = user;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Likes"),backgroundColor: Colors.transparent,),
      body: FutureBuilder(

        future:FirebaseFirestore.instance.collection('likes').doc(postId).collection('userLiked').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Text('Loading...');
          }

          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context,index){
                var data = snapshot.data!.docs[index];

                  return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                        color: Colors.purple,
                       // borderRadius: BorderRadius.circular(30)
                    ),
                    child: //Column( children: [

                    InkWell(
                      onTap: () async {
                        await _getAllUsers(data.id);
                        _user != null
                            ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfileScreen(_user!)))
                            : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UserNotFoundScreen()));
                      },
                      child: ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: data['photo'].toString(),
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
                          title: Text(
                            data['name'],
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          ),
                    ),

                    //],),
                  ),
                );





                 /* Container(
                  color: Colors.transparent,
                  //padding: EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 5),
                  margin: EdgeInsets.only(top: 5,),

                  child: ListTile(
                    leading: CircleAvatar(
                      //CachedNetworkImageProvider store the image so it doesnt have load the image every time we need to load it
                      backgroundImage:NetworkImage(data['photo']),
                      //COLOr##################
                      backgroundColor: Colors.grey,
                    ),
                    title: Text(data['username'],style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold ),),
                    trailing: Icon(Icons.favorite_outlined),
                  ),
                );*/
              }
          );
        },
      ),
    );

  }
}