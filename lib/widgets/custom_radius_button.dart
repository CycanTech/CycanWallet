
import 'package:flutter/material.dart';
import 'package:flutter_coinid/utils/offset.dart';

class CustomRadiusButton extends StatelessWidget {
  CustomRadiusButton(
      {Key key,
      this.paddingLeft = 0,
      this.paddingTop = 0,
      this.paddingRight = 0,
      this.paddingBottom = 0,
      this.marginLeft = 0,
      this.marginTop = 0,
      this.marginRight = 0,
      this.marginBottom = 0,
      this.width = 0,
      this.height = 0,
      this.topLeftBorderRadius = 0,
      this.topRightBorderRadius = 0,
      this.bottomLeftBorderRadius = 0,
      this.bottomRightBorderRadius = 0,
      this.background,
      this.textStr,
      this.textColor,
      this.fontSize = 0,
      this.onTap})
      : super(key: key);

  double paddingLeft;
  double paddingTop;
  double paddingRight;
  double paddingBottom;

  double marginLeft;
  double marginTop;
  double marginRight;
  double marginBottom;

  double width;
  double height;

  double topLeftBorderRadius;
  double topRightBorderRadius;
  double bottomLeftBorderRadius;
  double bottomRightBorderRadius;

  Color background;

  String textStr;

  Color textColor;

  double fontSize;

  @required
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topLeftBorderRadius),
          topRight: Radius.circular(topRightBorderRadius),
          bottomLeft: Radius.circular(bottomLeftBorderRadius),
          bottomRight: Radius.circular(bottomRightBorderRadius)),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.only(
              left: OffsetWidget.setSc(paddingLeft),
              top: OffsetWidget.setSc(paddingTop),
              right: OffsetWidget.setSc(paddingRight),
              bottom: OffsetWidget.setSc(paddingBottom)),
          margin: EdgeInsets.fromLTRB(
              OffsetWidget.setSc(marginLeft),
              OffsetWidget.setSc(marginTop),
              OffsetWidget.setSc(marginRight),
              OffsetWidget.setSc(marginBottom)),
          color: background,
          width: OffsetWidget.setSc(width),
          height: OffsetWidget.setSc(height),
          child: Center(
            child: Text(
              textStr,
              style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: OffsetWidget.setSp(fontSize),
                  color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
