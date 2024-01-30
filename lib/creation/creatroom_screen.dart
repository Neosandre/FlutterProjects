import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jinx/models/user_model.dart';
import 'package:jinx/screens/group_chat_screen.dart';
import 'package:jinx/screens/rooms_screen.dart';
import 'package:language_picker/language_picker_dropdown.dart';
import 'package:language_picker/languages.dart';
import 'package:provider/provider.dart';

class CreateRoomScreen extends StatefulWidget {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  UserModel userModel;

  CreateRoomScreen({required this.userModel});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  //const CreateRoomScreen({Key? key}) : super(key: key);
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length,
      (_) => CreateRoomScreen._chars
          .codeUnitAt(_rnd.nextInt(CreateRoomScreen._chars.length))));

  TextEditingController _roomTitle = new TextEditingController();
  late List<bool> isSelected;
  dynamic fileId;
  int selectedPage = 0;
  var _type = 'public';
  Language _selectedDropdownLanguage = Languages.english;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSelected = [true, false];
  }

  Widget _buildDropdownItem(Language language) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 8.0,
        ),
        Text(
          "${language.name} (${language.isoCode})",
          style: TextStyle(color: Colors.purple),
        ),
      ],
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Create Room',
          style: GoogleFonts.dongle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Form(
          //key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              Text(
                "\"Rooms and messsages are deleted within 24 hours\"",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(
                height: 20,
              ),

              ///Room Name
              TextFormField(
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                maxLength: 50,

                autocorrect: false,
                controller: _roomTitle,
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

                  hintText: 'title',
                  hintStyle: TextStyle(color: Colors.white),

                  //hintText: 'Enter Invited Phone Number'
                ),

                // onSaved: (value) {},
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              ToggleButtons(
                borderRadius: BorderRadius.circular(30),
                borderWidth: 2,
                borderColor: Colors.white,
                selectedBorderColor: Colors.white,
                // selectedColor: Colors.white,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.87 / 2,
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child:
                          Text('public', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.87 / 2,
                    padding: EdgeInsets.all(8),
                    child: Center(
                        child: Text(
                      'private',
                      style: TextStyle(color: Colors.white),
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
                      _type = 'public';
                    });
                  } else {
                    setState(() {
                      _type = 'private';
                    });
                  }
                  print(selectedPage);
                },
                fillColor: Colors.purple,
                isSelected: isSelected,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              LanguagePickerDropdown(
                initialValue: Languages.english,
                itemBuilder: _buildDropdownItem,
                onValuePicked: (Language language) {
                  _selectedDropdownLanguage = language;
                  // print(_selectedDropdownLanguage.name);
                  // print(_selectedDropdownLanguage.isoCode);
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              isLoading
                  ? CircularProgressIndicator(
                      color: Colors.purple,
                    )
                  : ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    primary: Color(0xfff1efe5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

                  ),
                      child: Text('Create Room',style: TextStyle(color: Colors.black),),
                      onPressed: () async {
                        if (_roomTitle.text.isEmpty) {
                          return _dialog('Room title empty', '');
                        }
                        setState(() {
                          isLoading = true;
                        });

                        //**Improment NOTE: you can make user and userdata variable global because we need the same detail in _stop function,so we dont call them twice
                        QuerySnapshot allusers = await FirebaseFirestore
                            .instance
                            .collection('rooms')
                            .where('userId', isEqualTo: widget.userModel.id)
                            .get();

                        if (allusers.docs.isEmpty) {
                          fileId = getRandomString(10);
                          await FirebaseFirestore.instance
                              .collection('rooms')
                              .doc(fileId)
                              .set({
                            'roomId': fileId,
                            'title': _roomTitle.text,
                            'language': _selectedDropdownLanguage.name,
                            'type': _type,
                            'userId': widget.userModel.id,
                            'createdBy': widget.userModel.name,
                            //'photo': widget.userModel.photo,
                            'time': DateTime.now(),
                            //"count": 0
                          });
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            isLoading = false;
                          });
                          return _dialog('You already own a room',
                              'delete the current room you own');
                        } //Navigator.push(context, MaterialPageRoute(builder: (context)=>GroupChatScreen(_roomTitle.text,fileId,widget.userModel,user.uid,)));
                      },
                    )
            ],
          ),
        ),
      ),
    );
  }
}
