import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coinid/channel/channel_native.dart';
import 'package:flutter_coinid/channel/channel_wallet.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/utils/instruction_data_format.dart';

import '../../public.dart';

class TabObj {
  String logoPath;
  String title;
  int optionType;

  TabObj({this.logoPath, this.title, this.optionType});
}

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
  List<TabObj> mtabs = [];
  String walletID;
  MHWallet mwallet;
  TextEditingController pinEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    TabObj obj = TabObj(
        logoPath: Constant.ASSETS_IMG + "icon/ic_update_wallet_name.png",
        title: "wallet_update_name".local(),
        optionType: MWalletOptionType.MWalletOptionType_Update_Name.index);
    mtabs.add(obj);
    obj = TabObj(
        logoPath: Constant.ASSETS_IMG + "icon/icon_pwd_tip.png",
        title: "wallet_pwd_tips".local(),
        optionType: MWalletOptionType.MWalletOptionType_Tips.index);
    mtabs.add(obj);
    obj = TabObj(
        logoPath: Constant.ASSETS_IMG + "icon/icon_export_key.png",
        title: "export_prv".local(),
        optionType: MWalletOptionType.MWalletOptionType_Export_Prvkey.index);
    mtabs.add(obj);
    _findWalletByWalletID();
  }

  _findWalletByWalletID() async {
    if (widget.params != null) {
      walletID = widget.params["walletID"][0];
      MHWallet wallet = await MHWallet.findWalletByWalletID(walletID);
      if (wallet != null) {
        if (wallet.chainType != MCoinType.MCoinType_BTM.index) {
          TabObj obj = TabObj(
              logoPath: Constant.ASSETS_IMG + "icon/icon_export_key.png",
              title: "export_keystore".local(),
              optionType:
                  MWalletOptionType.MWalletOptionType_Export_Keystore.index);
          mtabs.add(obj);
        }

        if (wallet.chainType == MCoinType.MCoinType_BTC.index ||
            wallet.chainType == MCoinType.MCoinType_USDT.index) {
          TabObj obj = TabObj(
              logoPath: Constant.ASSETS_IMG + "icon/icon_see_key.png",
              title: "wallet_switch_address".local(),
              optionType: MWalletOptionType.MWalletOptionType_SigData.index);
          mtabs.add(obj);
        }

        if (wallet.chainType == MCoinType.MCoinType_EOS.index) {
          TabObj obj = TabObj(
              logoPath: Constant.ASSETS_IMG + "icon/icon_see_key.png",
              title: "wallet_show_pub".local(),
              optionType:
                  MWalletOptionType.MWalletOptionType_Show_PubKey.index);
          mtabs.add(obj);
        }

        if (wallet.originType != MOriginType.MOriginType_Create.index &&
            wallet.originType != MOriginType.MOriginType_Restore.index) {
          TabObj obj = TabObj(
              logoPath: Constant.ASSETS_IMG + "icon/icon_clear.png",
              title: "wallet_del".local(),
              optionType: MWalletOptionType.MWalletOptionType_Clean.index);
          mtabs.add(obj);
        }

        setState(() {
          mwallet = wallet;
        });
      }
    }
  }

  void _clickCopy(String value) {
    LogUtil.v("_clickCopy " + value);
    if (value.isValid() == false) return;
    Clipboard.setData(ClipboardData(text: value));
    HWToast.showText(text: "copy_success".local());
  }

  Widget buildHeadView() {
    String logoPath = Constant.ASSETS_IMG + "wallet/logo_LTC.png";
    String bgPath = Constant.ASSETS_IMG + "background/bg_ltc.png";
    bool isRegisterEos = true;
    String chain = "";

    if (mwallet != null) {
      if (mwallet.chainType == MCoinType.MCoinType_EOS.index) {
        logoPath = Constant.ASSETS_IMG + "wallet/logo_EOS.png";
        bgPath = Constant.ASSETS_IMG + "background/bg_eos.png";
        if (mwallet.walletAaddress == null ||
            mwallet.walletAaddress.length == 0) {
          isRegisterEos = false;
        } else {
          isRegisterEos = true;
        }
        chain = "EOS-";
      } else if (mwallet.chainType == MCoinType.MCoinType_ETH.index) {
        logoPath = Constant.ASSETS_IMG + "wallet/logo_ETH.png";
        bgPath = Constant.ASSETS_IMG + "background/bg_eth.png";
        chain = "ETH-";
      } else if (mwallet.chainType == MCoinType.MCoinType_VNS.index) {
        logoPath = Constant.ASSETS_IMG + "wallet/logo_VNS.png";
        bgPath = Constant.ASSETS_IMG + "background/bg_eth.png";
        chain = "VNS-";
      } else if (mwallet.chainType == MCoinType.MCoinType_BTC.index) {
        logoPath = Constant.ASSETS_IMG + "wallet/logo_BTC.png";
        bgPath = Constant.ASSETS_IMG + "background/bg_btc.png";
        chain = "BTC-";
      } else if (mwallet.chainType == MCoinType.MCoinType_USDT.index) {
        logoPath = Constant.ASSETS_IMG + "wallet/logo_USDT.png";
        bgPath = Constant.ASSETS_IMG + "background/bg_usdt.png";
        chain = "USDT-";
      } else if (mwallet.chainType == MCoinType.MCoinType_LTC.index) {
        logoPath = Constant.ASSETS_IMG + "wallet/logo_LTC.png";
        bgPath = Constant.ASSETS_IMG + "background/bg_ltc.png";
        chain = "LTC-";
      } else if (mwallet.chainType == MCoinType.MCoinType_BTM.index) {
        logoPath = Constant.ASSETS_IMG + "wallet/logo_BTM.png";
        bgPath = Constant.ASSETS_IMG + "background/bg_btm.png";
        chain = "BTM-";
      } else if (mwallet.chainType == MCoinType.MCoinType_DOT.index) {
        logoPath = Constant.ASSETS_IMG + "wallet/logo_DOT.png";
        bgPath = Constant.ASSETS_IMG + "background/bg_dot.png";
        chain = "DOT-";
      }
    }

    return Container(
      margin: EdgeInsets.only(
          left: OffsetWidget.setSc(14),
          top: OffsetWidget.setSc(14),
          right: OffsetWidget.setSc(14)),
      padding: EdgeInsets.fromLTRB(
          OffsetWidget.setSc(22),
          OffsetWidget.setSc(23),
          OffsetWidget.setSc(22),
          OffsetWidget.setSc(16)),
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage(
            bgPath,
          ),
          fit: BoxFit.fill,
        ),
      ),
      child: Row(
        children: [
          LoadAssetsImage(
            logoPath,
            width: OffsetWidget.setSc(48),
            height: OffsetWidget.setSc(48),
            fit: BoxFit.contain,
          ),
          OffsetWidget.hGap(OffsetWidget.setSc(11)),
          Container(
            width: OffsetWidget.setSc(210),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (mwallet != null &&
                          mwallet.descName != null &&
                          mwallet.descName.length > 0
                      ? chain + mwallet.descName
                      : chain + "Wallet"),
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(29),
                      color: Color(0xFFFFFFFF)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                GestureDetector(
                  onTap: () {
                    if (isRegisterEos && mwallet != null) {
                      _clickCopy(mwallet.walletAaddress);
                    }
                  },
                  child: Row(
                    children: [
                      Container(
                        width: OffsetWidget.setSc(190),
                        child: Text(
                          isRegisterEos
                              ? (mwallet != null ? mwallet.walletAaddress : "")
                              : "main_noaccount".local(),
                          style: TextStyle(
                              fontSize: OffsetWidget.setSp(12),
                              color: Color(0xFFFFFFFF)),
                        ),
                      ),
                      OffsetWidget.hGap(OffsetWidget.setSc(5)),
                      Visibility(
                        visible: isRegisterEos,
                        child: LoadAssetsImage(
                          Constant.ASSETS_IMG + "icon/icon_copy.png",
                          width: OffsetWidget.setSc(12),
                          height: OffsetWidget.setSc(12),
                          fit: BoxFit.contain,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _cellClickAt(int optionType) {
    WalletObject walletObject;
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
      Map<String, dynamic> params = HashMap();
      _showDialog(
          context,
          "dialog_pwd".local(),
          () async => {
                if (mwallet.pin == InstructionDataFormat.SHA1(pinEC.text))
                  {
                    walletObject = await ChannelWallet.exportPrvFrom(
                        mwallet.prvKey, pinEC.text, mwallet.chainType),
                    if (walletObject != null)
                      {
                        Navigator.pop(context),
                        params["exportType"] = 0,
                        params["content"] = walletObject.prvKey,
                        Routers.push(
                            context, Routers.walletExportPrikeyKeystorePage,
                            params: params),
                      }
                  }
                else
                  {HWToast.showText(text: "payment_pwdwrong".local())}
              },
          () => null);
    } else if (MWalletOptionType.MWalletOptionType_Export_Keystore.index ==
        optionType) {
      Map<String, dynamic> params = HashMap();
      _showDialog(
          context,
          "dialog_pwd".local(),
          () async => {
                if (mwallet.pin == InstructionDataFormat.SHA1(pinEC.text))
                  {
                    walletObject = await ChannelWallet.exportKeyStoreFrom(
                        mwallet.prvKey, pinEC.text, mwallet.chainType),
                    if (walletObject != null)
                      {
                        Navigator.pop(context),
                        params["exportType"] = 1,
                        params["content"] = walletObject.keyStore,
                        Routers.push(
                            context, Routers.walletExportPrikeyKeystorePage,
                            params: params),
                      }
                  }
                else
                  {HWToast.showText(text: "payment_pwdwrong".local())}
              },
          () => null);
    } else if (MWalletOptionType.MWalletOptionType_SigData.index ==
        optionType) {
      String result;
      String privKey;
      bool flag;
      _showDialog(
          context,
          "dialog_pwd".local(),
          () async => {
                if (mwallet.pin == InstructionDataFormat.SHA1(pinEC.text))
                  {
                    privKey = await ChannelNative.decByAES128CBC(
                        mwallet.prvKey, pinEC.text),
                    if (StringUtil.isNotEmpty(privKey))
                      {
                        result = await ChannelNative.genBTCAddress(
                            privKey, !mwallet.isWegwit),
                        print(result),
                        if (StringUtil.isNotEmpty(result))
                          {
                            mwallet.walletAaddress = result,
                            mwallet.isWegwit = !mwallet.isWegwit,
                            flag = await MHWallet.updateWallet(mwallet),
                            if (flag) {Navigator.pop(context), setState(() {})}
                          }
                      }
                  }
                else
                  {HWToast.showText(text: "payment_pwdwrong".local())}
              },
          () => null);
    } else if (MWalletOptionType.MWalletOptionType_Clean.index == optionType) {
      bool flag;
      List<MHWallet> wallets;
      MHWallet wallet;
      _showDialog(
          context,
          "dialog_pwd".local(),
          () async => {
                if (mwallet.pin == InstructionDataFormat.SHA1(pinEC.text))
                  {
                    Navigator.pop(context),
                    flag = await MHWallet.deleteWallet(mwallet),
                    if (flag)
                      {
                        wallet = await MHWallet.findChooseWallet(),
                        if (wallet == null)
                          {
                            wallets = await MHWallet.findAllWallets(),
                            if (wallets != null && wallets.length > 0)
                              {
                                wallet = wallets.first,
                                wallet.isChoose = true,
                                flag = await MHWallet.updateChoose(wallet),
                                if (flag)
                                  {
                                    Routers.goBackWithParams(context, null),
                                  }
                              }
                            else
                              {
                                Routers.push(context, Routers.chooseTypePage,
                                    clearStack: true),
                              },
                          },
                      }
                  }
                else
                  {HWToast.showText(text: "payment_pwdwrong".local())}
              },
          () => null);
    } else if (MWalletOptionType.MWalletOptionType_Show_PubKey.index ==
        optionType) {
      Map<String, dynamic> params = HashMap();
      _showDialog(
          context,
          "dialog_pwd".local(),
          () => {
                if (mwallet.pin == InstructionDataFormat.SHA1(pinEC.text))
                  {
                    Navigator.pop(context),
                    params["active"] = mwallet.subPubKey,
                    params["owner"] = mwallet.pubKey,
                    Routers.push(context, Routers.walletShowPubKeyPage,
                        params: params),
                  }
                else
                  {HWToast.showText(text: "payment_pwdwrong".local())}
              },
          () => null);
    }
  }

  Widget _cellBuilder(int index) {
    TabObj tabObj = mtabs[index];
    return GestureDetector(
      onTap: () {
        _cellClickAt(tabObj.optionType);
      },
      child: Column(
        children: [
          Container(
            height: OffsetWidget.setSc(38),
            padding: EdgeInsets.only(
                left: OffsetWidget.setSc(17), right: OffsetWidget.setSc(23)),
            child: Row(
              children: [
                LoadAssetsImage(
                  tabObj.logoPath,
                  width: OffsetWidget.setSc(17),
                  height: OffsetWidget.setSc(17),
                  fit: BoxFit.contain,
                ),
                OffsetWidget.hGap(10),
                Container(
                  width: OffsetWidget.setSc(285),
                  child: Text(
                    tabObj.title,
                    style: TextStyle(
                        fontSize: OffsetWidget.setSp(13),
                        color: Color(0xFF4A4A4A)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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
          OffsetWidget.vLineWhitColor(1, Color(0xFFD7DDE1)),
        ],
      ),
    );
  }

  _showDialog(BuildContext cxt, String title, ok(), cancel()) {
    showCupertinoDialog<int>(
        context: cxt,
        builder: (cxt) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Card(
              elevation: 0.0,
              child: Container(
                width: OffsetWidget.setSc(200),
                child: CustomTextField(
                  controller: pinEC,
                  maxLines: 1,
                  fillColor: Colors.white,
                  obscureText: true,
                  contentPadding: EdgeInsets.all(OffsetWidget.setSc(8)),
                ),
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("dialog_confirm".local()),
                onPressed: () {
                  ok();
                  setState(() {
                    pinEC.text = "";
                  });
                },
              ),
              CupertinoDialogAction(
                child: Text("dialog_cancel".local()),
                onPressed: () {
                  setState(() {
                    pinEC.text = "";
                  });
                  Navigator.pop(context);
                  cancel();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    OffsetWidget.screenInit(context, 360);
    return CustomPageView(
      hiddenScrollView: true,
      hiddenResizeToAvoidBottomInset: false,
      child: Column(
        children: [
          buildHeadView(),
          OffsetWidget.vLineWhitColor(1, Color(0xFFD7DDE1)),
          OffsetWidget.vGap(42),
          OffsetWidget.vLineWhitColor(1, Color(0xFFD7DDE1)),
          Expanded(
            child: ListView.builder(
              itemCount: mtabs.length,
              itemBuilder: (BuildContext context, int index) {
                return _cellBuilder(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
