import 'dart:math';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:jinx/models/user_model.dart';
import 'package:jinx/posts/postguess.dart';

import '../screens/home_screen.dart';

class CreatePostGuess extends StatefulWidget {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  UserModel user;
  CreatePostGuess( this.user);

  @override
  State<CreatePostGuess> createState() => _CreatePostGuessState();
}

class _CreatePostGuessState extends State<CreatePostGuess> {
  TextEditingController _text = new TextEditingController();

  TextEditingController secretWord = new TextEditingController();



  var selected;
  dynamic _postId;
  var expireDate;
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

  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length,
          (_) => CreatePostGuess._chars
          .codeUnitAt(_rnd.nextInt(CreatePostGuess._chars.length))));

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
        title: Text("Create Post Guess"),),
    body: SingleChildScrollView(
      child: Form(child:Column(children: [

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
          maxLength: 10,

          autocorrect: false,
          controller: secretWord,
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

            hintText: 'Secret Word',
            hintStyle: TextStyle(color: Colors.white),

            //hintText: 'Enter Invited Phone Number'
          ),

          // onSaved: (value) {},
        ),


        //SizedBox(height: 10,),
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text("Pick the expire date",style: TextStyle(color: Colors.grey),),
  ),
        Container(
          color: Color(0xfff1efe5),
          padding: EdgeInsets.only(left: 5),
          child: DateTimePicker(
            decoration: InputDecoration(
                fillColor: Colors.purple,floatingLabelStyle: TextStyle(color: Colors.purple)
            ),

            type: DateTimePickerType.dateTimeSeparate,

            dateMask: 'd MMM, yyyy',
            autovalidate: true,
            initialValue: DateTime.now().toString(),
            firstDate:/* DateTime(2000)*/DateTime.now(),
            lastDate: DateTime(2100),
            icon: Icon(Icons.event),
            //timePickerEntryModeInput: true,
            dateLabelText: 'Date',
            timeLabelText: "Hour",


            /*selectableDayPredicate: (date) {
              // Disable weekend days to select from the calendar
             *//* if (date.weekday == 6 || date.weekday == 7) {
                return false;
              }*//*

              return true;
            },*/
            onChanged: (val) {
              var t= DateTime.parse(val);
              if(t.isBefore(DateTime.now())){return _dialog('Please add a future date and time', '');}
              else{
                setState(() {
                  expireDate =val;
                });
              }



            },

          )
        ),
        SizedBox(height: 20,),


        ///ButtonPost
        isLoading ? CircularProgressIndicator(
          color: Colors.purple,
        ): ElevatedButton(

          style: ElevatedButton.styleFrom(
            primary: Color(0xfff1efe5)/*Colors.purple*/,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

          ),


          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Post',style: TextStyle(color: Colors.black),),
          ),
          onPressed: () async {
            print(expireDate);
            if( _text.text.isEmpty || secretWord.text.isEmpty  )

            {return _dialog("please add a question and the secret word", '');
            }else if (expireDate == null){
              return _dialog("please pick an expiring date", '');
            }/*else if (expireDate.)*/

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
              'type':"pg",
              'time': DateTime.now(),
              'anonymous': _anonymous,
              'secretWord':secretWord.text.trim(),
              'expireDate':DateTime.parse(expireDate),
              "likedBy":[],
              'commentCount':[]
              //'userAnswer':'',

            });
            //Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen(widget.user,'feedScreen')));

          },
        )
      ],
      ),),
    ),
    );

  }
}
