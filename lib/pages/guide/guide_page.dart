import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_coinid/public.dart';

class GuidePage extends StatefulWidget {
  GuidePage({Key key}) : super(key: key);

  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  int exitTime = 0;
  int currentIndex = 0;
  List<Widget> slides = List();
  @override
  void initState() {
    super.initState();
  }

  List<Widget> buildWidget() {
    slides.clear();
    slides.add(
      Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: OffsetWidget.setSc(166)),
        child: Column(
          children: <Widget>[
            LoadAssetsImage(
              Constant.ASSETS_IMG + "guide/img1.png",
              width: OffsetWidget.setSc(231),
              height: OffsetWidget.setSc(194),
            ),
            OffsetWidget.vGap(50),
            Text(
              "guide_txt_1".local(),
              style: TextStyle(
                  color: Color(0XFFACBBCF), fontSize: OffsetWidget.setSp(14.0)),
            ),
          ],
        ),
      ),
    );
    slides.add(
      Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: OffsetWidget.setSc(166)),
        child: Column(
          children: <Widget>[
            LoadAssetsImage(
              Constant.ASSETS_IMG + "guide/img2.png",
              width: OffsetWidget.setSc(231),
              height: OffsetWidget.setSc(194),
            ),
            OffsetWidget.vGap(50),
            Text(
              "guide_txt_2".local(),
              style: TextStyle(
                  color: Color(0XFFACBBCF), fontSize: OffsetWidget.setSp(14.0)),
            ),
          ],
        ),
      ),
    );
    slides.add(
      Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: OffsetWidget.setSc(166)),
        child: Column(
          children: <Widget>[
            LoadAssetsImage(
              Constant.ASSETS_IMG + "guide/img3.png",
              width: OffsetWidget.setSc(231),
              height: OffsetWidget.setSc(194),
            ),
            OffsetWidget.vGap(50),
            Text(
              "guide_txt_3".local(),
              style: TextStyle(
                  color: Color(0XFFACBBCF), fontSize: OffsetWidget.setSp(14.0)),
            ),
            OffsetWidget.vGap(50),
            GestureDetector(
              onTap: () => {
                onDonePress(),
              },
              child: Container(
                height: OffsetWidget.setSc(38),
                width: OffsetWidget.setSc(92),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF1308FE)),
                    borderRadius: BorderRadius.circular(OffsetWidget.setSc(38)),
                    color: Color(0xffffffff)),
                child: Text(
                  "experience".local(),
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: OffsetWidget.setSp(13),
                      color: Color(0xFF1308FE)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return slides;
  }

  void onDonePress() {
    print("onDonePress");
    updateSkin();
  }

  List<Widget> _buildPoint() {
    List<Widget> pointSlides = List();
    for (var i = 0; i < slides.length; i++) {
      pointSlides.add(Container(
        margin: EdgeInsets.only(left: OffsetWidget.setSc(12)),
        child: LoadAssetsImage(
          i == currentIndex
              ? Constant.ASSETS_IMG + "icon/selecteddot.png"
              : Constant.ASSETS_IMG + "icon/normaldot.png",
          width: OffsetWidget.setSc(7),
          height: OffsetWidget.setSc(7),
        ),
      ));
    }
    return pointSlides;
  }

  void updateSkin() async {
    final fres = await SharedPreferences.getInstance();
    // if (Constant.inProduction == false) {
    fres.setBool("skip", true);
    // }
    Routers.push(context, Routers.chooseTypePage);
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return WillPopScope(
      onWillPop: () {
        //0x1AFFFFFF
        if (DateUtil.getNowDateMs() - exitTime > 2000) {
          HWToast.showText(text: 'exit_hint'.local());
          exitTime = DateUtil.getNowDateMs();
        } else {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
      child: CustomPageView(
        hiddenAppBar: true,
        hiddenScrollView: true,
        child: Stack(
          children: [
            Positioned(
              child: PageView(
                onPageChanged: (value) {
                  print("==index==$value");
                  setState(() {
                    currentIndex = value;
                  });
                },
                children: buildWidget(),
                // pageSnapping: false,
              ),
            ),
            Visibility(
              visible: currentIndex == slides.length - 1 ? false : true,
              child: Positioned(
                child: Container(
                  width: OffsetWidget.setSc(360),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _buildPoint(),
                  ),
                ),
                top: OffsetWidget.setSc(495),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
