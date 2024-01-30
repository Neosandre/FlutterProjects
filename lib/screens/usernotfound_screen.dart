import 'package:flutter/material.dart';

class UserNotFoundScreen extends StatelessWidget {
  const UserNotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Not Found'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        //alignment: Alignment.center,
        padding: EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Text(
              'Page not found, reasons: ',
              style: TextStyle(
                  color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Text('''
              -This user may have closed their account.
              -This user may have blocked you.
              -You may have blocked them.
               -Post was deleted.''',
                maxLines: 20,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white))
          ],
        ),
      ),
    );
  }
}
