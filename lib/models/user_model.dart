import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String name;
  String id;
  String email;
  Timestamp dob;
  String photo;
  String bio;
  String instagram;
  String status;
  String? token;
  //List? followers;
  //List? following;

  UserModel(
      {required this.name,
      required this.id,
      required this.email,
      required this.dob,
      //required this.status
      required this.photo,
      required this.bio,
      required this.instagram,
      required this.status,
      this.token,
       // this.followers,
         //this.following
      });

  factory UserModel.fromMap(dynamic documentSnapshot) {
    return UserModel(
        name: documentSnapshot['name'],
        id: documentSnapshot['id'],
        email: documentSnapshot['email'],
        dob: documentSnapshot['dob'],
        photo: documentSnapshot['photo'],
        bio: documentSnapshot['bio'],
        instagram: documentSnapshot['instagram'],
        status: documentSnapshot['status'],
        token: documentSnapshot['token'],
        //followers: documentSnapshot['followers'],
    //following: documentSnapshot['following'],

    );
  }

  Map<String, dynamic> toMap(UserModel user) => {
        'name': user.name,
        'id': user.id,
        'email': user.email,
        'dob': user.dob,
        'photo': user.photo,
        'bio': user.bio,
        'instagram': user.instagram,
        'status': user.status,
        'token': user.token,
    //'followers':user.followers,
    //'following':user.following,

      };
}
