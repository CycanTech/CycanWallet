import 'package:flutter/cupertino.dart';

import '../public.dart';

showMHAlertView({
  BuildContext context,
  String title,
  TextStyle titleStyle = const TextStyle(
    color: Color(0xFF161D2D),
    fontSize: 20,
    fontWeight: FontWightHelper.semiBold,
  ),
  String content,
  TextStyle contentStyle = const TextStyle(
    color: Color(0xFF000000),
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
            style: titleStyle,
          ),
          content: Column(
            children: [
              OffsetWidget.vGap(30),
              Text(
                "memo_create_tip".local(),
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: OffsetWidget.setSp(16),
                  fontWeight: FontWightHelper.regular,
                ),
              ),
              OffsetWidget.vGap(13),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                "dialog_cancel".local(),
                style: TextStyle(
                  color: Color(0xFFACBBCF),
                  fontSize: OffsetWidget.setSp(14),
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
                    fontSize: OffsetWidget.setSp(14),
                    fontWeight: FontWightHelper.medium,
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
    color: Color(0xFF000000),
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
            style: titleStyle,
          ),
          content: Column(
            children: [
              OffsetWidget.vGap(30),
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
              OffsetWidget.vGap(13),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                "dialog_cancel".local(),
                style: TextStyle(
                  color: Color(0xFFACBBCF),
                  fontSize: OffsetWidget.setSp(14),
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
                    fontSize: OffsetWidget.setSp(14),
                    fontWeight: FontWightHelper.medium,
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
