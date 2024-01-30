import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jinx/screens/home_screen.dart';
import 'package:jinx/widgets/user_image_picker.dart';
import 'package:string_validator/string_validator.dart';

import '../image_picker.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  EditProfileScreen(
    this.user,
  );

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  //final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  File? _userImageFile;
  var user = FirebaseAuth.instance.currentUser;
  bool exists = false;
  var userId;

  void _pickedImage(File image) {
    _userImageFile = image;
  }
///check if user name ex
  /*Future<void> usernameCheck() async {
    final result = await FirebaseFirestore.instance
        .collection("users")
        .where('name', isEqualTo: userNameController.text.toLowerCase())
        .get();

    setState(() {
      exists = result.docs.isEmpty;
      if (result.docs.isEmpty != true) userId = result.docs.first.id;
    });
  }*/

  updatePostePic(userId,file)async{
    QuerySnapshot posts= await FirebaseFirestore.instance.collection('post').where('userId',isEqualTo: userId).get();

    posts.docs.forEach((element) {
      FirebaseFirestore.instance.collection('post').doc(element.id).update({
        'photo':file
      });

    });
    
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Edit Profile'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            //NOte:####### use this to add the chat in rooms ######
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    EditProfileImagePicker(_pickedImage, widget.user),
                    /*Text(
                      "@${widget.user.name}",
                      style: TextStyle(color: Colors.purple,fontSize: 18),
                    ),*/
                    Text(
                      widget.user.email,
                      style: TextStyle(color: Colors.grey),
                    ),


                   /* Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp("[0-9a-zA-Z._]")),
                          FilteringTextInputFormatter.deny('\n'),
                        ],
                        controller: userNameController..text = widget.user.name,
                        style: TextStyle(color: Colors.white),
                        maxLength: 16,
                        decoration: const InputDecoration(
                          //focusColor: Colors.black,
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xfff1efe5),
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),

                          hintText: 'User Name',
                          hintStyle: TextStyle(color: Color(0xfff1efe5)),
                          counterStyle: TextStyle(color: Colors.white),

                          //hintText: 'Enter Invited Phone Number'
                        ),
                      ),
                    ),*/
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: TextFormField(
                        maxLength: 100,
                        controller: bioController..text = widget.user.bio,
                        style: TextStyle(color: Colors.white),
                        decoration: const InputDecoration(

                            //focusColor: Colors.black,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xfff1efe5),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            counterStyle: TextStyle(color: Colors.white),
                            hintText: 'Bio',
                            hintStyle: TextStyle(color: Color(0xfff1efe5))
                            //hintText: 'Enter Invited Phone Number'
                            ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: TextFormField(
                        controller: instagramController
                          ..text = widget.user.instagram,
                        style: TextStyle(color: Colors.white),
                        decoration: const InputDecoration(

                            //focusColor: Colors.black,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xfff1efe5),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            hintText: 'https://',
                            hintStyle: TextStyle(color: Color(0xfff1efe5))
                            //hintText: 'Enter Invited Phone Number'
                            ),
                        validator: (value) {
                          isURL(instagramController.text);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    /*  isLoading
                        ? CircularProgressIndicator(color: Colors.purple,)
                        :*/
                   isLoading == true? CircularProgressIndicator(color: Colors.purple,):Container(
                      height: 50,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextButton(
                        onPressed: () async {

                          /*await usernameCheck();



                          if (userNameController.text != '') {
                            if (exists == false && widget.user.id != userId) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('User name already exists'),
                              ));
                              return;
                            }

                            user!.updateDisplayName(
                                userNameController.text.toLowerCase());
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.user.id)
                                .update({
                              'name': userNameController.text.toLowerCase(),
                            });
                            widget.user.name =
                                userNameController.text.toLowerCase();
                          }*/
                          /////######################
                          var ima =_userImageFile;
                         var bio =bioController.text;
                          var insta =instagramController.text;


                          setState(() {
                            isLoading = true;
                          });

                          if (bio != '') {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.user.id)
                                .update({
                              'bio': bioController.text,
                            });
                            widget.user.bio = bio;
                            /* FirebaseFirestore.instance.collection('following').doc(widget.user.uuid).collection('userFollowing')
                                      .doc(currentUserId).update({
                                    'bio':bioController.text,
                                  });*/
                          }

                          if (insta != '') {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.user.id)
                                .update({
                              'instagram': insta,
                            });
                            widget.user.instagram = insta;
                          }

                          if (ima != null) {
                            final ref = FirebaseStorage.instance
                                .ref()
                                .child('user_image')
                                .child(widget.user.id + '.jpg');
                            await ref
                                .putFile(ima)
                                .whenComplete(() => null);
                            final url = await ref.getDownloadURL();

                           await user!.updatePhotoURL(url);
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.user.id)
                                .update({
                              'photo': url,
                            }).then((value) => widget.user.photo = url).then((value) =>updatePostePic(user?.uid, url) );



                          }
                          
                          
                           setState(() {
                            isLoading=false;
                          });
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomeScreen(widget.user,'profile')));
                        },
                        child: Text('Save',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
