import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text("O porfie"),
          centerTitle: true,
          backgroundColor: const Color(0xff171A25),
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
              child: Container(
            padding: EdgeInsets.all(30),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SvgPicture.asset(
                'assets/images/us.svg',
                height: deviceHeight * 0.25,
              ),
              const SizedBox(height: 35),
              Text(
                  'Porfie je projekt vytvořený studenty ze SŠTE Brno (Olomoucké).'
                  '\n'
                  '\n'
                  'Porfie spočívá ve sledování sebe a svého postupu. Pomůže Vám se retrospektivně podívat na svůj dovednostní nebo i osobní rozvoj. Zároveň si zde můžete ukládat všechny svoje certifikáty a taky svůj životopis.'
                  '\n'
                  '\n'
                  'Aplikace je intuitivní a svým ovládáním připomíná sociální síť, jelikož si svůj rozvoj ukládáte ve formě příspěvků, ve kterých se můžete rozepsat a popřípadě i přidat fotku.',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              TextButton(
                  onPressed: (() {
                    showDialog(
                        context: context,
                        builder: ((context) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              dialogTheme: DialogTheme(
                                  backgroundColor: Colors.white,
                                  contentTextStyle:
                                      TextStyle(color: Colors.white),
                                  titleTextStyle:
                                      TextStyle(color: Colors.white)),
                            ),
                            child: AboutDialog(
                              applicationName: "Porfie",
                              applicationVersion: "1.0",
                            ),
                          );
                        }));
                  }),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xffC83838),
                  ),
                  child: Text(
                    "All licenses",
                  ))
            ]),
          )),
        ));
  }
}
