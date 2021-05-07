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
    OffsetWidget.screenInit(context, 360);
    return WillPopScope(
      child: CustomPageView(
        hiddenScrollView: true,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              LoadAssetsImage(
                Constant.ASSETS_IMG + "background/bg_createwallet.png",
                // width: OffsetWidget.setSc(70),
                // width: OffsetWidget.setSc(290),
                height: OffsetWidget.setSc(250),
                fit: BoxFit.contain,
              ),
              Container(
                padding: EdgeInsets.only(
                    top: OffsetWidget.setSc(42), left: 10, right: 10),
                child: Text(
                  "choose_wallettip".local(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4F7BF2),
                    fontSize: OffsetWidget.setSp(24),
                    fontFamily: "LantingSimplified",
                    fontWeight: FontWightHelper.semiBold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                    top: OffsetWidget.setSc(16), left: 10, right: 10),
                child: Text(
                  "choose_wallettip2".local(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF101010),
                    fontSize: OffsetWidget.setSp(14),
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
                          fontSize: OffsetWidget.setSp(15),
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
                      OffsetWidget.setSc(117)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "choose_existwallet".local() + "，",
                        style: TextStyle(
                            fontSize: OffsetWidget.setSp(15),
                            color: Color(0xFF101010),
                            fontWeight: FontWightHelper.regular),
                      ),
                      Text(
                        "import_hote".local(),
                        style: TextStyle(
                            fontSize: OffsetWidget.setSp(15),
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
            ],
          ),
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
