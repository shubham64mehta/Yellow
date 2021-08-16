import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:yellow/Form/form.dart';
import 'package:hive/hive.dart';
import 'package:yellow/Google%20Auth/googleauth.dart';
import 'package:yellow/global.dart';
import 'package:yellow/main.dart';
import 'package:yellow/model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:delayed_display/delayed_display.dart';

String downloadurl;
bool checkimage = false;

class Homescreen extends StatefulWidget {
  const Homescreen({Key key}) : super(key: key);

  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Box<Data> yellowbox;
  List<int> count;
  final picker = ImagePicker();

  File image2;

  var _name = "";
  var _director = "";
  TextEditingController ctr1 = TextEditingController();
  TextEditingController ctr2 = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    yellowbox = Hive.box<Data>("yellow");
    // count = yellowbox.values.cast<int>().toList();
  }

  Future uploadToStorage() async {
    try {
      PickedFile file = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 30,
      );
      this.setState(() {
        image2 = File(file.path);
      });

      await uploadimage(image2);
    } catch (error) {
      print(error);
    }
  }

  Future<String> uploadimage(var imagefile) async {
    var uuid = new Uuid().v1();
    StorageReference ref =
        FirebaseStorage.instance.ref().child("post_$uuid.jpg");

    await ref.putFile(imagefile).onComplete.then((val) {
      val.ref.getDownloadURL().then((val) {
        print(val);
        downloadurl = val;
        setState(() {
          checkimage = !checkimage;
        });
      });
    });
    return downloadurl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: CupertinoColors.white,
          iconTheme: IconThemeData(color: CupertinoColors.activeBlue),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              Container(
                height: 250,
                color: CupertinoColors.activeBlue,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height / 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CachedNetworkImage(
                          imageUrl: image,
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            radius: 28,
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      SizedBox(height: 8),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23))),
                      SizedBox(height: 8),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(email,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15))),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Text("Profile",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                leading: Icon(Icons.person_outline),
                onTap: () {},
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 1.9,
              ),
              ListTile(
                  title: Text("Logout",
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  leading: Icon(Icons.logout),
                  onTap: () {
                    Navigator.pop(context);
                    signOutGoogle().then((_) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    });
                  }),
            ],
          ),
        ),
        backgroundColor: CupertinoColors.white,
        floatingActionButton: FloatingActionButton(
            backgroundColor: CupertinoColors.activeBlue,
            child: Icon(CupertinoIcons.add),
            elevation: 4,
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Form1()));
            }),
        body: Column(
          children: [
            Expanded(
              child: Container(
                child: ValueListenableBuilder(
                    valueListenable: yellowbox.listenable(),
                    builder: (context, Box<Data> todo, _) {
                      List<int> keys = todo.keys.cast<int>().toList();

                      return todo.values.isEmpty
                          ? Center(
                              child: Image.asset(
                                "images/file.png",
                                height: 190,
                              ),
                            )
                          : ListView.separated(
                              separatorBuilder: (context, index) => Divider(
                                color: CupertinoColors.systemGrey,
                                endIndent: 20,
                                indent: 20,
                                height: 1,
                                thickness: 0,
                              ),
                              itemCount: keys.length,
                              itemBuilder: (context, index) {
                                final int key = keys[index];
                                final Data check = todo.get(key);
                                return Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: CachedNetworkImage(
                                    imageUrl: check.image,
                                    imageBuilder: (context, imageProvider) =>
                                        Card(
                                      shadowColor: Colors.black,
                                      elevation: 15,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  3,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.fill)),
                                            ),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            check.name,
                                                            style: TextStyle(
                                                                shadows: <
                                                                    Shadow>[
                                                                  Shadow(
                                                                      offset: Offset(
                                                                          2.0,
                                                                          2.0),
                                                                      blurRadius:
                                                                          3.0,
                                                                      color: Colors
                                                                              .grey[
                                                                          300]),
                                                                  Shadow(
                                                                      offset: Offset(
                                                                          2.0,
                                                                          2.0),
                                                                      blurRadius:
                                                                          3.0,
                                                                      color: Colors
                                                                              .grey[
                                                                          300]),
                                                                ],
                                                                color: Colors
                                                                    .blue[400],
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          )),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            check.director,
                                                            style: TextStyle(
                                                                shadows: <
                                                                    Shadow>[
                                                                  Shadow(
                                                                      offset: Offset(
                                                                          5.0,
                                                                          5.0),
                                                                      blurRadius:
                                                                          3.0,
                                                                      color: Colors
                                                                          .white),
                                                                  Shadow(
                                                                      offset: Offset(
                                                                          5.0,
                                                                          5.0),
                                                                      blurRadius:
                                                                          3.0,
                                                                      color: Colors
                                                                          .white),
                                                                ],
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.5),
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.edit,
                                                      color: Colors.yellow[900],
                                                    ),
                                                    onPressed: () {
                                                      showDialog(
                                                          context: context,
                                                          builder:
                                                              (context) =>
                                                                  AlertDialog(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20)),
                                                                    content:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(20)),
                                                                      width:
                                                                          600,
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height /
                                                                          1.4,
                                                                      child:
                                                                          SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            CachedNetworkImage(
                                                                              imageBuilder: (context, imgaeProvider) => Container(
                                                                                height: 300,
                                                                                width: 300,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(15),
                                                                                  image: checkimage == false ? DecorationImage(image: imageProvider, fit: BoxFit.fill) : DecorationImage(image: NetworkImage(downloadurl), fit: BoxFit.fill),
                                                                                ),
                                                                              ),
                                                                              imageUrl: check.image,
                                                                              placeholder: (context, url) => Center(
                                                                                child: CircularProgressIndicator(),
                                                                              ),
                                                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                                                            ),
                                                                            SizedBox(
                                                                              height: 20,
                                                                            ),
                                                                            Center(
                                                                              child: Card(
                                                                                elevation: 2,
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                                                                                  width: MediaQuery.of(context).size.width / 1.1,
                                                                                  height: MediaQuery.of(context).size.height / 14,
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
                                                                                      decoration: InputDecoration(prefixIcon: Icon(Icons.movie), border: InputBorder.none, hintText: check.name, hintStyle: TextStyle(color: Colors.black38, fontSize: 19)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height: 20,
                                                                            ),
                                                                            Center(
                                                                              child: Card(
                                                                                elevation: 2,
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                                                                                  width: MediaQuery.of(context).size.width / 1.1,
                                                                                  height: MediaQuery.of(context).size.height / 14,
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
                                                                                        _director = value;
                                                                                      },
                                                                                      decoration: InputDecoration(prefixIcon: Icon(Icons.person), border: InputBorder.none, hintText: check.director, hintStyle: TextStyle(color: Colors.black38, fontSize: 19)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: 20),
                                                                            Center(
                                                                              child: Container(
                                                                                width: 200,
                                                                                child: CupertinoButton(
                                                                                  color: CupertinoColors.activeBlue,
                                                                                  child: Center(
                                                                                    child: Text("Update"),
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    if (ctr1.text.isEmpty || ctr2.text.isEmpty) {
                                                                                      Data object = Data(director: check.director, name: check.name, image: check.image);
                                                                                      yellowbox.putAt(index, object);

                                                                                      Navigator.pop(context);
                                                                                    } else {
                                                                                      Data object = Data(director: ctr2.text, name: ctr1.text, image: check.image);
                                                                                      yellowbox.putAt(index, object);

                                                                                      ctr1.clear();
                                                                                      ctr2.clear();

                                                                                      Navigator.pop(context);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ));
                                                    }),
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (_) {
                                                            return CupertinoAlertDialog(
                                                              title: Text(
                                                                  'Are You Sure?'),
                                                              content: Text(
                                                                  'it will be permanently deleted'),
                                                              actions: <Widget>[
                                                                CupertinoDialogAction(
                                                                  child: Text(
                                                                      'Yes'),
                                                                  onPressed:
                                                                      () {
                                                                    todo.deleteAt(
                                                                        index);
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                CupertinoDialogAction(
                                                                  child: Text(
                                                                      'No'),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          });
                                                    })
                                              ],
                                            )
                                          ],
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.4,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2.3,
                                      ),
                                    ),
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                );
                              },
                            );
                    }),
              ),
            ),
          ],
        ));
  }
}
