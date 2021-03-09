import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coinid/public.dart';
import 'package:flutter_coinid/utils/screenutil.dart';

//封装视图view
// ignore: must_be_immutable
class CustomPageView extends StatelessWidget {
  CustomPageView({
    Key key,
    @required this.child,
    this.title,
    this.hiddenScrollView,
    this.bottom,
    this.hiddenAppBar,
    this.hiddenLeading,
    this.bottomNavigationBar,
    this.leadBack,
    this.actions,
    this.leading,
    this.hiddenResizeToAvoidBottomInset = true,
    this.elevation = 0,
    this.backgroundColor = const Color(Constant.main_color),
  }) : super(key: key);

  Widget child;
  Widget title;
  final PreferredSizeWidget bottom;
  final bool hiddenAppBar;
  final bool hiddenScrollView;
  final bool hiddenLeading;
  final bool hiddenResizeToAvoidBottomInset; //是否弹出软键盘压缩界面
  final Widget bottomNavigationBar;
  final VoidCallback leadBack;
  final List<Widget> actions;
  final Widget leading;
  final double elevation;
  final Color backgroundColor;

  static Widget getDefaultTitle({String titleStr = ""}) {
    return Text(
      titleStr,
      style: TextStyle(
          color: Color(0xFF171F24),
          fontWeight: FontWightHelper.medium,
          fontSize: OffsetWidget.setSp(18)),
    );
  }

  static Widget getIconSmallTitle(
      {String smallIconPath = "",
      String bigTitle = "",
      String smallTitle = ""}) {
    return Container(
      alignment: Alignment.center,
      width: OffsetWidget.setSc(200),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LoadAssetsImage(
            smallIconPath,
            width: OffsetWidget.setSc(26),
            height: OffsetWidget.setSc(26),
          ),
          OffsetWidget.hGap(5),
          Column(
            children: [
              Text(
                bigTitle,
                style: TextStyle(
                    color: Color(0xFF171F24),
                    fontWeight: FontWightHelper.semiBold,
                    fontSize: OffsetWidget.setSp(18)),
              ),
              Text(
                smallTitle,
                style: TextStyle(
                    color: Color(0xFFACBBCF),
                    fontWeight: FontWightHelper.medium,
                    fontSize: OffsetWidget.setSp(10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    //全局拦截键盘处理
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          resizeToAvoidBottomInset: hiddenResizeToAvoidBottomInset,
          appBar: hiddenAppBar == true
              ? null
              : AppBar(
                  title: title,
                  centerTitle: true,
                  elevation: elevation,
                  bottom: bottom,
                  backgroundColor: Colors.white,
                  brightness: Brightness.dark,
                  actions: actions,
                  leading: hiddenLeading == true
                      ? (leading != null ? leading : Text(""))
                      : Routers.canGoPop(context) == true
                          ? GestureDetector(
                              onTap: () => {
                                if (leadBack != null)
                                  {
                                    leadBack(),
                                  }
                                else
                                  {
                                    Routers.goBackWithParams(context, null),
                                  }
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
                          : Text("")),
          backgroundColor: backgroundColor,
          bottomNavigationBar: this.bottomNavigationBar,
          body: SafeArea(
            child: hiddenScrollView == true
                ? child
                : SingleChildScrollView(
                    child: child,
                  ),
          ),
        ),
      ),
    );
  }
}
