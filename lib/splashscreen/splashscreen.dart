//import 'package:delayed_display/delayed_display.dart';
import 'package:custom_splash/custom_splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yellow/main.dart';

class Splash extends StatefulWidget {
  const Splash({Key key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return CustomSplash(
      imagePath: 'images/Pulp.png',
      backGroundColor: CupertinoColors.white,
      animationEffect: 'zoom-in',
      logoSize: 800,
      home: Login(),
      duration: 8800,
      type: CustomSplashType.StaticDuration,
    );
  }
}
