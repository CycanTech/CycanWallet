import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter_coinid/channel/channel_scan.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/pages/main/wallets_managet_sheet.dart';
import 'package:flutter_coinid/utils/ver_upgrade_util.dart';
import 'package:flutter_coinid/widgets/custom_network_image.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../public.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  bool isObscureText = false;

  @override
  void initState() {
    super.initState();
    //版本检测
    VerSionUpgradeUtil.getAppInfo(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> getBarAction() {
    return <Widget>[
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => {
          Routers.push(context, Routers.walletManagerPage),
        },
        child: LoadAssetsImage(
          Constant.ASSETS_IMG + "icon/icon_option.png",
          scale: 2,
          width: OffsetWidget.setSc(45),
          height: OffsetWidget.setSc(45),
          fit: null,
        ),
      ),
    ];
  }

  void _cellDidSelectRowAt(int index) {
    List collectionTokens =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .collectionTokens;
    String convert =
        Provider.of<SystemSettings>(context, listen: false).currencySymbolStr;
    MHWallet mwallet =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet;

    Map<String, dynamic> map = collectionTokens[index];
    String total = StringUtil.dataFormat(
        double.parse(map["balance"].replaceAll(" " + map["token"], "")) *
            double.parse(map["price"].toString()),
        2);

    if (!StringUtil.isNotEmpty(total)) {
      total = "0.00";
    }
    Map<String, dynamic> params = HashMap();
    params["token"] = map["token"];
    params["decimals"] = map["decimals"];
    params["contract"] = map["contract"];
    params["balance"] = map["balance"];
    params["total"] = "≈$convert" + total;
    params["walletAddress"] = mwallet.walletAaddress;
    params["chainType"] = mwallet.chainType;

    Routers.push(context, Routers.transListPage, params: params);
  }

  Widget _cellBuilder(int index) {
    List collectionTokens =
        Provider.of<CurrentChooseWalletState>(context).collectionTokens;
    String convert = Provider.of<SystemSettings>(context).currencySymbolStr;
    Map<String, dynamic> map = collectionTokens[index];
    String tokenAssets = "0.00";
    if (StringUtil.isNotEmpty(map["balance"]) &&
        StringUtil.isNotEmpty(map["token"])) {
      tokenAssets = StringUtil.dataFormat(
          double.parse(map["balance"].replaceAll(" " + map["token"], "")) *
              double.parse(map["price"].toString()),
          2);
    }
    tokenAssets = "≈$convert " + tokenAssets;
    return Container(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: GestureDetector(
        onTap: () => {
          _cellDidSelectRowAt(index),
        },
        child: Container(
          padding: EdgeInsets.only(left: OffsetWidget.setSp(19)),
          height: OffsetWidget.setSp(54),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: <Widget>[
              StringUtil.isNotEmpty(map["iconPath"])
                  ? LoadNetworkImage(
                      map["iconPath"],
                      width: OffsetWidget.setSc(30),
                      height: OffsetWidget.setSc(30),
                      fit: BoxFit.contain,
                      scale: 1,
                    )
                  : LoadAssetsImage(
                      Constant.ASSETS_IMG +
                          "wallet/icon_" +
                          map["coinType"].toLowerCase() +
                          "_token_default.png",
                      width: OffsetWidget.setSc(28),
                      height: OffsetWidget.setSc(28),
                      fit: BoxFit.contain,
                    ),
              OffsetWidget.hGap(9),
              Container(
                width: OffsetWidget.setSc(100),
                child: Text(
                  map["token"],
                  style: TextStyle(
                      fontSize: OffsetWidget.setSp(19),
                      color: Color(0xFF171F24)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Container(
                alignment: Alignment.topRight,
                width: OffsetWidget.setSc(120),
                margin: EdgeInsets.only(
                    left: OffsetWidget.setSp(19),
                    top: OffsetWidget.setSp(10),
                    right: OffsetWidget.setSp(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      StringUtil.isNotEmpty(map["balance"])
                          ? StringUtil.dataFormat(
                              double.parse(map["balance"]
                                  .replaceAll(" " + map["token"], "")),
                              4)
                          : '0.0000',
                      style: TextStyle(
                          fontSize: OffsetWidget.setSp(19),
                          color: Color(0xFF171F24)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      tokenAssets,
                      style: TextStyle(
                          fontSize: OffsetWidget.setSp(13),
                          color: Color(0xFF9B9B9B)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
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
      ),
    );
  }

  _walletEditName() {
    TextEditingController controller = TextEditingController();
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("wallet_update_name".local()),
            content: Column(
              children: [
                CupertinoTextField(
                  maxLines: 1,
                  controller: controller,
                  autofocus: true,
                ),
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text("dialog_confirm".local()),
                  onPressed: () {
                    String text = controller.text;
                    Navigator.pop(context);
                    Provider.of<CurrentChooseWalletState>(context,
                            listen: false)
                        .updateWalletDescName(text);
                  }),
              CupertinoDialogAction(
                child: Text("dialog_cancel".local()),
                onPressed: () {
                  controller.text = "";
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  _receive() {
    Routers.push(context, Routers.recervePaymentPage);
  }

  _payment() {
    MHWallet mwallet =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet;
    Map<String, dynamic> params = Map();
    params["contract"] = "";
    params["token"] = mwallet.symbol;
    params["decimals"] = Constant.getChainDecimals(mwallet.chainType);
    Routers.push(context, Routers.paymentPage, params: params);
  }

  _wallets() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        elevation: 0,
        isDismissible: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        builder: (context) {
          return SafeArea(child: WalletsSheetPage());
        });
  }

  _scan() async {
    MHWallet mwallet =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet;
    Map<String, dynamic> params = Map();
    params["contract"] = "";
    params["token"] = mwallet.symbol;
    params["decimals"] = Constant.getChainDecimals(mwallet.chainType);
    String result = await ChannelScan.scan();
    Routers.push(context, Routers.paymentPage, params: params);
  }

  _addAssetsList() {
    MHWallet mwallet =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet;
    if (mwallet.chainType == MCoinType.MCoinType_ETH.index) {
      Map<String, dynamic> params = HashMap();
      params["account"] = mwallet.walletAaddress;
      params["symbol"] = mwallet.symbol.toUpperCase();
      Routers.push(context, Routers.addAssetsPagePage, params: params);
    }
  }

  Widget buildHeadView() {
    List allTokens = Provider.of<CurrentChooseWalletState>(context).allTokens;
    MHWallet mwallet =
        Provider.of<CurrentChooseWalletState>(context).currentWallet;
    String convert = Provider.of<SystemSettings>(context).currencySymbolStr;
    String logoPath = "";
    String bgPath = "";
    String chain = "";
    String total = "0.00";
    double calculation = 0;
    int i = 0;
    for (i = 0; i < allTokens.length; i++) {
      Map<String, dynamic> map = allTokens[i];
      if (StringUtil.isNotEmpty(map["balance"]) &&
          StringUtil.isNotEmpty(map["price"])) {
        calculation +=
            double.parse(map["balance"]) * double.parse(map["price"]);
      }
    }
    total = StringUtil.dataFormat(calculation, 2);
    total = "≈$convert " + total;
    total = isObscureText ? "******" : total;
    if (mwallet != null) {
      logoPath = Constant.ASSETS_IMG + "wallet/logo_" + mwallet.symbol + ".png";
      bgPath = Constant.ASSETS_IMG +
          "background/bg_" +
          mwallet.symbol.toLowerCase() +
          "_index.png";
      chain = mwallet.symbol + " - ";
    }
    String name = mwallet != null &&
            mwallet.descName != null &&
            mwallet.descName.length > 0
        ? chain + mwallet.descName
        : chain + "Wallet";
    String address = mwallet?.walletAaddress ??= "";

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (mwallet != null) {
                Map<String, dynamic> params = HashMap();
                params["walletID"] = mwallet.walletID;
                Routers.push(context, Routers.walletInfoPagePage,
                    params: params);
              }
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  OffsetWidget.setSc(40),
                  OffsetWidget.setSc(45),
                  OffsetWidget.setSc(40),
                  OffsetWidget.setSc(50)),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    bgPath,
                  ),
                  fit: BoxFit.contain,
                ),
              ),
              height: OffsetWidget.setSc(220),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //地址名字编辑
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LoadAssetsImage(
                              logoPath,
                              width: OffsetWidget.setSc(17),
                              height: OffsetWidget.setSc(17),
                              fit: BoxFit.contain,
                            ),
                            OffsetWidget.hGap(4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                        fontWeight: FontWightHelper.medium,
                                        fontSize: OffsetWidget.setSp(18),
                                        color: Color(0xFFFFFFFF)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  OffsetWidget.vGap(5),
                                  Text(
                                    address,
                                    style: TextStyle(
                                        fontWeight: FontWightHelper.regular,
                                        fontSize: OffsetWidget.setSp(10),
                                        color: Color(0xFFFFFFFF)),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _walletEditName();
                        },
                        child: LoadAssetsImage(
                          Constant.ASSETS_IMG + "icon/icon_edit.png",
                          width: OffsetWidget.setSc(25),
                          height: OffsetWidget.setSc(18),
                        ),
                      ),
                    ],
                  ),
                  //资产金额
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            total,
                            style: TextStyle(
                                fontWeight: FontWightHelper.medium,
                                fontSize: OffsetWidget.setSp(23),
                                color: Color(0xFFFFFFFF)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          // OffsetWidget.hGap(10),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                isObscureText = !isObscureText;
                              });
                            },
                            child: LoadAssetsImage(
                              Constant.ASSETS_IMG +
                                  "icon/icon_white_closeeyes.png",
                              width: OffsetWidget.setSc(45),
                              height: OffsetWidget.setSc(45),
                              fit: null,
                              scale: 2,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Total Assets",
                        style: TextStyle(
                            fontWeight: FontWightHelper.regular,
                            fontSize: OffsetWidget.setSp(12),
                            color: Color(0xFFFFFFFF)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          buildItemBar(),
        ],
      ),
    );
  }

  Widget buildItemBar() {
    return Container(
      color: Colors.red,
      padding: EdgeInsets.only(
          left: OffsetWidget.setSc(25),
          right: OffsetWidget.setSc(25),
          bottom: OffsetWidget.setSc(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _receive(),
            child: Container(
              child: Column(
                children: [
                  LoadAssetsImage(
                    Constant.ASSETS_IMG + "icon/icon_recevice.png",
                    width: OffsetWidget.setSc(23),
                    height: OffsetWidget.setSc(23),
                  ),
                  OffsetWidget.vGap(5),
                  Text(
                    "trans_receive".local(),
                    style: TextStyle(
                        color: Color(0xFF161D2D),
                        fontSize: OffsetWidget.setSp(15),
                        fontWeight: FontWightHelper.medium),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _payment(),
            child: Container(
              width: OffsetWidget.setSc(310 / 4),
              child: Column(
                children: [
                  LoadAssetsImage(
                    Constant.ASSETS_IMG + "icon/icon_payment.png",
                    width: OffsetWidget.setSc(23),
                    height: OffsetWidget.setSc(23),
                  ),
                  OffsetWidget.vGap(5),
                  Text(
                    "wallet_payment".local(),
                    style: TextStyle(
                        color: Color(0xFF161D2D),
                        fontSize: OffsetWidget.setSp(15),
                        fontWeight: FontWightHelper.medium),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _wallets(),
            child: Container(
              child: Column(
                children: [
                  LoadAssetsImage(
                    Constant.ASSETS_IMG + "icon/icon_wallets.png",
                    width: OffsetWidget.setSc(23),
                    height: OffsetWidget.setSc(23),
                  ),
                  OffsetWidget.vGap(5),
                  Text(
                    "wallet_manager".local(),
                    style: TextStyle(
                        color: Color(0xFF161D2D),
                        fontSize: OffsetWidget.setSp(15),
                        fontWeight: FontWightHelper.medium),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _scan(),
            child: Container(
              child: Column(
                children: [
                  LoadAssetsImage(
                    Constant.ASSETS_IMG + "icon/icon_scan.png",
                    width: OffsetWidget.setSc(23),
                    height: OffsetWidget.setSc(23),
                  ),
                  OffsetWidget.vGap(5),
                  Text(
                    "wallet_scans".local(),
                    style: TextStyle(
                        color: Color(0xFF161D2D),
                        fontSize: OffsetWidget.setSp(15),
                        fontWeight: FontWightHelper.medium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    CurrentChooseWalletState statewallets =
        Provider.of<CurrentChooseWalletState>(context);
    return CustomPageView(
      hiddenScrollView: true,
      hiddenLeading: true,
      backgroundColor: Color(0xFFF8F9FB),
      actions: getBarAction(),
      child: CustomRefresher(
          refreshController: refreshController,
          onRefresh: () {
            Provider.of<CurrentChooseWalletState>(context, listen: false)
                .findMainTokenCount();
            Future.delayed(Duration(seconds: 3)).then((value) => {
                  refreshController.loadComplete(),
                  refreshController.refreshCompleted(resetFooterState: true),
                });
          },
          enableFooter: false,
          child: Column(
            children: [
              buildHeadView(),
              Visibility(
                visible: statewallets.currentWallet.chainType ==
                    MCoinType.MCoinType_ETH.index,
                child: Container(
                  height: OffsetWidget.setSc(50),
                  padding: EdgeInsets.only(
                      left: OffsetWidget.setSc(20),
                      right: OffsetWidget.setSc(20)),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "main_assets".local(),
                              style: TextStyle(
                                  fontSize: OffsetWidget.setSp(14),
                                  fontWeight: FontWightHelper.medium,
                                  color: Color(0xFF4A4A4A)),
                            ),
                            GestureDetector(
                              onTap: () => _addAssetsList(),
                              child: Visibility(
                                  visible: true,
                                  child: LoadAssetsImage(
                                    Constant.ASSETS_IMG +
                                        "icon/icon_add_token.png",
                                    width: OffsetWidget.setSc(16),
                                    height: OffsetWidget.setSc(16),
                                    fit: BoxFit.contain,
                                  )),
                            ),
                          ],
                        ),
                      ),
                      OffsetWidget.vLineWhitColor(1, Color(0xFFEAEFF2)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: Provider.of<CurrentChooseWalletState>(context)
                      .collectionTokens
                      .length,
                  itemBuilder: (BuildContext context, int index) {
                    return _cellBuilder(index);
                  },
                ),
              ),
            ],
          )),
    );
  }
}
