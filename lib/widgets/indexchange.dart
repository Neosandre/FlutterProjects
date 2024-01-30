import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:jinx/widgets/profile_anonymous.dart';
import 'package:jinx/widgets/profile_post.dart';

import '../models/user_model.dart';

class IndexChange extends StatefulWidget {
  UserModel userModel;

  IndexChange(this.userModel);

  @override
  State<IndexChange> createState() => _IndexChangeState();
}

class _IndexChangeState extends State<IndexChange> {
  var _selectedTab = _enumList.post;

  void _handleIndexChanged(int i) {
    setState(() {
      _selectedTab = _enumList.values[i];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ///2#Create this then add new value on click in notification and rooms creen
     ProfilePost(widget.userModel),
      ProfileAnonymous(widget.userModel)
    ];

    return Column(children: [

      if(widget.userModel.id == "jLhQUkYfk2Nelc3H9aRn45FJpap2")  Container(
        //height: 50,
        width: 300,
        child: DotNavigationBar(
          enableFloatingNavBar: false,

          //margin: EdgeInsets.only(bottom: 10),

          unselectedItemColor: Colors.white,
          selectedItemColor:Colors.purple ,
          backgroundColor: Colors.transparent,
          currentIndex: _enumList.values.indexOf(_selectedTab),
          onTap: _handleIndexChanged,
          items: [
            /// post
            DotNavigationBarItem(
              icon: Icon(
                Icons.grid_view_rounded,
              ),
            ),

            /// Anonymous
           DotNavigationBarItem(
              icon: Icon(Icons.account_circle_sharp),
            ),


          ],

        ),
      ) ,

    //  Divider(color: Colors.white,),
      screens[_selectedTab.index],

    ],);
  }
}

enum _enumList { post, anonymous }