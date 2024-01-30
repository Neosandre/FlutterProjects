import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinx/screens/profile_screen.dart';
import 'package:jinx/screens/usernotfound_screen.dart';
import 'package:jinx/widgets/listtile_users.dart';

import '../models/user_model.dart';

class FollowingList extends StatelessWidget {
  final UserModel userModel;

  FollowingList(this.userModel);

  final usersRef = FirebaseFirestore.instance.collection('users');
  final feedRef = FirebaseFirestore.instance.collection('following');
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
        appBar: AppBar(
          title: Text(
            "Following",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: FutureBuilder(
            future: feedRef.doc(userModel.id).collection("userFollowing").get(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index];
                    //_getAllUsers(data.id);
                    final user = UserModel(
                      name: data['name'],
                      id: data['uuid'],
                      photo: data['photo'],
                      status: '',
                      dob: Timestamp.now(),
                      email: '',
                      instagram: '',
                      bio: '',
                        //followers: [],
                        //following: []
                    );

                    return ListTileUsers(user);
                  },
                );
              }
              return Container();
            }));
  }
}
