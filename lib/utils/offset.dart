import 'package:flutter_coinid/utils/screenutil.dart';

import '../public.dart';
import 'package:flutter/material.dart';

/// 间隔
class OffsetWidget {
  static const Widget line = Divider();

  static const Widget empty = SizedBox.shrink();

  static Widget vLine(double dimens) {
    return SizedBox(
      height: dimens,
      child: VerticalDivider(),
    );
  }

  static Widget vLineWhitColor(double h, Color color) {
    return Container(
      height: h,
      color: color,
    );
  }

  static Widget hLineWhitColor(double w, Color color) {
    return Container(
      width: w,
      color: color,
    );
  }

  ///垂直间隔
  static Widget vGap(double dimens) {
    return SizedBox(height: setSc(dimens));
  }

  ///水平间隔
  static Widget hGap(double dimens) {
    return SizedBox(width: setSc(dimens));
  }

  //界面基准初始化
  static void screenInit(BuildContext context, double width) {
    ScreenUtil.init(context, width: 360, allowFontScaling: true);
  }
  /// 高度。宽度适配
  static num setSc(double value) {
    return ScreenUtil().setSc(value);
  }

  ///适配后UI字体数值
  static num setSp(double fontSize) {
    return ScreenUtil().setSp(fontSize);
  }
}
