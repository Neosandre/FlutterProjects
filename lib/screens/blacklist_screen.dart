import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BlackListScreen extends StatelessWidget {
  final blockRef = FirebaseFirestore.instance.collection('block');
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  buildNoContent() {
    return Container(
      padding: EdgeInsets.only(top: 100),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.emoji_emotions,
              size: 100,
              color: Colors.purple,
            ),
            Text(
              'there is not rooms to show...\n',
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            blockRef.doc(currentUserId).collection('userBlocked').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                    title: Text('Block List'),
                    backgroundColor: Colors.transparent),
                body: Center(child: Text('loading...')));
          }

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
                title: Text(
                  'Block List',
                ),
                backgroundColor: Colors.transparent),
            body: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data = snapshot.data!.docs[index];
                  return Card(
                    child: Container(
                      color: Colors.black,
                      child: ListTile(
                        subtitle: Text(
                          'this user can\'t see your content',
                          style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                              fontSize: 12),
                        ),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(data['userImage']),
                        ),
                        title: Text(
                          data['userName'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        trailing: TextButton(
                            child: Text(
                              'Unblock',
                              style: TextStyle(color: Colors.purple),
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('block')
                                  .doc(currentUserId)
                                  .collection('userBlocked')
                                  .doc(data['userId'])
                                  .delete()
                                  .then((value) {
                                FirebaseFirestore.instance
                                    .collection('blockedUsers')
                                    .doc(data['userId'])
                                    .collection('blockedBy')
                                    .doc(currentUserId)
                                    .delete();
                              });
                            }),
                      ),
                    ),
                  );
                }),
          );
        });
  }
}
