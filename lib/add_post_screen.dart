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
import 'package:porfie/LoadingWidget.dart';
import 'package:porfie/home_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  void initState() {
    super.initState();
    certcontrol();
    wait();
  }

  final headerController = TextEditingController();
  final contentController = TextEditingController();
  late var imageurl = null;
  final FirebaseAuth auth = FirebaseAuth.instance;
  var name;
  File? _photo;
  final ImagePicker _picker = ImagePicker();
  File? _file;

  Future uploadFile() async {
    if (imageurl != null) {
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

  Future wait() async {
    Future.delayed(Duration(milliseconds: 500), () {
      //Delay here
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future uploadDocument() async {
    if (imageurl != null) {
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

  bool _isLoading = true;
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

  Widget certcontrol() {
    if (dropdownValue == "Certifikát") {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: ElevatedButton(
          onPressed: () {
            doc();
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffC83838), shape: StadiumBorder()),
          child: Text((() {
            if (imageurl != null) {
              return "PDF přidáno";
            }

            return "Kliknutím Přidáte PDF";
          })()),
        ),
      );
    } else {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
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
        ],
      );
    }
  }

  late String uid;
  String val = "";
  Future addPostDetails() async {
    User user = auth.currentUser!;
    uid = user.uid;
    String format2 = DateFormat('yyyy-MM-dd ').format(DateTime.now());
    String format =
        DateFormat('EEE MMM dd yyyy HH:mm:ss ').format(DateTime.now()) +
            "GMT+0100 (Středoevropský standardní čas)";
    switch (dropdownValue) {
      case "Osobní rozvoj":
        val = "personal";
        break;
      case "Dovednost":
        val = "skill";
        break;
      case "Certifikát":
        val = "certificate";
        break;
      case "Projekt":
        val = "project";
        break;
      case "Volnočasová aktivita":
        val = "hobbies";
        break;
      case "Pracovní zkušenosti":
        val = "experience";
        break;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("posts")
        .doc(format)
        .set(({
          'header': headerController.text.trim(),
          'content': contentController.text.trim(),
          'type': val,
          'file': name,
          'date': format2,
          'fileUrl': imageurl,
        }));
  }

  late bool Control;
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final devicewidth = MediaQuery.of(context).size.width;
    return _isLoading
        ? LoadingWidget()
        : GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                floatingActionButton: FloatingActionButton(
                  elevation: 10.0,
                  backgroundColor: const Color(0xffC83838),
                  child: const Icon(Icons.upload),
                  onPressed: () {
                    addPostDetails();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()));
                  },
                ),
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color(0xff171A25),
                  elevation: 0,
                  title: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()));
                      }),
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
                                  borderSide: const BorderSide(
                                      color: Color(0xff2A3044)),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                hintText: 'Nadpis',
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
                                        borderSide: const BorderSide(
                                            color: Colors.white),
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
                            DropdownButtonExe(),
                            certcontrol(),
                          ],
                        )))));
  }
}

String dropdownValue = list.first;
const List<String> list = <String>[
  'Osobní rozvoj',
  'Dovednost',
  'Certifikát',
  'Projekt',
  'Volnočasová aktivita',
  'Pracovní zkušenost',
];

class DropdownButtonExe extends StatefulWidget {
  const DropdownButtonExe({super.key});

  @override
  State<DropdownButtonExe> createState() => _DropdownButtonExeState();
}

class _DropdownButtonExeState extends State<DropdownButtonExe> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 200,
        child: DropdownButton<String>(
          hint: Text(
            "Vyber typ",
            style: TextStyle(color: const Color(0xffC83838)),
          ),
          isExpanded: true,
          icon: const Icon(Icons.arrow_downward),
          value: dropdownValue,
          elevation: 16,
          style: const TextStyle(color: const Color(0xffC83838)),
          underline: Container(
            height: 2,
            color: const Color(0xffC83838),
          ),
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              dropdownValue = value!;
            });
          },
          items: list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ));
  }
}