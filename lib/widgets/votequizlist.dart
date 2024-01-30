import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../screens/profile_screen.dart';
import '../screens/usernotfound_screen.dart';

class VoteQuizList extends StatelessWidget {


  final Map<String, dynamic> userWhoAnswered;
  final answers;
  final answerList;




  VoteQuizList(this.userWhoAnswered,this.answers,this.answerList,);



  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  UserModel? _user;

  ///UUUUUUUUUUUUSSSSSSSII$$$$$$$$$$$$
  final usersRef = FirebaseFirestore.instance.collection('users');


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
    print(userWhoAnswered.keys);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Answers"),backgroundColor: Colors.transparent,),

      body:FutureBuilder(

        future:FirebaseFirestore.instance.collection('users').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Text('Loading...');
          }
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context,index){
                var data = snapshot.data!.docs[index];


                for (final mapEntry in userWhoAnswered.entries) {
                  final key = mapEntry.key;
                  final value = mapEntry.value;
                  if(key == data.id)
                  {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          // borderRadius: BorderRadius.circular(30)
                        ),
                        child: //Column( children: [

                        ListTile(
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
                          trailing: /*value == 0?*/
                          Container(
                              width: 200,
                              child: Text('${answerList[value]}',style: TextStyle(color:Colors.grey ),overflow: TextOverflow.ellipsis,))
                             ),

                        //],),
                      ),
                    );

                  }

                }


                return Container();

              }
          );
        },
      ),
    );

  }
}