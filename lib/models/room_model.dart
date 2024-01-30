import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class RoomModel {
  String createdBy;
  String language;
  String roomId;
  String title;
  String type;
  String userId;

  //String photo;
  //int count;
  Timestamp time;

  RoomModel({
    required this.createdBy,
    required this.language,
    required this.roomId,
    required this.title,
    required this.type,
    required this.userId,
    //required this.photo,
    //required this.count,
    required this.time,
  });

  factory RoomModel.fromMap(dynamic documentSnapshot) {
    return RoomModel(
      createdBy: documentSnapshot['createdBy'],
      language: documentSnapshot['language'],
      roomId: documentSnapshot['roomId'],
      title: documentSnapshot['title'],
      type: documentSnapshot['type'],
      userId: documentSnapshot['userId'],
      //photo: documentSnapshot['photo'],
      //count: documentSnapshot['count'],
      time: documentSnapshot['time'],
    );
  }

  Map<String, dynamic> toMap(RoomModel room) => {
        'createdBy': room.createdBy,
        'language': room.language,
        'roomId': room.roomId,
        'title': room.title,
        'type': room.type,
        'userId': room.userId,
        //'photo':room.photo,
        //'count':room.count,
        'time': room.time
      };
}
