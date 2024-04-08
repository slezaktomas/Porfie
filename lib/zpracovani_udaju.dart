import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'registration_screen.dart';
import 'login_screen.dart';

class ZpracovaniUdaju extends StatefulWidget {
  const ZpracovaniUdaju({Key? key}) : super(key: key);

  @override
  State<ZpracovaniUdaju> createState() => _ZpracovaniUdajuState();
}

class _ZpracovaniUdajuState extends State<ZpracovaniUdaju> {
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: const Color(0xff171A25),
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
              child: Container(
            padding: EdgeInsets.all(30),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 35),
              Text(
                  'Udělujete tímto souhlas Střední škole technické a ekonomické Brno, Olomoucké (dále jen „Správce“), aby ve smyslu nařízení Evropského parlamentu a Rady (EU) č. 2016/679 o ochraně fyzických osob v souvislosti se zpracováním osobních údajů a o volném pohybu těchto údajů a o zrušení směrnice 95/46/ES (obecné nařízení o ochraně osobních údajů) (dále jen „Nařízení“) zpracovávala data, která si budete na této stránce vyplňovat.'
                  '\n'
                  '\n'
                  'S výše uvedeným zpracováním udělujete svůj výslovný souhlas. Poskytnutím osobních údajů je dobrovolné. Souhlas lze vzít kdykoliv zpět, a to například zasláním emailu.'
                  '\n'
                  '\n'
                  'Údaje jsou ukládany do databáze Google Firebase'
                  '\n'
                  '\n'
                  "Vezměte, prosíme, na vědomí, že podle Nařízení máte právo: \n - vzít souhlas kdykoliv zpět \n - požadovat po nás informaci, jaké vaše osobní údaje zpracováváme, žádat si kopii těchto údajů \n - vyžádat si u nás přístup k těmto údajům a tyto nechat aktualizovat nebo opravit, popřípadě požadovat omezení zpracování \n - požadovat po nás výmaz těchto osobních údajů \n - na přenositelnost údajů \n - podat stížnost u Úřadu pro ochranu osobních údajů nebo se obrátit na soud.",
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ]),
          )),
        ));
  }
}
