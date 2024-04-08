import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'registration_screen.dart';
import 'login_screen.dart';
import 'dart:async';
import 'dart:io';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'LoadingWidget.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

class Pdfviewer extends StatefulWidget {
  const Pdfviewer({Key? key, required this.s}) : super(key: key);
  final String s;
  @override
  State<Pdfviewer> createState() => _PdfviewerState();
}

class _PdfviewerState extends State<Pdfviewer> {
  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  String? pdfFlePath;

  Future<String> downloadAndSavePdf() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/sample.pdf');
    if (await file.exists()) {
      file.delete();
    }
    final response = await http.get(Uri.parse(widget.s));
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  void loadPdf() async {
    pdfFlePath = await downloadAndSavePdf();
    setState(() {
      _load = false;
    });
  }

  var date1 = DateTime.now().millisecondsSinceEpoch.toString() + ".pdf";
  Future download2(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(url,

          //Received data with List<int>
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
          ));
      print(response.headers);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

  bool _load = true;
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return _load
        ? LoadingWidget()
        : Scaffold(
            appBar: AppBar(
              title: Text("Pdf viewer"),
              centerTitle: true,
              backgroundColor: const Color(0xff171A25),
              actions: [
                IconButton(
                    onPressed: (() async {
                      if (Platform.isIOS) {
                        var dir = await getApplicationDocumentsDirectory();
                        String p = dir!.path + "/lol.pdf";
                        download2(Dio(), widget.s, p);
                      }
                      if (Platform.isAndroid) {
                        var status = await Permission.storage.status;
                        if (status != PermissionStatus.granted) {
                          status = await Permission.storage.request();
                        }
                        if (status.isGranted) {
                          const downloadsFolderPath =
                              '/storage/emulated/0/Download/';
                          Directory dir = Directory(downloadsFolderPath);
                          String p = dir!.path + date1;
                          download2(Dio(), widget.s, p);
                        }
                      }
                    }),
                    icon: Icon(Icons.download))
              ],
            ),
            body: Container(
              child: PdfView(path: pdfFlePath!),
            ));
  }
}
