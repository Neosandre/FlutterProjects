
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jinx/screens/feed_screen.dart';
import 'package:jinx/widgets/user_image_picker.dart';

import '../models/user_model.dart';
import '../screens/home_screen.dart';


class CreatePostScreen extends StatefulWidget {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  UserModel userModel;

  CreatePostScreen(this.userModel);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  TextEditingController _text = new TextEditingController();
  TextEditingController _option1 = new TextEditingController();
  TextEditingController _option2 = new TextEditingController();
  TextEditingController _option3 = new TextEditingController();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = false;
  bool _anonymous = false;
  bool _poll = false;

  int selectedPage = 0;
  int selectedPage2 = 0;

  late List<bool> isSelected;
  late List<bool> isSelected2;


  Map<String, int> usersWhoVoted ={};

  dynamic _postId;
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length,
          (_) => CreatePostScreen._chars
          .codeUnitAt(_rnd.nextInt(CreatePostScreen._chars.length))));


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


  ///Imagepicker
  File? _pickedImage;

  _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
      source: ImageSource.gallery, /*imageQuality: 50,maxWidth: 150*/
    );


    final pickedImageFile = File(pickedImage!.path);

    setState(() {
      _pickedImage = File(pickedImageFile.path);
    });

  }

  @override
  void initState() {
    isSelected = [true, false];
    isSelected2 = [true, false];

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        /*leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios),
            onPressed: () {
              if(_pickedImage ==null)
              {
                _pickedImage?.delete();

              }
            }),*/
        backgroundColor: Colors.transparent,
        title: Text("Create Post"),),

    body: SingleChildScrollView(
      child: Form(
        //key: _formKey,
        child: Column(
          children: <Widget>[
           /* const SizedBox(
              height: 50,
            ),*/

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
                 maxLines: 20,
                  decoration: const InputDecoration.collapsed(
                    //focusColor: Colors.black,
                   /* border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30))),*/
                    /*enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(30)))*/

                    hintText: 'tell us anything; your story, life experience, day highlight etc...',
                    hintStyle: TextStyle(color: Colors.grey),

                    //hintText: 'Enter Invited Phone Number'
                  ),

                  // onSaved: (value) {},
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              /*  _pickedImage !=null? IconButton(onPressed: (){
    _pickedImage?.delete(); _pickedImage=null;}
                    
                , icon: Icon(Icons.clear),color: Colors.purple,iconSize: 20):Container(),*/
              TextButton(onPressed: ()
                  {
                  if(_pickedImage ==null)
                    {
                      _pickFromGallery();

                    }else{
                    _pickedImage?.delete().then((value) =>_pickFromGallery() );
                  }

                  }
                  , child:Text("Add Image",style: TextStyle(color: Colors.purple,decoration: TextDecoration.underline))),
              _pickedImage !=null? Container(
                  height: 100,
                  width: 100,
                  padding: EdgeInsets.only(top: 5,bottom: 5),
                  child: ClipRRect(
                    child: Image.file(_pickedImage!),
                    borderRadius: BorderRadius.circular(20),

                  )):Container(),

            ],),

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
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text("Would you like to add a Poll?",style: TextStyle(color: Colors.white),),
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
                    for (int i = 0; i < isSelected2.length; i++) {
                      isSelected2[i] = i == index;
                    }
                    selectedPage2 = index;
                  });
                  if (selectedPage2 == 0) {
                    setState(() {
                      _poll = false;
                    });
                  } else {
                    setState(() {
                      _poll = true;
                    });
                  }
                  print(selectedPage2);
                },
                fillColor: Colors.purple,
                isSelected: isSelected2,
              ),
            ],),

            SizedBox(height: MediaQuery.of(context).size.height * 0.05),


              // onSaved: (value) {},
          ///Options Textfield
          selectedPage2 == 1?  Column(children: [
             TextFormField(
               style: TextStyle(color: Colors.white),
               cursorColor: Colors.white,
               maxLength: 32,

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

                 hintText: 'option 1',
                 hintStyle: TextStyle(color: Colors.white),

                 //hintText: 'Enter Invited Phone Number'
               ),

               // onSaved: (value) {},
             ),
             TextFormField(
               style: TextStyle(color: Colors.white),
               cursorColor: Colors.white,
               maxLength: 32,

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

                 hintText: 'option 2',
                 hintStyle: TextStyle(color: Colors.white),

                 //hintText: 'Enter Invited Phone Number'
               ),

               // onSaved: (value) {},
             ),
            /* TextFormField(
               style: TextStyle(color: Colors.white),
               cursorColor: Colors.white,
               maxLength: 32,

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

                 hintText: 'option 3',
                 hintStyle: TextStyle(color: Colors.white),

                 //hintText: 'Enter Invited Phone Number'
               ),

               // onSaved: (value) {},
             ),*/

           ],):Container(),

            //SizedBox(height: 1,),
            isLoading
                ? CircularProgressIndicator(
              color: Colors.purple,
            )
                : Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(

              style: ElevatedButton.styleFrom(
                  primary: Color(0xfff1efe5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

              ),


              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Post',style: TextStyle(color: Colors.black),),
              ),
              onPressed: () async {

                  if (_text.text.isEmpty) {
                    return _dialog('Text box empty', '');
                  }else if(_poll == true && (_option1.text.isEmpty || _option2.text.isEmpty)) {
                    return _dialog('please add at least two options for the poll', '');
                  }
                  setState(() {
                    isLoading = true;
                  });
                  _postId = getRandomString(10);
                  var url;
                    if (_pickedImage != null) {
                      final ref = FirebaseStorage.instance
                          .ref()
                          .child('post_image')
                          .child(_postId + '.jpg');
                      await ref
                          .putFile(_pickedImage!)
                          .whenComplete(() => null);
                       url = await ref.getDownloadURL();


                    }
                   if(_anonymous == false){
                     await FirebaseFirestore.instance
                         .collection('post')
                         .doc(_postId)
                         .set({
                       'name':widget.userModel.name,
                       'postId': _postId,
                       'text': _text.text.trim(),
                       'postImage':url,
                       //'language': _selectedDropdownLanguage.name,
                       'anonymous': _anonymous,
                       'poll':_poll,
                       'option1':_option1.text.trim(),
                       'option2':_option2.text.trim(),
                       'option3':_option3.text.trim(),
                       'userId': widget.userModel.id,
                       'createdBy': widget.userModel.id,
                       'photo': widget.userModel.photo,
                       'time': DateTime.now(),
                       'type':"pp",
                       'option1P':0.0,
                       'option2P':0.0,
                       'option3P':0.0,
                       'userWhoVoted':usersWhoVoted,
                       "likedBy":[],
                       'commentCount':[]
                       //"count": 0
                     });

                   }else{
                     await FirebaseFirestore.instance
                         .collection('post')
                         .doc(_postId)
                         .set({
                       'name':"anonymous",
                       'postId': _postId,
                       'text': _text.text.trim(),
                       'postImage':url,
                       //'language': _selectedDropdownLanguage.name,
                       'anonymous': _anonymous,
                       'poll':_poll,
                       'option1':_option1.text.trim(),
                       'option2':_option2.text.trim(),
                       'option3':_option3.text.trim(),
                       'userId': "jLhQUkYfk2Nelc3H9aRn45FJpap2",
                       'createdBy': currentUserId,
                       'photo': "https://firebasestorage.googleapis.com/v0/b/jinx-ca0c7.appspot.com/o/user_image%2Fdefaultprofile.jpeg?alt=media&token=79066c24-6920-4338-947c-eb59c96e8b25",
                       'time': DateTime.now(),
                       'type':"pp",
                       'option1P':0.0,
                       'option2P':0.0,
                       'option3P':0.0,
                       'userWhoVoted':usersWhoVoted,
                       "likedBy":[],
                       'commentCount':[]
                       //"count": 0
                     });


                   }

                    setState(() {
                      isLoading = false;
                    });
                    //Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen(widget.userModel,'feedScreen')));
              },
            ),
                )
          ],
        ),
      ),
    ),
    );
  }
}
