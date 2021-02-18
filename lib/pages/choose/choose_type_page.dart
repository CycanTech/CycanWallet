import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/utils/ver_upgrade_util.dart';
import '../../public.dart';

class ChooseTypePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ChooseTypePageState();
  }
}

class ChooseTypePageState extends State<ChooseTypePage> {
  bool isOff = true;
  int exitTime = 0;
  bool visibleAppWallet = true;
  Future<Null> _getTestMeod() async {}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //版本检测
    initData();
    VerSionUpgradeUtil.getAppInfo(context);
  }

  initData() async {
    List creates =
        await MHWallet.findWalletsByType(MOriginType.MOriginType_Create.index);
    List restores =
        await MHWallet.findWalletsByType(MOriginType.MOriginType_Restore.index);
    setState(() {
      visibleAppWallet = (creates.length + restores.length) > 0 ? false : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return WillPopScope(
      child: CustomPageView(
        title: Text("my_wallet".local(),
            style: TextStyle(
                fontSize: OffsetWidget.setSp(18),
                fontWeight: FontWeight.w400,
                color: Color(0xFFFFFFFF))),
        hiddenScrollView: false,
        hiddenLeading: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Visibility(
              visible: visibleAppWallet,
              child: GestureDetector(
                child: Container(
                  height: 54,
                  margin: EdgeInsets.fromLTRB(
                      OffsetWidget.setSc(40),
                      OffsetWidget.setSc(40),
                      OffsetWidget.setSc(40),
                      OffsetWidget.setSc(10)),
                  padding: EdgeInsets.only(left: OffsetWidget.setSc(73)),
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: new AssetImage(
                        Constant.ASSETS_IMG + "background/create_app.png",
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        Constant.ASSETS_IMG + "icon/wallet_app.png",
                        fit: BoxFit.cover,
                        scale: 2,
                        width: OffsetWidget.setSc(30),
                        height: OffsetWidget.setSc(30),
                      ),
                      OffsetWidget.hGap(12),
                      Text(
                        "create_hote".local(),
                        style: TextStyle(
                          fontSize: OffsetWidget.setSp(12),
                          color: Color(0xff586883),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Routers.push(context, Routers.chooseCreateTypePage);
                },
              ),
            ),
            GestureDetector(
              child: Container(
                height: 54,
                margin: EdgeInsets.fromLTRB(
                    OffsetWidget.setSc(40),
                    OffsetWidget.setSc(0),
                    OffsetWidget.setSc(40),
                    OffsetWidget.setSc(10)),
                padding: EdgeInsets.only(left: OffsetWidget.setSc(73)),
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: new AssetImage(
                      Constant.ASSETS_IMG + "background/create_import.png",
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      Constant.ASSETS_IMG + "icon/wallet_import.png",
                      fit: BoxFit.cover,
                      scale: 2,
                      width: OffsetWidget.setSc(30),
                      height: OffsetWidget.setSc(30),
                    ),
                    OffsetWidget.hGap(12),
                    Text(
                      "import_hote".local(),
                      style: TextStyle(
                        fontSize: OffsetWidget.setSp(12),
                        color: Color(0xff586883),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Routers.push(context, Routers.chooseCoinTypePage);
              },
            ),
            Visibility(
              visible: false,
              child: GestureDetector(
                child: Container(
                  height: 54,
                  margin: EdgeInsets.fromLTRB(
                      OffsetWidget.setSc(40),
                      OffsetWidget.setSc(0),
                      OffsetWidget.setSc(40),
                      OffsetWidget.setSc(10)),
                  padding: EdgeInsets.only(left: OffsetWidget.setSc(73)),
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: new AssetImage(
                        Constant.ASSETS_IMG + "background/create_bluetooth.png",
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        Constant.ASSETS_IMG + "icon/wallet_bluetooth.png",
                        fit: BoxFit.cover,
                        scale: 2,
                        width: OffsetWidget.setSc(30),
                        height: OffsetWidget.setSc(30),
                      ),
                      OffsetWidget.hGap(12),
                      Text(
                        "create_code".local(),
                        style: TextStyle(
                          fontSize: OffsetWidget.setSp(12),
                          color: Color(0xff586883),
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () {},
              ),
            ),
            Visibility(
              visible: false,
              child: GestureDetector(
                child: Container(
                  height: 54,
                  margin: EdgeInsets.fromLTRB(
                      OffsetWidget.setSc(40),
                      OffsetWidget.setSc(0),
                      OffsetWidget.setSc(40),
                      OffsetWidget.setSc(10)),
                  padding: EdgeInsets.only(left: OffsetWidget.setSc(73)),
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: new AssetImage(
                        Constant.ASSETS_IMG + "background/create_nfcicon.png",
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        Constant.ASSETS_IMG + "icon/wallet_nfc.png",
                        fit: BoxFit.cover,
                        scale: 2,
                        width: OffsetWidget.setSc(30),
                        height: OffsetWidget.setSc(30),
                      ),
                      OffsetWidget.hGap(12),
                      Text(
                        "create_nfc".local(),
                        style: TextStyle(
                          fontSize: OffsetWidget.setSp(12),
                          color: Color(0xff586883),
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () {
                  _getTestMeod();
                },
              ),
            ),
            Visibility(
              visible: false,
              child: GestureDetector(
                child: Container(
                  height: 54,
                  margin: EdgeInsets.fromLTRB(
                      OffsetWidget.setSc(40),
                      OffsetWidget.setSc(0),
                      OffsetWidget.setSc(40),
                      OffsetWidget.setSc(10)),
                  padding: EdgeInsets.only(left: OffsetWidget.setSc(73)),
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: new AssetImage(
                        Constant.ASSETS_IMG + "background/create_mws.png",
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        Constant.ASSETS_IMG + "icon/wallet_msw.png",
                        fit: BoxFit.cover,
                        scale: 2,
                        width: OffsetWidget.setSc(30),
                        height: OffsetWidget.setSc(30),
                      ),
                      OffsetWidget.hGap(12),
                      Text(
                        "多重签名钱包",
                        style: TextStyle(
                          fontSize: OffsetWidget.setSp(12),
                          color: Color(0xff586883),
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
      onWillPop: () {
        //0x1AFFFFFF
        if (DateUtil.getNowDateMs() - exitTime > 2000) {
          HWToast.showText(text: 'exit_hint'.local());
          exitTime = DateUtil.getNowDateMs();
        } else {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
    );
  }
}
