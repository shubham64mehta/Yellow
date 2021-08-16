import 'dart:io';
import 'package:flutter/cupertino.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:yellow/Google%20Auth/googleauth.dart';
import 'package:yellow/Homescreen/homescreen.dart';
//import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yellow/model.dart';
import 'package:yellow/splashscreen/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Directory directory = await getApplicationDocumentsDirectory();

  Hive..init(directory.path);
  Hive.registerAdapter(DataAdapter());
  await Hive.openBox<Data>("Yellow");
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Login()));
}

class Login extends StatelessWidget {
  const Login({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 8),
          Center(
            child: Image.asset(
              "images/Pulp.gif",
              alignment: Alignment.center,
              height: 400,
            ),
          ),
          SizedBox(
            height: 70,
          ),
          Center(
              child: Card(
            elevation: 15,
            shadowColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 350,
              height: 70,
              child: CupertinoButton(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(20),
                  onPressed: () async {
                    signInWithGoogle().whenComplete(() async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return Homescreen();
                          },
                        ),
                      );
                    });
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: ExactAssetImage("images/google.jpg"),
                        radius: 20,
                      ),
                      SizedBox(width: 30),
                      Text(
                        "Login with Google",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  )),
            ),
          )),
        ],
      ),
    );
  }
}
