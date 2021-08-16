import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
//import 'package:uuid/uuid.dart';
//import 'package:yellow/Form/data.dart';
import 'package:yellow/model.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

String downloadurl;
bool check = false;
bool loading = false;

class Form1 extends StatefulWidget {
  const Form1({Key key}) : super(key: key);

  @override
  _Form1State createState() => _Form1State();
}

class _Form1State extends State<Form1> {
  Box<Data> yellowbox;

  final picker = ImagePicker();

  File image2;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final formkey = GlobalKey<FormState>();

  var _name = "";
  var _dir = "";

  TextEditingController ctr1 = TextEditingController();
  TextEditingController ctr2 = TextEditingController();

  Future<void> _trysubmit(BuildContext ctx) async {
    final isvalid = formkey.currentState.validate();
    FocusScope.of(ctx).unfocus();
    if (isvalid) {
      formkey.currentState.save();
    } else {}
    /* _submitAuthForm(_email.trim(), _passwd.trim(), _name.trim(), _number.trim(),
        _address.trim(), _state.trim(), _city.trim(), ctx);*/
  }

  Future<String> uploadToStorage(BuildContext context) async {
    try {
      PickedFile file = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 30,
      );

      this.setState(() {
        image2 = File(file.path);
        loading = !loading;
      });

      if (loading == true) {
        showDialog(
            context: context,
            builder: (context) => Center(child: CircularProgressIndicator()));
      }

      await uploadimage(image2, context);
    } catch (error) {
      print(error);
    }
    return downloadurl;
  }

  Future<String> uploadimage(var imagefile, BuildContext context) async {
    var uuid = new Uuid().v1();
    StorageReference ref =
        FirebaseStorage.instance.ref().child("post_$uuid.jpg");

    await ref.putFile(imagefile).onComplete.then((val) {
      val.ref.getDownloadURL().then((val) {
        print(val);
        setState(() {
          check = !check;
          // loading = !loading;
          // Navigator.of(context).pop(true)
        });
        downloadurl = val;
      });
    });
    return downloadurl;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    yellowbox = Hive.box<Data>("yellow");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: CupertinoColors.activeBlue),
        elevation: 0,
      ),
      // backgroundColor: Colors.transparent,
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 20,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  uploadToStorage(context)
                      .then((value) => Navigator.of(context).pop(true));
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      shadowColor: Colors.black,
                      elevation: 25,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height / 3,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            image: check == false
                                ? DecorationImage(
                                    image: ExactAssetImage("images/icon.png",
                                        scale: 4),
                                    alignment: Alignment.center)
                                : DecorationImage(
                                    image: NetworkImage(downloadurl),
                                    fit: BoxFit.fill),
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 80),
            Form(
                key: formkey,
                child: Column(
                  children: [
                    Center(
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 6,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15)),
                          width: MediaQuery.of(context).size.width / 1.1,
                          height: MediaQuery.of(context).size.height / 14,
                          //  color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: ctr1,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Required";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _name = value;
                              },
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.movie),
                                  border: InputBorder.none,
                                  hintText: " Film Name",
                                  hintStyle: TextStyle(
                                      color: Colors.black38, fontSize: 19)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Center(
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 6,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15)),
                          width: MediaQuery.of(context).size.width / 1.1,
                          height: MediaQuery.of(context).size.height / 14,
                          //color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: ctr2,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Required";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _dir = value;
                              },
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  border: InputBorder.none,
                                  hintText: "Director",
                                  hintStyle: TextStyle(
                                      color: Colors.black38, fontSize: 19)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: Container(
                        width: 200,
                        child: CupertinoButton(
                          color: Colors.blue,
                          child: Center(
                            child: Text("Add +"),
                          ),
                          onPressed: () {
                            _trysubmit(context).then((value) {
                              Data data = Data(
                                  name: ctr1.text,
                                  director: ctr2.text,
                                  image: downloadurl);
                              yellowbox.add(data);

                              ctr1.clear();
                              ctr2.clear();
                              check = !check;
                            });

                            //final key = uuid.v1();
                            //final value ={"name":}

                            Navigator.pop(context);
                          },
                        ),
                      ),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
