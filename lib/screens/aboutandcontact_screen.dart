import 'package:flutter/material.dart';

class AboutAndContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: Text(
            'Contacts',
          ),
          backgroundColor: Colors.transparent),
      body: Padding(
        padding: EdgeInsets.only(top: 100),
        child: Center(
          child: Column(
            children: [
              Text(
                'Since we are working on the next version of jinX,\n please expect a reply within 5 working days.',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Please, do Not forget to add a subject,\n eg:bug,feedback,suggestions...',
                style: TextStyle(color: Colors.white),
              ),
              Container(
                  width: 300,
                  child: Divider(
                    color: Colors.white,
                  )),
              Text(
                'Contact us via email: jinxcrewoficial@gmail.com',
                style: TextStyle(color: Colors.purple),
              ),
              Text(
                'Instagram: @jinx_oficial_app',
                style: TextStyle(color: Colors.purple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
