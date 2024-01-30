//main
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:jinx/screens/feed_screen.dart';
import 'package:jinx/screens/forgot_password_screen.dart';
import 'package:jinx/screens/home_screen.dart';
import 'package:jinx/screens/privacypolicy_screen.dart';
import 'package:jinx/screens/termsandconditions_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'image_picker.dart';
import 'models/user_model.dart';

//import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(
      /*options: DefaultFirebaseOptions.currentPlatform*/);
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //NotificationService().initNotification()

  await Firebase.initializeApp();
// Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => isSelected(),
      ),
      ChangeNotifierProvider(
        create: (_) => chatselected(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: Provider(
        create: (context) => UserModel,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FlutterChat',
          theme: ThemeData(
            //primarySwatch:Colors.black,

            accentColor: Colors.purple,
            accentColorBrightness: Brightness.dark,
            //copyWith allow us to override some of the keys and use the default values
            buttonTheme: ButtonTheme.of(context).copyWith(
                buttonColor: Color(0xfff1efe5),
                textTheme: ButtonTextTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
          ),
          home: CheckUserIsSignedIn(),
        ),
      ),
    );
  }
}

class CheckUserIsSignedIn extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future checkCurrentUser() async {
    if (_firebaseAuth.currentUser != null) {
      //checking if current user is authenticate
      var userExist = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: _firebaseAuth.currentUser!.uid)
          .get();
      UserModel userModel = UserModel.fromMap(userExist.docs.first);
      // await updateUser('online');
      return HomeScreen(userModel,'feedScreen');
    } else {
      //await updateUser('offline');
      //AuthScreen()
      return AuthScreen();
    }
  }

  /* updateUser(status)async{
    await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
      'status': status
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: checkCurrentUser(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Container(
                padding: EdgeInsets.only(top: 200),
                child: Column(
                  children: [
                    Center(
                      child: RichText(
                          text: TextSpan(
                        style: GoogleFonts.mochiyPopPOne(fontSize: 50),
                        children: const <TextSpan>[
                          TextSpan(
                              text: 'jin',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xfff1efe5))),
                          TextSpan(
                              text: 'X',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple)),
                        ],
                      )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        height: 3,
                        width: 200,
                        child: Center(
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.purple,
                          ),
                        )),
                  ],
                ),
              ),
            );
          }

          //snapshot.data
          //AuthScreen()
          //HomeScreen
          //setStatusmanual("online");


            return snapshot.data;


        });
  }
}

//auth screen #######################

////////////////////////auth Screen
class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

mapUser(userId, ctx) async {
  var userExist = await FirebaseFirestore.instance
      .collection('users')
      .where('id', isEqualTo: userId)
      .get();
  var user = FirebaseAuth.instance.currentUser;
  if (userExist.docs.isNotEmpty) {
    UserModel userModel = UserModel.fromMap(userExist.docs.first);

    ///you can delete both update
    user!.updateDisplayName(userModel.name);
    user.updatePhotoURL(userModel.photo);


    ///getusertoken was hehehehehhee

    getToken(userId);
    Navigator.pushReplacement(
        ctx, MaterialPageRoute(builder: (context) => HomeScreen(userModel,'feedScreen')));
  }
}

var token;

void getToken(userid) async {
  await FirebaseMessaging.instance.getToken().then((value) {
    //setState(() {
    token = value;
    print("token: $value");
    // });
  }).then((value) => FirebaseFirestore.instance
      .collection('users')
      .doc(userid)
      .update({'token': token, 'status': 'online'}));
}

makeUsersFollowJinx()async{
  DocumentSnapshot jinx = await FirebaseFirestore.instance.collection('users').doc("jLhQUkYfk2Nelc3H9aRn45FJpap2").get();
  QuerySnapshot users = await FirebaseFirestore.instance.collection('users').get();
  users.docs.forEach((element) { if(element.id !="jLhQUkYfk2Nelc3H9aRn45FJpap2"){
    FirebaseFirestore.instance.collection('followers')
        .doc(jinx.id)
        .collection('userFollowers')
        .doc(element.id)
        .set({
      'name': element['name'],
      'photo': element['photo'],
      'uuid': element['id'],
      'status': element['status']
    });

    FirebaseFirestore.instance.collection('following')
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


class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isloading = false;

  void _submitAuthForm(
    String email,
    String password,
    String name,
    DateTime dob,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential authResult;

    try {
      setState(() {
        _isloading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        mapUser(authResult.user!.uid, context);
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child(authResult.user!.uid + '.jpg');
        await ref.putFile(_imageFile!).whenComplete(() => null);
        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user?.uid)
            .set({
          'id': authResult.user?.uid,
          'name': name.toLowerCase(),
          'email': email.toLowerCase(),
          'dob': dob,
          'photo': url,
          'bio': '',
          'instagram': '',
          'status': 'online',
          'token': token,
          'followers':[],
          'following':[]
        });
        makeUsersFollowJinx();
        FirebaseAuth.instance.currentUser?.sendEmailVerification();
        mapUser(authResult.user?.uid, ctx);
      }
    } on FirebaseAuthException catch (e) {
      if (e.message != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text('${e.message}'),
          backgroundColor: Colors.red,
        ));
      }
      setState(() {
        _isloading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AuthForm(_submitAuthForm, _isloading),
    );
  }
}

File? _imageFile;

///////////////////////////AuthForm//////////

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn, this.isloading);

  final void Function(String email, String password, String name, DateTime dob,
      bool isLogin, BuildContext ctx) submitFn;
  final bool isloading;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;

  //note these var type can be String as well
  var _email = '';
  var _name = '';
  var _password = '';
  DateTime _dateOfBirth = DateTime.now();
  bool exists = false;

  void _pickedImage(File image) {
    _imageFile = image;
  }

  void _trySubmit() async {
    //Note: if put currentState! then in the if statement can be just isValid,
    // if put ? then have to specify that isValid wont be null in if statement by adding isValid!
    final isValid = _formKey.currentState!.validate();
    //this removes the keyboard when the data is submitted
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(
          _email, _password, _name, _dateOfBirth, _isLogin, context);
    }
  }

  Future<void> usernameCheck() async {
    final result = await FirebaseFirestore.instance
        .collection("users")
        .where('name', isEqualTo: _name.toLowerCase())
        .get();

    setState(() {
      exists = result.docs.isEmpty;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //usernameCheck();
    return Center(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 18,
              ),
              RichText(
                  text: TextSpan(
                style: GoogleFonts.mochiyPopPOne(fontSize: 60),
                children: const <TextSpan>[
                  TextSpan(
                      text: 'jin',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xfff1efe5))),
                  TextSpan(
                      text: 'X',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.purple)),
                ],
              )),
              if (!_isLogin) UserImagePicker(_pickedImage),
              if (_isLogin)
                const SizedBox(
                  height: 18,
                ),
              TextFormField(
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                key: ValueKey('email'),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(

                    //focusColor: Colors.black,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xfff1efe5),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    hintText: 'Email Address',
                    hintStyle: TextStyle(color: Color(0xfff1efe5))
                    //hintText: 'Enter Invited Phone Number'
                    ),
                onSaved: (value) {
                  _email = value!;
                },
              ),
              const SizedBox(
                height: 12,
              ),
              if (!_isLogin)
                TextFormField(
                  maxLength: 16,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z._]")),
                    FilteringTextInputFormatter.deny('\n'),
                  ],
                  style: TextStyle(color: Colors.white),
                  key: ValueKey('name'),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 3) {
                      return 'Please enter at least 3 characters';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(

                      //focusColor: Colors.black,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xfff1efe5),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      hintText: 'User Name',
                      hintStyle: TextStyle(color: Color(0xfff1efe5))
                      //hintText: 'Enter Invited Phone Number'
                      ),
                  onSaved: (value) {
                    _name = value!;
                  },
                  onChanged: (v) {
                    _name = v;
                  },
                ),
              SizedBox(
                height: 12,
              ),
              if (!_isLogin)
                Text(
                  'Date of Birth',
                  style: TextStyle(color: Color(0xfff1efe5), fontSize: 18),
                ),
              if (!_isLogin)
                Container(
                    height: 150,
                    child: CupertinoDatePicker(
                      backgroundColor: Color(0xfff1efe5),
                      maximumYear: DateTime.now().year,
                      mode: CupertinoDatePickerMode.date,
                      onDateTimeChanged: (DateTime dateOfBirth) {
                        _dateOfBirth = dateOfBirth;
                      },
                    )),
              if (!_isLogin)
                SizedBox(
                  height: 12,
                ),
              TextFormField(
                style: TextStyle(color: Colors.white),
                key: ValueKey('password'),
                validator: (value) {
                  if (value!.isEmpty || value.length < 7) {
                    return 'Password must be at least 7 characters long.';
                  }
                  return null;
                },
                decoration: const InputDecoration(

                    //focusColor: Colors.black,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xfff1efe5),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Color(0xfff1efe5))
                    //hintText: 'Enter Invited Phone Number'
                    ),
                obscureText: true,
                onSaved: (value) {
                  _password = value!;
                },
              ),
              SizedBox(
                height: 15,
              ),
              if (widget.isloading)
                CircularProgressIndicator(
                  color: Colors.purple,
                ),
              if (!widget.isloading)
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xfff1efe5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_isLogin ? 'Login' : 'Signup',style: TextStyle(color: Colors.black),),
                    ),
                    onPressed: () async {
                      await usernameCheck();
                      if (_imageFile == null && !_isLogin) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Please add a photo of you'),
                        ));
                        return;
                      }

                      if (exists == false || _name == "anonymous") {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('User name already exists'),
                        ));
                        return;
                      }

                   /*   if (_dateOfBirth.isAfter(DateTime.utc(2018, 12, 01)) &&
                          !_isLogin) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Select a valid date of birth'),
                        ));
                        return;
                      }*/
                      _trySubmit();
                    }),
              if (!widget.isloading && _isLogin)
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.purple, // foreground
                  ),

                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen())),
                ),
              if (!widget.isloading)
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.purple, // foreground
                  ),

                  child: Text(
                    _isLogin
                        ? 'Create new account?'
                        : 'I already have an account?',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                  onPressed: () {
                    setState(() {
                      //or _isLogin = false;
                      _isLogin = !_isLogin;
                    });
                  },
                ),
              SizedBox(
                height: 5,
              ),
              InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TermsAndConditionsScreens())),
                child: Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PrivacyPolicyScreen())),
                /*_launchUrl('https://www.freeprivacypolicy.com/live/8974f4e3-9a74-4d29-9415-d28f5b83b4cc'),*/
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
