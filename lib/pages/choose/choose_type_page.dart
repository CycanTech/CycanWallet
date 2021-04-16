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
    // VerSionUpgradeUtil.getAppInfo(context);
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
    return WillPopScope(
      child: CustomPageView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            LoadAssetsImage(
              Constant.ASSETS_IMG + "background/bg_createwallet.png",
              // width: OffsetWidget.setSc(70),
              height: OffsetWidget.setSc(310),
              fit: BoxFit.contain,
            ),
            Container(
              padding: EdgeInsets.only(
                  top: OffsetWidget.setSc(42), left: 10, right: 10),
              child: Text(
                "choose_wallettip".local(),
                style: TextStyle(
                  color: Color(0xFF4F7BF2),
                  fontSize: OffsetWidget.setSp(24),
                  fontWeight: FontWightHelper.semiBold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  top: OffsetWidget.setSc(13), left: 10, right: 10),
              child: Text(
                "choose_wallettip2".local(),
                style: TextStyle(
                  color: Color(0xFF101010),
                  fontSize: OffsetWidget.setSp(18),
                  fontWeight: FontWightHelper.regular,
                ),
              ),
            ),
            Visibility(
              visible: visibleAppWallet,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFF586883),
                  ),
                  height: OffsetWidget.setSc(40),
                  margin: EdgeInsets.fromLTRB(OffsetWidget.setSc(42),
                      OffsetWidget.setSc(42), OffsetWidget.setSc(42), 0),
                  child: Text(
                    "create_hote".local(),
                    style: TextStyle(
                        fontSize: OffsetWidget.setSp(18),
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWightHelper.regular),
                  ),
                ),
                onTap: () {
                  Routers.push(context, Routers.createPage);
                },
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: EdgeInsets.fromLTRB(
                    OffsetWidget.setSc(40),
                    OffsetWidget.setSc(20),
                    OffsetWidget.setSc(40),
                    OffsetWidget.setSc(0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "choose_existwallet".local() + "，",
                      style: TextStyle(
                          fontSize: OffsetWidget.setSp(16),
                          color: Color(0xFF101010),
                          fontWeight: FontWightHelper.regular),
                    ),
                    Text(
                      "import_hote".local(),
                      style: TextStyle(
                          fontSize: OffsetWidget.setSp(16),
                          color: Color(0xFF4F7BF2),
                          fontWeight: FontWightHelper.regular),
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
