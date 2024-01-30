import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {


  final storageRef = FirebaseStorage.instance.ref();
  final followersRef = FirebaseFirestore.instance.collection('followers');
  final followingRef = FirebaseFirestore.instance.collection('following');
  final activityFeedRef = FirebaseFirestore.instance.collection('feed');

  deleteFollowing(userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('followers')
        .doc(userId)
        .collection("userFollowers")
        .get();
    snapshot.docs.forEach((element) {
      FirebaseFirestore.instance
          .collection('following')
          .doc(element.id)
          .collection("userFollowing")
          .doc(userId)
          .delete().then((value) {
        FirebaseFirestore.instance
            .collection('followers')
            .doc(userId)
            .collection("userFollowers")
            .doc(element.id).delete();

      });
    });
  }

  deleteFollowers(userId) async {
    ///deletefollowings
    QuerySnapshot snapshot2 = await FirebaseFirestore.instance
        .collection('following')
        .doc(userId)
        .collection("userFollowing")
        .get();
    snapshot2.docs.forEach((element) {
      FirebaseFirestore.instance
          .collection('followers')
          .doc(element.id)
          .collection("userFollowers")
          .doc(userId)
          .delete();
    });
  }
  deleteUser(){
    var a='hCTgCDX6ZOgk1cfZ2ipeA8WrTC82';

    var b='hCTgCDX6ZOgk1cfZ2ipeA8WrTC82';

    var c='91EMhuokJ2Niw1KxrQq60XJVzqy2';

    var d='GkFKHGsRqeUeElLFJJz8lEyuaDy2';

    var e='dssOdEFknXNYqY89tqfxsUmtvcp2';

    var f='fc80hoWkI9g6yTKQ9NofHClMTsJ2';



      FirebaseFirestore.instance
          .collection('users')
          .doc(a)
          .delete();


  }

  deletefeedfollowers(userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('followers')
        .doc(userId)
        .collection("userFollowers")
        .get();

    snapshot.docs.forEach((element) async {
      final el = element.id;
      QuerySnapshot _snapshot = await FirebaseFirestore.instance
          .collection('feed')
          .doc(element.id)
          .collection("feedItems")
          .where("uuid", isEqualTo: userId)
          .get();
      _snapshot.docs.forEach((element) {

        FirebaseFirestore.instance
            .collection('feed')
            .doc(el)
            .collection("feedItems")
            .doc(element.id)
            .delete();
      });
    });
  }

  deletefeedFollowing(userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('following')
        .doc(userId)
        .collection("userFollowing")
        .get();

    snapshot.docs.forEach((element) async {
      final el = element.id;
      QuerySnapshot _snapshot = await FirebaseFirestore.instance
          .collection('feed')
          .doc(element.id)
          .collection("feedItems")
          .where("uuid", isEqualTo:userId)
          .get();
      _snapshot.docs.forEach((element) {

        FirebaseFirestore.instance
            .collection('feed')
            .doc(el)
            .collection("feedItems")
            .doc(element.id)
            .delete();
      });
    });
  }

  deleteAllOther(userId)async{

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .delete();
    FirebaseFirestore.instance
        .collection('rooms')
        .where("userId",
        isEqualTo: userId)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds
      in snapshot.docs) {
        ds.reference.delete();
      }
    });

    FirebaseFirestore.instance
        .collection('followers')
        .doc(userId)
        .collection('userFollowers')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds
      in snapshot.docs) {
        ds.reference.delete();
      }
    });
    FirebaseFirestore.instance
        .collection('following')
        .doc(userId)
        .collection("userFollowing")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds
      in snapshot.docs) {
        ds.reference.delete();
      }
    });
    FirebaseFirestore.instance
        .collection('chatList')
        .doc(userId)
        .collection("userChatList")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds
      in snapshot.docs) {
        ds.reference.delete();
      }
    });

    FirebaseFirestore.instance
        .collection('roomuserin')
        .doc(userId)
        .delete();
    FirebaseFirestore.instance
        .collection('feed')
        .doc(userId)
        .collection("feedItems")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds
      in snapshot.docs) {
        ds.reference.delete();
      }
    });

    /// Create a reference to the file to deletefor next app version
    final desertRef = storageRef.child("user_image/$userId.jpg");
    desertRef.delete();



  }

deleteEveryWhere()async{
deleteUser();
  QuerySnapshot usersDeleted= await FirebaseFirestore.instance.collection('deleted').get();



  usersDeleted.docs.forEach((element) {
      deleteFollowing(element.id);
      deleteFollowers(element.id);
      deletefeedfollowers(element.id);
      deletefeedFollowing(element.id);
      deleteAllOther(element.id);

  });
}
makeUsersFollowJinx()async{
  DocumentSnapshot jinx = await FirebaseFirestore.instance.collection('users').doc("jLhQUkYfk2Nelc3H9aRn45FJpap2").get();
  QuerySnapshot users = await FirebaseFirestore.instance.collection('users').get();
  users.docs.forEach((element) {

    if(element.id != jinx.id){
      followersRef
          .doc(jinx.id)
          .collection('userFollowers')
          .doc(element.id)
          .set({
        'name': element['name'],
        'photo': element['photo'],
        'uuid': element['id'],
        'status': element['status']
      });

      followingRef
          .doc(element.id)
          .collection('userFollowing')
          .doc(jinx.id)
          .set({
        'name': jinx['name'],
        'photo': jinx['photo'],
        'uuid': jinx['id'],
        'status': jinx['status']
      });

    }


  });

}

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(

            style: ElevatedButton.styleFrom(primary: Colors.red,),
            child: Text('Delete'),onPressed: ()=>deleteUser()),
         ElevatedButton(

            style: ElevatedButton.styleFrom(primary: Colors.blue,),
            child: Text('Follow Jinx'),onPressed: ()=>makeUsersFollowJinx()),


      ],
    );



  }
}
