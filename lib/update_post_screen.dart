import 'dart:ffi';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:porfie/add_post_screen.dart';
import 'package:porfie/home_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import "LoadingWidget.dart";

class UpdatePost extends StatefulWidget {
  const UpdatePost({
    Key? key,
    required this.klic,
  }) : super(key: key);
  final String klic;

  @override
  State<UpdatePost> createState() => _UpdatePostState();
}

const map = {
  "personal": "Osobní rozvoj",
  "skill": "Dovednost",
  "certificate": "Certifikát",
  "project": "Projekt",
  "hobbies": "Volnočasová aktivita",
  "experience": "Pracovní zkušenost"
};
const List<String> list = <String>[
  'Osobní rozvoj',
  'Dovednost',
  'Certifikát',
  'Projekt',
  'Volnočasová aktivita',
  'Pracovní zkušenost',
];

class _UpdatePostState extends State<UpdatePost> {
  final headerController = TextEditingController();
  final contentController = TextEditingController();
  var imageurl;
  var contvalue;
  int? filen;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late String uid;
  String dropdownValue = "";
  void initState() {
    super.initState();
    getPostDetails();
    certcontrol();
  }

  bool _isLoading = true;
  var name;
  Future getPostDetails() async {
    User user = auth.currentUser!;
    uid = user.uid;
    final DocumentSnapshot postDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('posts')
        .doc(widget.klic)
        .get();
    setState(() {
      final data = postDoc.data();

      if (postDoc != null) {
        final data = postDoc.data() as Map<String, dynamic>;
        headerController.text = data['header'] ?? '';
        contentController.text = data['content'] ?? '';
        filen = data['file'] ?? null;
        dropdownValue = data['type'] ?? '';
        imageurl = data["fileUrl"] ?? null;
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  File? _photo;
  final ImagePicker _picker = ImagePicker();
  File? _file;

  Future deletePost() async {
    User user = auth.currentUser!;
    uid = user.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('posts')
        .doc(widget.klic)
        .delete();
  }

  Future uploadFile() async {
    if (imageurl != null) {
      firebase_storage.FirebaseStorage.instance.refFromURL(imageurl).delete();
      imageurl = null;
    }
    User user = auth.currentUser!;
    String uid = user.uid;
    if (_photo == null) return;

    final destination = 'users/$uid';

    try {
      setState(() {
        name = (DateTime.now().millisecondsSinceEpoch / 1000).round();
      });

      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('$name/');
      await ref.putFile(_photo!);
      String url = (await ref.getDownloadURL()).toString();

      setState(() {
        imageurl = url;
      });
    } catch (e) {
      print('error occured');
    }
  }

  Future uploadDocument() async {
    if (imageurl != null) {
      firebase_storage.FirebaseStorage.instance.refFromURL(imageurl).delete();
      imageurl = null;
    }
    User user = auth.currentUser!;
    String uid = user.uid;
    if (_file == null) return;

    final destination = 'users/$uid';

    try {
      setState(() {
        name = (DateTime.now().millisecondsSinceEpoch / 1000).round();
      });
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('$name/');
      await ref.putFile(_file!);
      String url = (await ref.getDownloadURL()).toString();

      setState(() {
        imageurl = url;
      });
    } catch (e) {
      print('error occured');
    }
  }

  Future doc() async {
    final picked = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    setState(() {
      if (picked != null) {
        _file = File(picked.files.single.path!);
        uploadDocument();
      } else {
        print('No document selected.');
      }
    });
  }

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

  Future updatePostDetails() async {
    User user = auth.currentUser!;
    uid = user.uid;

    switch (contvalue) {
      case "Osobní rozvoj":
        dropdownValue = "personal";
        break;
      case "Dovednost":
        dropdownValue = "skill";
        break;
      case "Certifikát":
        dropdownValue = "certificate";
        break;
      case "Projekt":
        dropdownValue = "project";
        break;
      case "Volnočasová aktivita":
        dropdownValue = "hobbies";
        break;
      case "Pracovní zkušenosti":
        dropdownValue = "experience";
        break;
      case null:
        dropdownValue;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("posts")
        .doc(widget.klic)
        .update(({
          'header': headerController.text.trim(),
          'content': contentController.text.trim(),
          'type': dropdownValue,
          'file': name,
          'fileUrl': imageurl,
        }));
  }

  var val = list.first;
  Widget certcontrol() {
    if (dropdownValue == "certificate" || contvalue == "Certifikát") {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
            child: ElevatedButton(
              onPressed: () {
                doc();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffC83838),
                  shape: StadiumBorder()),
              child: Text((() {
                if (imageurl != null) {
                  return "PDF přidáno";
                }

                return "Kliknutím Přidáte PDF";
              })()),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  firebase_storage.FirebaseStorage.instance
                      .refFromURL(imageurl)
                      .delete();
                  imageurl = null;
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffC83838),
                  shape: StadiumBorder()),
              child: Text(
                "Smazat pdf",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    image();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffC83838),
                      shape: StadiumBorder()),
                  child: Text((() {
                    if (imageurl != null) {
                      return "Obrázek přidán";
                    }

                    return "Kliknutím Přidáte obrázek";
                  })()),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      firebase_storage.FirebaseStorage.instance
                          .refFromURL(imageurl)
                          .delete();
                      imageurl = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffC83838),
                      shape: StadiumBorder()),
                  child: Text(
                    "Smazat fotku",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            child: Image(
              height: 150,
              width: 150,
              image: imageurl != null
                  ? NetworkImage(imageurl)
                  : NetworkImage(
                          "https://icons-for-free.com/iconfiles/png/512/image+images+photo+picture+pictures+icon-1320191040579947532.png")
                      as ImageProvider,
            ),
          ),
        ],
      );
    }
  }

  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final devicewidth = MediaQuery.of(context).size.width;
    final s = map[dropdownValue];
    return _isLoading
        ? LoadingWidget()
        : GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xff171A25),
                elevation: 0,
                title: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen())),
                ),
                actions: <Widget>[
                  IconButton(
                    autofocus: false,
                    icon: const Icon(Icons.delete),
                    color: const Color(0xffC83838),
                    tooltip: 'Setting Icon',
                    onPressed: () {
                      deletePost();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                    },
                  ),
                ],
              ),
              body: Center(
                  child: Container(
                      height: deviceHeight * 0.8,
                      width: devicewidth * 0.75,
                      child: Column(
                        children: [
                          TextField(
                            style: const TextStyle(color: Colors.white),
                            controller: headerController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xff2A3044)),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              hintText: headerController.text,
                              hintStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              fillColor: const Color(0xff2A3044),
                              filled: true,
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                              child: Container(
                                height: 200,
                                child: TextField(
                                  maxLines: 10,
                                  style: const TextStyle(color: Colors.white),
                                  controller: contentController,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color(0xff2A3044)),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    hintText: 'Libovolný text',
                                    hintStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    fillColor: const Color(0xff2A3044),
                                    filled: true,
                                  ),
                                ),
                              )),
                          Container(
                              width: 200,
                              child: DropdownButton<String>(
                                hint: Text(
                                  s!,
                                  style:
                                      TextStyle(color: const Color(0xffC83838)),
                                ),
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_downward),
                                value: contvalue,
                                elevation: 16,
                                style: const TextStyle(
                                    color: const Color(0xffC83838)),
                                underline: Container(
                                  height: 2,
                                  color: const Color(0xffC83838),
                                ),
                                onChanged: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    contvalue = value!;
                                  });
                                },
                                items: list.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              )),
                          certcontrol(),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () {
                                updatePostDetails();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen()));
                              },
                              style: ElevatedButton.styleFrom(
                                shape: StadiumBorder(),
                                backgroundColor: const Color(0xffC83838),
                              ),
                              child: Text("Upravit post"),
                            ),
                          )
                        ],
                      ))),
            ));
    ;
  }
}
