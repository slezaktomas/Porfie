import 'dart:ffi';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:porfie/LoadingWidget.dart';
import 'package:porfie/auth_screen.dart';
import 'package:porfie/login_screen.dart';
import 'package:porfie/main_screen.dart';
import 'package:porfie/update_post_screen.dart';
import 'add_post_screen.dart';
import 'registration_screen.dart';
import 'column_builder.dart';
import 'package:intl/intl.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'about_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'webview.dart';

enum _MenuValues {
  about,
  signout,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String firstName = '';
  String lastName = '';
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final aboutController = TextEditingController();
  final emailController = TextEditingController();
  String imageurl = "";

  final FirebaseAuth auth = FirebaseAuth.instance;
  late String uid;
  //add user
  Future addUserDetails() async {
    User user = auth.currentUser!;
    uid = user.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'firstname': firstNameController.text.trim(),
      'lastname': lastNameController.text.trim(),
      'about': aboutController.text.trim(),
    });
  }

//widget controller
  Widget controler(var ac, var sd) {
    Uri ur = Uri.parse(sd);
    var sr = Uri.encodeFull(sd);
    if (ac == 'certificate') {
      if (sd != "") {
        return Padding(
          padding: EdgeInsets.fromLTRB(60, 20, 60, 20),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStatePropertyAll<Color>(const Color(0x171a25)),
            ),
            onPressed: (() {
              Navigator.push(this.context,
                  MaterialPageRoute(builder: (context) => Pdfviewer(s: sd)));
            }),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                child: Icon(Icons.download_sharp),
              ),
              Text("Zobrazit certifikát"),
            ]),
          ),
        );
      } else {
        return Container();
      }
    } else if (sd == "") {
      return Container();
    } else {
      return Padding(
          padding: EdgeInsets.all(30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: sd,
              placeholder: (context, url) => CircularProgressIndicator(
                color: const Color(0xffC83838),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ));
    }
  }

//fucking photo
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  File? _photo;
  final ImagePicker _picker = ImagePicker();
  Future image() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (picked != null) {
        _photo = File(picked.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> deleteFile(String url) async {
    try {
      await firebase_storage.FirebaseStorage.instance.refFromURL(url).delete();
    } catch (e) {
      print("Error deleting db from cloud: $e");
    }
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = basename(_photo!.path);
    final destination = 'users/$uid';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('profile/');
      await ref.putFile(_photo!);
      String url = (await ref.getDownloadURL()).toString();
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        "img": true,
      });
      setState(() {
        imageurl = url;
      });
    } catch (e) {
      print('error occured');
    }
  }

// user text
  Future updateUserText() async {
    User user = auth.currentUser!;
    uid = user.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'about': aboutController.text.trim(),
    });
  }

//filtering
  bool filter = false;
  Widget filterbuttons(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    if (filter) {
      return Column(
          mainAxisSize: MainAxisSize.max,
          children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
              children: [
                MaterialButton(
                    minWidth: deviceWidth * 0.45,
                    child: Text("Osobni rozvoj",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    onPressed: () {
                      setState(() {
                        oR = !oR;
                      });

                      if (oR) {
                        equalP = "personal";
                      } else {
                        equalP = "";
                      }
                    },
                    color:
                        oR ? const Color(0xffC83838) : const Color(0xff2A3044)),
                MaterialButton(
                    minWidth: deviceWidth * 0.45,
                    child: Text("Dovednosti",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    onPressed: () {
                      setState(() {
                        S = !S;
                      });
                      if (S) {
                        equalS = "skill";
                      } else {
                        equalS = "";
                      }
                    },
                    color:
                        S ? const Color(0xffC83838) : const Color(0xff2A3044)),
                MaterialButton(
                    minWidth: deviceWidth * 0.45,
                    child: Text("Certifikáty",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    onPressed: () {
                      setState(() {
                        C = !C;
                      });
                      if (C) {
                        equalC = "certificate";
                      } else {
                        equalC = "";
                      }
                    },
                    color:
                        C ? const Color(0xffC83838) : const Color(0xff2A3044)),
                MaterialButton(
                    minWidth: deviceWidth * 0.45,
                    child: Text("Projekty",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    onPressed: () {
                      setState(() {
                        PR = !PR;
                      });
                      if (PR) {
                        equalPR = "project";
                      } else {
                        equalPR = "";
                      }
                    },
                    color:
                        PR ? const Color(0xffC83838) : const Color(0xff2A3044)),
                MaterialButton(
                    minWidth: deviceWidth * 0.45,
                    child: Text("Volnočasové aktivity",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    onPressed: () {
                      setState(() {
                        H = !H;
                      });
                      if (H) {
                        equalC = "hobbies";
                      } else {
                        equalC = "";
                      }
                    },
                    color:
                        H ? const Color(0xffC83838) : const Color(0xff2A3044)),
                MaterialButton(
                    minWidth: deviceWidth * 0.45,
                    child: Text("Pracovní zkušenosti",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    onPressed: () {
                      setState(() {
                        E = !E;
                      });
                      if (E) {
                        equalC = "experience";
                      } else {
                        equalC = "";
                      }
                    },
                    color:
                        E ? const Color(0xffC83838) : const Color(0xff2A3044)),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(20, 0, 0, 10),
                  child: MaterialButton(
                      onPressed: (() {
                        if (sort) {
                          setState(() {
                            sort = false;
                          });
                        } else {
                          setState(() {
                            sort = true;
                          });
                        }
                      }),
                      child: sort
                          ? Container(
                              width: deviceWidth * 0.5,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.swap_vert,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Seřadit od nejstaršího",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ))
                          : Container(
                              width: deviceWidth * 0.5,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.swap_vert,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Seřadit od nejnovějšího",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              )),
                      color: const Color(0xff2A3044)),
                ),
              ]));
    } else {
      return Container();
    }
  }

//get details
  Future getUserDetails() async {
    User user = auth.currentUser!;
    uid = user.uid;
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      final data = userDoc.data();

      if (userDoc != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        firstNameController.text = data['firstname'] ?? '';
        lastNameController.text = data['lastname'] ?? '';
        aboutController.text = data['about'] ?? '';
        emailController.text = data['email'] ?? '';
      }
    });
  }

  bool sort = true;

  Future ret() async {
    final destination = 'users/$uid/';
    final ref = firebase_storage.FirebaseStorage.instance
        .ref(destination)
        .child('profile/');
    String url = (await ref.getDownloadURL()).toString();
    setState(() {
      imageurl = url;
    });
  }

  Future wait() async {
    Future.delayed(Duration(milliseconds: 500), () {
      //Delay here
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
    ret();
    wait();
  }

  bool _isLoading = true;
//control
  bool oR = true;
  bool S = true;
  bool C = true;
  bool PR = true;
  bool H = true;
  bool E = true;
  var equalP = "personal";
  var equalS = "skill";
  var equalC = "certificate";
  var equalPR = "project";
  var equalH = "hobbies";
  var equalE = "experience";
  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("posts")
        .orderBy("date", descending: sort)
        .where("type",
            whereIn: [equalP, equalS, equalC, equalPR, equalH, equalE]);
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    final p = deviceWidth * 0.8;
    final p1 = deviceHeight * 0.25;
    return _isLoading
        ? LoadingWidget()
        : Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButton: FloatingActionButton(
              elevation: 10.0,
              backgroundColor: const Color(0xffC83838),
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const AddPost()));
              },
            ),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff171A25),
              elevation: 0,
              title: SvgPicture.asset(
                'assets/images/logo2.svg',
                width: 30,
                height: 30,
              ),
              actions: <Widget>[
                PopupMenuButton<_MenuValues>(
                  child: Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      child: const Text("O porfie",
                          style: TextStyle(color: Colors.white)),
                      value: _MenuValues.about,
                    ),
                    PopupMenuItem(
                      child: Text("Odhlásit se",
                          style: TextStyle(color: Colors.red)),
                      value: _MenuValues.signout,
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case _MenuValues.about:
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AboutScreen()));
                        break;
                      case _MenuValues.signout:
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MainScreen()));
                        break;
                    }
                  },
                  color: const Color(0xff2A3044),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                    Container(
                        width: deviceWidth * 0.9,
                        height: deviceHeight * 0.23,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                image();
                              },
                              child: Container(
                                child: CircleAvatar(
                                  backgroundColor: Color(0xff171A25),
                                  radius: 55,
                                  foregroundImage:
                                      CachedNetworkImageProvider(imageurl),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(1.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          firstNameController.text,
                                          style: new TextStyle(
                                            fontSize: 26.0,
                                            fontFamily: 'Roboto',
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          " " + lastNameController.text,
                                          style: new TextStyle(
                                            fontSize: 26.0,
                                            fontFamily: 'Roboto',
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                      width: p * 0.5,
                                      height: p1 * 0.65,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: (() {}),
                                          child: Container(
                                            height: 150,
                                            width: 150,
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: Center(
                                              child: Text(
                                                aboutController.text,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        )),
                    Container(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(bottom: 25.0),
                                child: GestureDetector(
                                  onTap: (() {
                                    showModalBottomSheet(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(45))),
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return Padding(
                                            padding: MediaQuery.of(context)
                                                .viewInsets,
                                            child: Container(
                                              height: deviceHeight * 0.45,
                                              color: const Color(0xff171A25),
                                              child: SafeArea(
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      25.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Expanded(
                                                                // first name
                                                                child:
                                                                    TextField(
                                                                  onTap: () {
                                                                    () => FocusScope.of(
                                                                            context)
                                                                        .unfocus();
                                                                  },
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                  controller:
                                                                      firstNameController,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          const BorderSide(
                                                                              color: Color(0xff2A3044)),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          const BorderSide(
                                                                              color: Colors.white),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25),
                                                                    ),
                                                                    hintText:
                                                                        'Jméno',
                                                                    hintStyle:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    fillColor:
                                                                        const Color(
                                                                            0xff2A3044),
                                                                    filled:
                                                                        true,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10,
                                                                  height: 20),
                                                              Expanded(
                                                                // last name
                                                                child:
                                                                    TextField(
                                                                  onTap: () {
                                                                    () => FocusScope.of(
                                                                            context)
                                                                        .unfocus();
                                                                  },
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                  controller:
                                                                      lastNameController,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          const BorderSide(
                                                                              color: Color(0xff2A3044)),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          const BorderSide(
                                                                              color: Colors.white),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25),
                                                                    ),
                                                                    hintText:
                                                                        'Příjmení',
                                                                    hintStyle:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    fillColor:
                                                                        const Color(
                                                                            0xff2A3044),
                                                                    filled:
                                                                        true,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 20),
                                                            ],
                                                          )),
                                                      const SizedBox(
                                                          height: 10),
                                                      // class
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    25.0),
                                                        child: TextField(
                                                          onTap: () {
                                                            () => FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                          },
                                                          keyboardType:
                                                              TextInputType
                                                                  .multiline,
                                                          maxLines: 5,
                                                          maxLength: 100,
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .top,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                          controller:
                                                              aboutController,
                                                          decoration:
                                                              InputDecoration(
                                                            counterStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Color(
                                                                          0xff2A3044)),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .white),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25),
                                                            ),
                                                            hintText:
                                                                'Něco málo o sobě...',
                                                            hintStyle:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            fillColor:
                                                                const Color(
                                                                    0xff2A3044),
                                                            filled: true,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),

                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 25.0,
                                                            vertical: 30.0,
                                                          ),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              addUserDetails();
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const HomeScreen()));
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(20),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: const Color(
                                                                    0xffC83838),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            35),
                                                              ),
                                                              child:
                                                                  const Center(
                                                                child: Text(
                                                                  'Uložit',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          20),
                                                                ),
                                                              ),
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  }),
                                  child: Container(
                                    height: deviceHeight * 0.05,
                                    width: deviceWidth * 0.8,
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffC83838),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Upravit profil',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ),
                                  ),
                                )),
                          ]),
                    ),

                    Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                                child: Text(
                                  "Filtering",
                                  style: new TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(20, 0, 0, 10),
                      child: MaterialButton(
                          onPressed: (() {
                            if (filter) {
                              setState(() {
                                filter = false;
                              });
                            } else {
                              setState(() {
                                filter = true;
                              });
                            }
                          }),
                          child: Icon(Icons.menu, color: Colors.white),
                          color: filter
                              ? const Color(0xffC83838)
                              : const Color(0xff2A3044)),
                    ),
                    filterbuttons(context),

                    //builder postů
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: query.snapshots(),
                      builder: ((BuildContext context, snapshot) {
                        return ColumnBuilder(
                          itemCount: snapshot.data?.docs.length ?? 0,
                          itemBuilder: (context, index) {
                            final docs = snapshot.data!.docs;
                            final data = docs[index].data();
                            final s = docs[index].id;
                            final contHeight = deviceHeight * 0.35;
                            final contWidth = deviceWidth * 0.8;
                            String val = "";
                            switch (data["type"]) {
                              case "personal":
                                val = "Osobní rozvoj";
                                break;
                              case "skill":
                                val = "Dovednost";
                                break;
                              case "certificate":
                                val = "Certifikát";
                                break;
                              case "project":
                                val = "Projekt";
                                break;
                              case "hobbies":
                                val = "Volnočasová aktivita";
                                break;
                              case "experience":
                                val = "Pracovní zkušenosti";
                                break;
                            }
                            return Padding(
                                padding: EdgeInsets.all(10),
                                child: Container(
                                  constraints: BoxConstraints(
                                    minHeight: deviceHeight * 0.35,
                                    maxWidth: deviceWidth * 0.8,
                                  ),
                                  child: Column(children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(20, 10, 5, 0),
                                          child: Text(
                                            val,
                                            style: new TextStyle(
                                              fontSize: 20.0,
                                              fontFamily: 'Roboto',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 10, 0),
                                            child: TextButton(
                                              child: Text(
                                                "Upravit post",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              onPressed: () {
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            UpdatePost(
                                                              klic: s,
                                                            )));
                                              },
                                            ))
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 5, 10),
                                        child: Text(
                                          data["header"] ?? null,
                                          style: new TextStyle(
                                            fontSize: 24.0,
                                            fontFamily: 'Roboto',
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 20, 0),
                                        child: Text(
                                          data["date"],
                                          style: new TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: 'Roboto',
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 10, 20, 0),
                                        child: Text(
                                          data["content"] ?? null,
                                          style: new TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: 'Roboto',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    controler(
                                        data["type"], data["fileUrl"] ?? ""),
                                  ]),
                                  decoration: BoxDecoration(
                                      color: Color(0xff2A3044),
                                      border: Border.all(
                                        color: const Color(0xff2A3044),
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ));
                          },
                        );
                      }),
                    )
                  ])),
            ));
  }
}
