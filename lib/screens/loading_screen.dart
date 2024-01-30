import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  const TextSpan(
                      text: 'jin',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xfff1efe5))),
                  const TextSpan(
                      text: 'X',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.purple)),
                ],
              )),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
                height: 3,
                width: 200,
                child: const Center(
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.purple,
                  ),
                )),
          ],
        ),
      ),
    );
    ;
  }
}
