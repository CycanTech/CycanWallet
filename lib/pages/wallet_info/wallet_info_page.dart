import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coinid/channel/channel_native.dart';
import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
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
  String walletID;
  MHWallet mwallet;
  @override
  void initState() {
    super.initState();

    _findWalletByWalletID();
  }

  _findWalletByWalletID() async {
    if (widget.params != null) {
      walletID = widget.params["walletID"][0];
      MHWallet wallet = await MHWallet.findWalletByWalletID(walletID);
      if (wallet != null) {
        if (wallet.chainType != MCoinType.MCoinType_BTM.index) {}

        if (wallet.chainType == MCoinType.MCoinType_BTC.index ||
            wallet.chainType == MCoinType.MCoinType_USDT.index) {}

        if (wallet.chainType == MCoinType.MCoinType_EOS.index) {}
        if (wallet.originType != MOriginType.MOriginType_Create.index &&
            wallet.originType != MOriginType.MOriginType_Restore.index) {}

        setState(() {
          mwallet = wallet;
        });
      }
    }
  }

  _cellClickAt(int optionType) {
    WalletObject walletObject;
    Map<String, dynamic> params = HashMap();
    if (MWalletOptionType.MWalletOptionType_Update_Name.index == optionType) {
      if (mwallet != null) {
        Map<String, dynamic> params = HashMap();
        Map<String, dynamic> map;
        params["walletID"] = mwallet.walletID;
        Routers.push(context, Routers.walletUpdateNamePage, params: params)
            .then((value) =>
                {map = value, mwallet.descName = map["name"], setState(() {})});
      }
    } else if (MWalletOptionType.MWalletOptionType_Tips.index == optionType) {
      if (mwallet != null) {
        Map<String, dynamic> params = HashMap();
        params["walletID"] = mwallet.walletID;
        Routers.push(context, Routers.walletUpdateTipsPage, params: params);
      }
    } else if (MWalletOptionType.MWalletOptionType_Export_Prvkey.index ==
        optionType) {
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
    } else if (MWalletOptionType.MWalletOptionType_Export_Keystore.index ==
        optionType) {
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
    // else if (MWalletOptionType.MWalletOptionType_SigData.index ==
    //     optionType) {
    //   String result;
    //   String privKey;
    //   bool flag;
    //   _showDialog(
    //       context,
    //       "dialog_pwd".local(),
    //       () async => {
    //             if (mwallet.pin == InstructionDataFormat.SHA1(pinEC.text))
    //               {
    //                 privKey = await ChannelNative.decByAES128CBC(
    //                     mwallet.prvKey, pinEC.text),
    //                 if (StringUtil.isNotEmpty(privKey))
    //                   {
    //                     result = await ChannelNative.genBTCAddress(
    //                         privKey, !mwallet.isWegwit),
    //                     print(result),
    //                     if (StringUtil.isNotEmpty(result))
    //                       {
    //                         mwallet.walletAaddress = result,
    //                         mwallet.isWegwit = !mwallet.isWegwit,
    //                         flag = await MHWallet.updateWallet(mwallet),
    //                         if (flag) {Navigator.pop(context), setState(() {})}
    //                       }
    //                   }
    //               }
    //             else
    //               {HWToast.showText(text: "payment_pwdwrong".local())}
    //           },
    //       () => null);
    // } else if (MWalletOptionType.MWalletOptionType_Clean.index == optionType) {
    //   bool flag;
    //   List<MHWallet> wallets;
    //   MHWallet wallet;
    //   _showDialog(
    //       context,
    //       "dialog_pwd".local(),
    //       () async => {
    //             if (mwallet.pin == InstructionDataFormat.SHA1(pinEC.text))
    //               {
    //                 Navigator.pop(context),
    //                 flag = await MHWallet.deleteWallet(mwallet),
    //                 if (flag)
    //                   {
    //                     wallet = await MHWallet.findChooseWallet(),
    //                     if (wallet == null)
    //                       {
    //                         wallets = await MHWallet.findAllWallets(),
    //                         if (wallets != null && wallets.length > 0)
    //                           {
    //                             wallet = wallets.first,
    //                             wallet.isChoose = true,
    //                             flag = await MHWallet.updateChoose(wallet),
    //                             if (flag)
    //                               {
    //                                 Routers.goBackWithParams(context, null),
    //                               }
    //                           }
    //                         else
    //                           {
    //                             Routers.push(context, Routers.chooseTypePage,
    //                                 clearStack: true),
    //                           },
    //                       },
    //                   }
    //               }
    //             else
    //               {HWToast.showText(text: "payment_pwdwrong".local())}
    //           },
    //       () => null);
    // } else if (MWalletOptionType.MWalletOptionType_Show_PubKey.index ==
    //     optionType) {
    //   Map<String, dynamic> params = HashMap();
    //   _showDialog(
    //       context,
    //       "dialog_pwd".local(),
    //       () => {
    //             if (mwallet.pin == InstructionDataFormat.SHA1(pinEC.text))
    //               {
    //                 Navigator.pop(context),
    //                 params["active"] = mwallet.subPubKey,
    //                 params["owner"] = mwallet.pubKey,
    //                 Routers.push(context, Routers.walletShowPubKeyPage,
    //                     params: params),
    //               }
    //             else
    //               {HWToast.showText(text: "payment_pwdwrong".local())}
    //           },
    //       () => null);
    // }
  }

  Widget getPageWidget() {
    return Container(
      height: OffsetWidget.setSc(45),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "wallet_name".local(),
            style: TextStyle(
              color: Color(0xFF171F24),
              fontSize: OffsetWidget.setSp(16),
              fontWeight: FontWightHelper.regular,
            ),
          ),
          Row(
            children: [
              Text(
                mwallet.descName,
                style: TextStyle(
                  color: Color(0xFF171F24),
                  fontSize: OffsetWidget.setSp(12),
                  fontWeight: FontWightHelper.regular,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: OffsetWidget.setSc(15)),
                child: Image.asset(
                  Constant.ASSETS_IMG + "icon/arrow_black_right.png",
                  fit: BoxFit.cover,
                  scale: 2.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String descName = mwallet.fullName;

    return CustomPageView(
      hiddenResizeToAvoidBottomInset: false,
      title: CustomPageView.getDefaultTitle(
        titleStr: "wallet_management".local(),
      ),
      backgroundColor: Color(0xFFEAEFF2),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
                left: OffsetWidget.setSc(20),
                right: OffsetWidget.setSc(20),
                bottom: OffsetWidget.setSc(10)),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: OffsetWidget.setSc(45),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "wallet_type".local(),
                        style: TextStyle(
                          color: Color(0xFF171F24),
                          fontSize: OffsetWidget.setSp(16),
                          fontWeight: FontWightHelper.regular,
                        ),
                      ),
                      Text(
                        descName,
                        style: TextStyle(
                          color: Color(0xFF171F24),
                          fontSize: OffsetWidget.setSp(12),
                          fontWeight: FontWightHelper.regular,
                        ),
                      ),
                    ],
                  ),
                ),
                OffsetWidget.vLineWhitColor(1, Color(0xFFEAEFF2)),
                Container(
                  height: OffsetWidget.setSc(45),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "wallet_name".local(),
                        style: TextStyle(
                          color: Color(0xFF171F24),
                          fontSize: OffsetWidget.setSp(16),
                          fontWeight: FontWightHelper.regular,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            mwallet.descName,
                            style: TextStyle(
                              color: Color(0xFF171F24),
                              fontSize: OffsetWidget.setSp(12),
                              fontWeight: FontWightHelper.regular,
                            ),
                          ),
                          Container(
                            padding:
                                EdgeInsets.only(left: OffsetWidget.setSc(15)),
                            child: Image.asset(
                              Constant.ASSETS_IMG +
                                  "icon/arrow_black_right.png",
                              fit: BoxFit.cover,
                              scale: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                OffsetWidget.vLineWhitColor(1, Color(0xFFEAEFF2)),
                Container(
                  constraints: BoxConstraints(
                    minHeight: OffsetWidget.setSc(45),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "wallet_address".local(),
                        textAlign: TextAlign.left,
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
                Container(
                  height: OffsetWidget.setSc(45),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "export_keystore".local(),
                        style: TextStyle(
                          color: Color(0xFF171F24),
                          fontSize: OffsetWidget.setSp(16),
                          fontWeight: FontWightHelper.regular,
                        ),
                      ),
                      Image.asset(
                        Constant.ASSETS_IMG + "icon/arrow_black_right.png",
                        fit: BoxFit.cover,
                        scale: 2.0,
                      ),
                    ],
                  ),
                ),
                OffsetWidget.vLineWhitColor(1, Color(0xFFEAEFF2)),
                Container(
                  height: OffsetWidget.setSc(45),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "export_prv".local(),
                        style: TextStyle(
                          color: Color(0xFF171F24),
                          fontSize: OffsetWidget.setSp(16),
                          fontWeight: FontWightHelper.regular,
                        ),
                      ),
                      Image.asset(
                        Constant.ASSETS_IMG + "icon/arrow_black_right.png",
                        fit: BoxFit.cover,
                        scale: 2.0,
                      ),
                    ],
                  ),
                ),
                OffsetWidget.vLineWhitColor(1, Color(0xFFEAEFF2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
