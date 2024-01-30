import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();

  Future<void> resetPass() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _email.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                  "Password reset link sent! check your inbox & junk  or spam folder"),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("error: ${e.message.toString()}"),
            );
          });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('reset password', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 50),
        child: Column(
          children: [
            const Text(
              "\"We will send a reset password link to your email address\"",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _email,
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
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Color(0xfff1efe5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: Text('Send',style: TextStyle(color: Colors.black),), onPressed: () => resetPass()),
          ],
        ),
      ),
    );
  }
}
