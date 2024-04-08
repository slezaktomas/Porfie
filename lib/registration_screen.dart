import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import "zpracovani_udaju.dart";

class RegistrationScreen extends StatefulWidget {
  final VoidCallback showLoginScreen;
  const RegistrationScreen({Key? key, required this.showLoginScreen})
      : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  late String uid;

  Future addUserDetails() async {
    User user = auth.currentUser!;
    uid = user.uid;
    DateTime? creationTime = user.metadata.creationTime;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': user.email,
      'firstname': "",
      'img': false,
      'lastname': "",
      'registration': creationTime,
      'about': "",
      'uid': user.uid,
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
  }

  Future signUp() async {
    if (passwordConfirmed()) {
      try {
        showDialog(
            context: context,
            builder: (context) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xffC83838),
                ),
              );
            });
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        addUserDetails();
        Navigator.of(context).pop();
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Container(
                padding: const EdgeInsets.all(16),
                height: 90,
                decoration: const BoxDecoration(
                    color: Color(0xffC83838),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Jejda!", style: TextStyle(fontSize: 22)),
                      const Text("Někde nastala chyba :(",
                          style: const TextStyle(fontSize: 16)),
                    ]))));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
              padding: const EdgeInsets.all(16),
              height: 90,
              decoration: const BoxDecoration(
                  color: Color(0xffC83838),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Jejda!", style: TextStyle(fontSize: 22)),
                    const Text("Hesla se neshodují",
                        style: const TextStyle(fontSize: 16)),
                  ]))));
    }
  }

  bool passwordConfirmed() {
    if (passwordController.text.trim() ==
        confirmpasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: SafeArea(
              child: Center(
                  child: SingleChildScrollView(
                      child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //image
              SvgPicture.asset(
                'assets/images/logo.svg',
                height: deviceHeight * 0.15,
              ),
              const SizedBox(height: 15),

              //text
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 30, top: 30),
                child: const Text(
                  'Zaregistrujte se',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              //email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: emailController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xff2A3044)),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Colors.white),
                    fillColor: const Color(0xff2A3044),
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),

              //password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xff2A3044)),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    hintText: 'Heslo (minimálně 6 znaků)',
                    hintStyle: const TextStyle(color: Colors.white),
                    fillColor: const Color(0xff2A3044),
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),

              // confirm password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: confirmpasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xff2A3044)),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    hintText: 'Potvrďte Heslo',
                    hintStyle: const TextStyle(
                      color: Colors.white,
                    ),
                    fillColor: const Color(0xff2A3044),
                    filled: true,
                  ),
                ),
              ),

              //button
              Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 30.0,
                  ),
                  child: GestureDetector(
                    onTap: signUp,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xffC83838),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: const Center(
                        child: Text(
                          'Zaregistrovat se',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  )),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text(
                  'Už u nás máte účet?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16),
                ),
                GestureDetector(
                  onTap: widget.showLoginScreen,
                  child: const Text(
                    ' Přihlašte se',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xffC83838),
                        fontSize: 16),
                  ),
                ),
              ]),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text(
                    'Registrací souhlasíte se',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  GestureDetector(
                    onTap: (() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ZpracovaniUdaju()));
                    }),
                    child: const Text(
                      ' zpracováním osobních údajů',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ]),
              )
            ],
          )))),
        ));
  }
}
