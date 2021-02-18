import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_coinid/utils/permission.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';

import '../public.dart';

class PDFScreen extends StatefulWidget {
  PDFScreen({Key key, this.pathPDF}) : super(key: key);
  final String pathPDF;

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  String pathPDF;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPath();
  }

  initPath() {
    pathPDF = widget.pathPDF;
  }

  @override
  Widget build(BuildContext context) {
    return pathPDF == null
        ? Container(
            child: null,
          )
        : PDFViewerScaffold(
            path: pathPDF,
            appBar: AppBar(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.white,
                leading: Routers.canGoPop(context) == true
                    ? GestureDetector(
                        onTap: () => {
                          Routers.goBackWithParams(context, null),
                        },
                        child: Center(
                          child: Image.asset(
                            Constant.ASSETS_IMG + "icon/icon_goback.png",
                            scale: 2,
                            width: 45,
                            height: 45,
                          ),
                        ),
                      )
                    : Text("")));
  }
}
