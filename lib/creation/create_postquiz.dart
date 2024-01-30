import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jinx/models/user_model.dart';
import 'package:jinx/posts/postquiz.dart';
import 'package:jinx/screens/feed_screen.dart';

import '../screens/home_screen.dart';

class CreatePostQuiz extends StatefulWidget {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  UserModel user;

  CreatePostQuiz(this.user);


  @override
  State<CreatePostQuiz> createState() => _CreatePostQuizState();
}

class _CreatePostQuizState extends State<CreatePostQuiz> {
  TextEditingController _text = new TextEditingController();

  TextEditingController _option1 = new TextEditingController();

  TextEditingController _option2 = new TextEditingController();

  TextEditingController _option3 = new TextEditingController();

   TextEditingController _option4 = new TextEditingController();

  dynamic _postId;

  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length,
          (_) => CreatePostQuiz._chars
          .codeUnitAt(_rnd.nextInt(CreatePostQuiz._chars.length))));

  bool answer1=false;
  bool answer2=false;
  bool answer3=false;
  bool answer4=false;
  var correctA;
  _dialog(top, button) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Color(0xfff1efe5),
            title: Text(top, style: TextStyle(color: Colors.red)),
            content: Text(button),
          );
        });
  }

   var selectedA;
  bool _anonymous = false;
  bool isLoading = false;

  int selectedPage = 0;
  int selectedPage2 = 0;

  late List<bool> isSelected;


  @override
  void initState() {
    isSelected = [true, false];

    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Create Post Quiz"),),


    body: SingleChildScrollView(
      child: Form(
        child: Column(children: [
          ///Text
          Container(
            color: Color(0xfff1efe5),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                cursorColor: Colors.purple,
                autocorrect: false,
                controller: _text,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Question...',
                  hintStyle: TextStyle(color: Colors.grey),

                  //hintText: 'Enter Invited Phone Number'
                ),

                // onSaved: (value) {},
              ),
            ),
          ),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Make it Anonymous?",style: TextStyle(color: Colors.white),),

              //SizedBox(width: 20,),
              ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                //borderWidth: 2,
                borderColor: Colors.white,
                selectedBorderColor: Colors.white,
                // selectedColor: Colors.white,
                children: [
                  Container(
                    height: 30,
                    width:50 /*MediaQuery.of(context).size.width * 0.87 / 2*/,
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child:
                      Text('no', style: TextStyle(color: Colors.white,fontSize: 10)),
                    ),
                  ),
                  Container(
                    width: 50/*MediaQuery.of(context).size.width * 0.87 / 2*/,
                    padding: EdgeInsets.all(8),
                    child: Center(
                        child: Text(
                          'yes',
                          style: TextStyle(color: Colors.white,fontSize: 10),
                        )),
                  ),
                ],
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < isSelected.length; i++) {
                      isSelected[i] = i == index;
                    }
                    selectedPage = index;
                  });
                  if (selectedPage == 0) {
                    setState(() {
                      _anonymous = false;
                    });
                  } else {
                    setState(() {
                      _anonymous = true;
                    });
                  }
                  print(selectedPage);
                },
                fillColor: Colors.purple,
                isSelected: isSelected,
              ),
            ],),
          SizedBox(height: 20,),

          _anonymous ==true? Center(child: Text("\"you can find anonymous post on jinx profile\"",style: TextStyle(color: Colors.grey),)):Container(),
          SizedBox(height: 20,),
          TextFormField(

            style: TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            maxLength: 16,

            autocorrect: false,
            controller: _option1,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              //focusColor: Colors.black,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30))),

              hintText: 'answer 1',
              hintStyle: TextStyle(color: Colors.white),

              //hintText: 'Enter Invited Phone Number'
            ),
            onSaved: (value) {setState(() {

            });},
            onEditingComplete: (){setState(() {

            });},
            onFieldSubmitted: (s){setState(() {

            });},
            onChanged: (s){setState(() {

            });},
            // onSaved: (value) {},
          ),
        ///togglebutton
          ///opton 2
          TextFormField(
            style: TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            maxLength: 16,

            autocorrect: false,
            controller: _option2,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              //focusColor: Colors.black,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30))),

              hintText: 'answer 2',
              hintStyle: TextStyle(color: Colors.white),

              //hintText: 'Enter Invited Phone Number'
            ),
            onSaved: (value) {setState(() {

            });},
            onEditingComplete: (){setState(() {

            });},
            onFieldSubmitted: (s){setState(() {

            });},
            onChanged: (s){setState(() {

            });},
            // onSaved: (value) {},
          ),
          ///option 3
          TextFormField(
            style: TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            maxLength: 16,

            autocorrect: false,
            controller: _option3,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              //focusColor: Colors.black,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30))),

              hintText: 'answer 3',
              hintStyle: TextStyle(color: Colors.white),

              //hintText: 'Enter Invited Phone Number'
            ),
            onSaved: (value) {setState(() {

            });},
            onEditingComplete: (){setState(() {

            });},
            onFieldSubmitted: (s){setState(() {

            });},
            onChanged: (s){setState(() {

            });},
            // onSaved: (value) {},
          ),

          ///option 4
          TextFormField(
            style: TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            maxLength: 16,

            autocorrect: false,
            controller: _option4,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              //focusColor: Colors.black,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30))),

              hintText: 'answer 4',
              hintStyle: TextStyle(color: Colors.white),

              //hintText: 'Enter Invited Phone Number'
            ),

            onSaved: (value) {setState(() {

            });},
            onEditingComplete: (){setState(() {

            });},
            onFieldSubmitted: (s){setState(() {

            });},
            onChanged: (s){setState(() {

            });},
          ),

          _text.text.isEmpty || _option1.text.isEmpty || _option2.text.isEmpty||_option3.text.isEmpty||_option4.text.isEmpty?
          Container():DropdownButton <int>(
            value: selectedA,
               hint: Text("Select the correct answer",style: TextStyle(color: Colors.grey),),
              dropdownColor: Color(0xfff1efe5),
             // value: selectedItem,
              items:[
                DropdownMenuItem(
                    value: 0,
                    child: Text("${_option1.text}",style: TextStyle(color: Colors.purple),)),

           DropdownMenuItem(
                    value: 1,
                    child: Text("${_option2.text}",style: TextStyle(color: Colors.purple),)),
             DropdownMenuItem(
                    value: 2,
                    child: Text("${_option3.text}",style: TextStyle(color: Colors.purple),)),
             DropdownMenuItem(
                    value: 3,
                    child: Text("${_option4.text}",style: TextStyle(color: Colors.purple),)),

              ] , onChanged: (item){

                 setState(() {
                   correctA = item;
                   selectedA = item;
                 });

               },







          ),
  SizedBox(height: 20,),
          ///ButtonPost
          isLoading ? CircularProgressIndicator(
            color: Colors.purple,
          ): ElevatedButton(

            style: ElevatedButton.styleFrom(
              primary: Color(0xfff1efe5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

            ),


            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Post',style: TextStyle(color: Colors.black),),
            ),
            onPressed: () async {

              if( _text.text.isEmpty )

              {return _dialog("please add a question", '');
              }else if(_option1.text.isEmpty || _option2.text.isEmpty||_option3.text.isEmpty||_option4.text.isEmpty){
                return _dialog("please add 4 answers", '');

              }
              else if (correctA == null){
                return _dialog("please choose the correct answer", '');
              }
              setState(() {
                isLoading = true;
              });
              switch(correctA){
                case 0:
                  setState(() {
                    answer1=true;
                  });
                  break;
                 case 1:
                  setState(() {
                    answer2=true;
                  });
                  break;
                 case 2:
                  setState(() {
                    answer3=true;
                  });
                  break;
                 case 3:
                  setState(() {
                    answer4=true;
                  });
                  break;
              }

              _postId = getRandomString(10);

              await FirebaseFirestore.instance
                  .collection('post')
                  .doc(_postId).set({
                'name':_anonymous == true?"anonymous":widget.user.name,
                'userId':_anonymous == true?"jLhQUkYfk2Nelc3H9aRn45FJpap2":widget.user.id,
                'postId': _postId,
                'text': _text.text.trim(),
                'createdBy': widget.user.id,
                'photo':_anonymous==true?"https://firebasestorage.googleapis.com/v0/b/jinx-ca0c7.appspot.com/o/user_image%2Fdefaultprofile.jpeg?alt=media&token=79066c24-6920-4338-947c-eb59c96e8b25": widget.user.photo,
                'type':"pq",
                'anonymous': _anonymous,
                'time': DateTime.now(),
                'answers':{
                  _option1.text.trim():answer1,
                 _option2.text.trim():answer2,
                 _option3.text.trim():answer3,
                 _option4.text.trim():answer4,

                },
                //'userAnswer':'',
                'userWhoAnswered':{},
                "likedBy":[],
                'commentCount':[]
              });
              //Navigator.pop(context);
              setState(() {
                isLoading = true;
              });
              //Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen(widget.user,'feedScreen')));

              //Navigator.push(context, MaterialPageRoute(builder: (context)=>GroupChatScreen(_roomTitle.text,fileId,widget.userModel,user.uid,)));
            },
          )

        ],),
      ),
    ),
    );
  }
}