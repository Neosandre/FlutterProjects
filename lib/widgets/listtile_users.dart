import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jinx/models/user_model.dart';

import '../screens/profile_screen.dart';
import '../screens/usernotfound_screen.dart';

class ListTileUsers extends StatelessWidget {
  UserModel user;
  ListTileUsers(this.user);

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').where("id", isEqualTo: user.id).get() ,
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){

    if (snapshot.hasData) {


      try {



      final allusers = UserModel(
        name: snapshot.data?.docs.first['name'],
        id: snapshot.data?.docs.first['id'],
        photo: snapshot.data?.docs.first['photo'],
        status: '',
        dob: Timestamp.now(),
        email: '',
        instagram: '',
        bio: snapshot.data?.docs.first['bio'],
        //followers: [],
        //following: []

      );
      return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(60)),
          child: InkWell(
            onTap: () =>
            user != null
                ? Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(allusers)))
                : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        UserNotFoundScreen())),
            child: Container(

              color: Colors.purple,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    //Divider(color: Colors.white,),

                    Row(children: [
                      CachedNetworkImage(
                        imageUrl: allusers.photo,
                        imageBuilder: (context, imageProvider) =>
                            Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                        placeholder: (context, url) =>
                            Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/defaultprofile.jpeg'),
                                      fit: BoxFit.cover),
                                )),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      SizedBox(width: 5,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          RichText(
                            overflow: TextOverflow.clip,
                            text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),

                                children: [
                                  TextSpan(
                                      text: allusers.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, /*fontSize: 15*/)),

                                ]),
                          ),

                        ],)
                    ],),
                  ],
                ),
              ),
            ),
          ), //Column( children: [
        ),
      );
    } on FirebaseException{




      }

    }
    return Container();
    });
  }
}
