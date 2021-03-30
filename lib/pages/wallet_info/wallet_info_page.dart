import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coinid/channel/channel_native.dart';
import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/states/provider_setup.dart';
import 'package:flutter_coinid/utils/instruction_data_format.dart';
import 'package:provider/provider.dart';

import '../../public.dart';

class WalletInfoPage extends StatefulWidget {
  WalletInfoPage({
    Key key,
    this.params,
  }) : super(key: key);
  Map params = Map();
  @override
  _WalletInfoPageState createState() => _WalletInfoPageState();
}

class _WalletInfoPageState extends State<WalletInfoPage> {
  @override
  void initState() {
    super.initState();
  }

  void _modifyDescName() {
    MHWallet mwallet =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet;
    Map<String, dynamic> params = HashMap();
    params["walletID"] = mwallet.walletID;
    Routers.push(
      context,
      Routers.walletUpdateNamePage,
      params: params,
    );
  }

  void _exportWalletPrv() {
    MHWallet mwallet =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet;
    Map<String, dynamic> params = HashMap();
    mwallet.showLockPinDialog(
        context: context,
        tips: "dialog_pwd".local(),
        ok: (value) async {
          String prv = await mwallet.exportPrv(pin: value);
          params["exportType"] = 0;
          params["content"] = prv;
          Routers.push(context, Routers.walletExportPrikeyKeystorePage,
              params: params);
        },
        cancle: null,
        wrong: () => {HWToast.showText(text: "payment_pwdwrong".local())});
  }

  void _exportWalletKeyStore() {
    MHWallet mwallet =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet;
    Map<String, dynamic> params = HashMap();
    mwallet.showLockPinDialog(
        context: context,
        tips: "dialog_pwd".local(),
        ok: (value) async {
          String keyStore = await mwallet.exportKeystore(pin: value);
          params["exportType"] = 1;
          params["content"] = keyStore;
          Routers.push(context, Routers.walletExportPrikeyKeystorePage,
              params: params);
        },
        cancle: null,
        wrong: () => {HWToast.showText(text: "payment_pwdwrong".local())});
  }

  Widget getPageWidget(
      {String leftName,
      String contentValue = "",
      EdgeInsetsGeometry padding,
      EdgeInsetsGeometry margin,
      bool showArrowIcon = false,
      Function() onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: OffsetWidget.setSc(45),
        padding: padding,
        margin: margin,
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFEAEFF2),
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                leftName,
                style: TextStyle(
                  color: Color(0xFF171F24),
                  fontSize: OffsetWidget.setSp(16),
                  fontWeight: FontWightHelper.regular,
                ),
              ),
              Row(
                children: [
                  Text(
                    contentValue,
                    style: TextStyle(
                      color: Color(0xFF171F24),
                      fontSize: OffsetWidget.setSp(12),
                      fontWeight: FontWightHelper.regular,
                    ),
                  ),
                  Visibility(
                    visible: showArrowIcon,
                    child: Container(
                      padding: EdgeInsets.only(left: OffsetWidget.setSc(15)),
                      child: Image.asset(
                        Constant.ASSETS_IMG + "icon/arrow_black_right.png",
                        fit: BoxFit.cover,
                        scale: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MHWallet mwallet =
        Provider.of<CurrentChooseWalletState>(context).currentWallet;
    String descName = mwallet.descName;
    String fullName = mwallet.fullName;
    return CustomPageView(
      // hiddenResizeToAvoidBottomInset: false,
      title: CustomPageView.getDefaultTitle(
        titleStr: "wallet_management".local(),
      ),
      backgroundColor: Color(0xFFEAEFF2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getPageWidget(
            leftName: "wallet_type".local(),
            contentValue: fullName,
            padding: EdgeInsets.only(
              left: OffsetWidget.setSc(20),
              right: OffsetWidget.setSc(20),
            ),
          ),
          getPageWidget(
            leftName: "wallet_name".local(),
            contentValue: descName,
            showArrowIcon: true,
            onTap: () {
              _modifyDescName();
            },
            padding: EdgeInsets.only(
              left: OffsetWidget.setSc(20),
              right: OffsetWidget.setSc(20),
            ),
          ),
          Container(
            constraints: BoxConstraints(
              minHeight: OffsetWidget.setSc(60),
            ),
            margin: null,
            padding: EdgeInsets.only(
              left: OffsetWidget.setSc(20),
              right: OffsetWidget.setSc(20),
            ),
            alignment: Alignment.centerLeft,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "wallet_address".local(),
                  style: TextStyle(
                    color: Color(0xFF171F24),
                    fontSize: OffsetWidget.setSp(16),
                    fontWeight: FontWightHelper.regular,
                  ),
                ),
                OffsetWidget.vGap(5),
                Text(
                  "${mwallet.walletAaddress}",
                  style: TextStyle(
                    color: Color(0xFF9B9B9B),
                    fontSize: OffsetWidget.setSp(10),
                    fontWeight: FontWightHelper.regular,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            margin: EdgeInsets.only(
                top: OffsetWidget.setSc(20), bottom: OffsetWidget.setSc(10)),
            padding: EdgeInsets.only(
              left: OffsetWidget.setSc(20),
              right: OffsetWidget.setSc(20),
            ),
            // padding: EdgeInsets.only(top: OffsetWidget.setSc(20)),
            child: Column(
              children: [
                Container(
                  height: OffsetWidget.setSc(45),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "export_wallet".local(),
                        style: TextStyle(
                          color: Color(0xFF000000),
                          fontSize: OffsetWidget.setSp(16),
                          fontWeight: FontWightHelper.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                OffsetWidget.vLineWhitColor(1, Color(0xFFEAEFF2)),
                getPageWidget(
                    leftName: "export_keystore".local(),
                    showArrowIcon: true,
                    onTap: () => {
                          _exportWalletKeyStore(),
                        }),
                getPageWidget(
                    leftName: "export_prv".local(),
                    showArrowIcon: true,
                    onTap: () => {
                          _exportWalletPrv(),
                        }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
