import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../public.dart';

showMHAlertView({
  BuildContext context,
  String title,
  String content,
  TextStyle contentStyle = const TextStyle(
    color: Color(0xFF161D2D),
    fontSize: 16,
    fontWeight: FontWightHelper.regular,
  ),
  VoidCallback cancelPressed,
  VoidCallback confirmPressed,
}) {
  showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: Color(0xFF161D2D),
              fontSize: OffsetWidget.setSp(20),
              fontWeight: FontWightHelper.semiBold,
              fontFamily: Platform.isAndroid ? "SourceHanSans" : null,
            ),
          ),
          content: Column(
            children: [
              SizedBox(
                height: 27,
              ),
              Text(
                "memo_create_tip".local(),
                style: contentStyle,
              ),
              SizedBox(
                height: 21,
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                "dialog_cancel".local(),
                style: TextStyle(
                  color: Color(0xFFACBBCF),
                  fontSize: OffsetWidget.setSp(20),
                  fontWeight: FontWightHelper.regular,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                if (cancelPressed != null) {
                  cancelPressed();
                }
              },
            ),
            CupertinoDialogAction(
                child: Text(
                  "dialog_confirm".local(),
                  style: TextStyle(
                    color: Color(0xFF586883),
                    fontSize: OffsetWidget.setSp(18),
                    fontWeight: FontWightHelper.semiBold,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (confirmPressed != null) {
                    confirmPressed();
                  }
                }),
          ],
        );
      });
}

showMHInputAlertView({
  BuildContext context,
  String title,
  TextStyle titleStyle = const TextStyle(
    color: Color(0xFF161D2D),
    fontSize: 20,
    fontWeight: FontWightHelper.semiBold,
  ),
  String placeholder = "",
  String placeValue = "",
  String content,
  bool obscureText = true,
  TextStyle contentStyle = const TextStyle(
    color: Color(0xFF161D2D),
    fontSize: 16,
    fontWeight: FontWightHelper.regular,
  ),
  VoidCallback cancelPressed,
  Function(String value) confirmPressed,
}) {
  TextEditingController controller = TextEditingController(text: placeValue);
  showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: Color(0xFF161D2D),
              fontSize: OffsetWidget.setSp(20),
              fontWeight: FontWightHelper.semiBold,
              fontFamily: Platform.isAndroid ? "SourceHanSans" : null,
            ),
          ),
          content: Column(
            children: [
              SizedBox(
                height: 27,
              ),
              CupertinoTextField(
                maxLines: 1,
                controller: controller,
                obscureText: obscureText,
                autofocus: true,
                placeholder: placeholder,
                padding:
                    EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                placeholderStyle: TextStyle(
                  color: Color(0xFFACBBCF),
                  fontSize: 16,
                  fontWeight: FontWightHelper.regular,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFF6F8F9),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Color(0xFFEFF3F5), width: 1),
                ),
              ),
              SizedBox(
                height: 21,
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                "dialog_cancel".local(),
                style: TextStyle(
                  color: Color(0xFFACBBCF),
                  fontSize: OffsetWidget.setSp(20),
                  fontWeight: FontWightHelper.regular,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                if (cancelPressed != null) {
                  cancelPressed();
                }
              },
            ),
            CupertinoDialogAction(
                child: Text(
                  "dialog_confirm".local(),
                  style: TextStyle(
                    color: Color(0xFF586883),
                    fontSize: OffsetWidget.setSp(18),
                    fontWeight: FontWightHelper.semiBold,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (confirmPressed != null) {
                    confirmPressed(controller.text);
                  }
                }),
          ],
        );
      });
}
