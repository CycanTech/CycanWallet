import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter_coinid/channel/channel_scan.dart';
import 'package:flutter_coinid/models/tokens/collection_tokens.dart';
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
  @override
  void initState() {
    super.initState();
    //版本检测
    // VerSionUpgradeUtil.getAppInfo(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _cellDidSelectRowAt(int index) {
    Provider.of<CurrentChooseWalletState>(context, listen: false)
        .updateTokenChoose(index);
    Routers.push(context, Routers.transListPage).then((value) => {
          Provider.of<CurrentChooseWalletState>(context, listen: false)
              .requestAssets(),
        });
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
    Provider.of<CurrentChooseWalletState>(context, listen: false)
        .updateTokenChoose(0);
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
    Routers.push(context, Routers.walletManagerPage);
  }

  _scan() async {
    Provider.of<CurrentChooseWalletState>(context, listen: false)
        .updateTokenChoose(0);
    MHWallet mwallet =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet;
    Map<String, dynamic> params = Map();
    params["contract"] = "";
    params["token"] = mwallet.symbol;
    params["decimals"] = Constant.getChainDecimals(mwallet.chainType);
    String result = await ChannelScan.scan();
    params["to"] = result;
    if (result.contains("ethereum:") ||
        result.contains("bitcoin:") ||
        result.contains("dot:")) {
      if (result.contains("ethereum:")) {
        params["to"] = result.replaceAll("ethereum:", "").substring(0, 42);
      } else {
        int index = result.indexOf("&decimal");
        if (index != -1) {
          params["to"] = result
              .replaceAll("dot:", "")
              .replaceAll("bitcoin:", "")
              .substring(0, index);
        }
      }
    }
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

  Widget getCustomAppBar() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            elevation: 0,
            isDismissible: true,
            isScrollControlled: true,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            builder: (context) {
              return SafeArea(child: WalletsSheetPage());
            }),
      },
      child: Container(
        height: OffsetWidget.setSc(30),
        alignment: Alignment.centerRight,
        child: LoadAssetsImage(
          Constant.ASSETS_IMG + "icon/icon_option.png",
          scale: 2,
          width: OffsetWidget.setSc(45),
          height: OffsetWidget.setSc(30),
          fit: null,
        ),
      ),
    );
  }

  Widget buildHeadView() {
    MHWallet mwallet =
        Provider.of<CurrentChooseWalletState>(context).currentWallet;
    String total = Provider.of<CurrentChooseWalletState>(context).totalAssets;
    String fromTypeImage = "";
    String bgPath = "";
    String chain = "";
    if (mwallet != null) {
      fromTypeImage = Constant.ASSETS_IMG + "wallet/wallettype_leadin.png";
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
    String address = mwallet?.walletAaddress;
    address ??= "";
    bool hiddenAssets = mwallet.hiddenAssets;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          getCustomAppBar(),
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
                  OffsetWidget.setSc(45)),
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
                  //图片名字编辑
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                LoadAssetsImage(
                                  fromTypeImage,
                                  width: OffsetWidget.setSc(17),
                                  height: OffsetWidget.setSc(17),
                                  fit: BoxFit.contain,
                                ),
                                OffsetWidget.hGap(4),
                                Text(
                                  name,
                                  style: TextStyle(
                                      fontWeight: FontWightHelper.medium,
                                      fontSize: OffsetWidget.setSp(18),
                                      color: Color(0xFFFFFFFF)),
                                  overflow: TextOverflow.ellipsis,
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
                      Container(
                        padding: EdgeInsets.only(
                          left: OffsetWidget.setSc(22),
                          right: OffsetWidget.setSc(35),
                          top: OffsetWidget.setSc(3),
                        ),
                        child: Text(
                          address,
                          style: TextStyle(
                              fontWeight: FontWightHelper.regular,
                              fontSize: OffsetWidget.setSp(10),
                              color: Color(0xFFFFFFFF)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
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
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: OffsetWidget.setSc(220),
                            ),
                            child: Text(
                              total,
                              maxLines: 1,
                              style: TextStyle(
                                  fontWeight: FontWightHelper.medium,
                                  fontSize: OffsetWidget.setSp(23),
                                  color: Color(0xFFFFFFFF)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Provider.of<CurrentChooseWalletState>(context,
                                      listen: false)
                                  .updateWalletAssetsState(!hiddenAssets);
                            },
                            child: LoadAssetsImage(
                              hiddenAssets == true
                                  ? Constant.ASSETS_IMG +
                                      "icon/icon_white_closeeyes.png"
                                  : Constant.ASSETS_IMG +
                                      "icon/icon_white_openeyes.png",
                              width: OffsetWidget.setSc(40),
                              height: OffsetWidget.setSc(40),
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
      padding: EdgeInsets.only(
        left: OffsetWidget.setSc(25),
        right: OffsetWidget.setSc(25),
      ),
      height: OffsetWidget.setSc(65),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
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
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0xFF161D2D),
                          fontSize: OffsetWidget.setSp(15),
                          fontWeight: FontWightHelper.medium),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
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
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0xFF161D2D),
                          fontSize: OffsetWidget.setSp(15),
                          fontWeight: FontWightHelper.medium),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
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
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0xFF161D2D),
                          fontSize: OffsetWidget.setSp(15),
                          fontWeight: FontWightHelper.medium),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
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
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0xFF161D2D),
                          fontSize: OffsetWidget.setSp(15),
                          fontWeight: FontWightHelper.medium),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cellBuilder(int index) {
    String tokenAssets = "0.00";
    String balance = "0.0000";
    MHWallet mwallet =
        Provider.of<CurrentChooseWalletState>(context).currentWallet;
    List<MCollectionTokens> collectionTokens =
        Provider.of<CurrentChooseWalletState>(context).collectionTokens;
    String convert =
        Provider.of<CurrentChooseWalletState>(context).currencySymbolStr;
    MCollectionTokens map = collectionTokens[index];
    if (mwallet.hiddenAssets == true) {
      tokenAssets = "******";
      balance = "******";
    } else {
      tokenAssets = map.assets ;
      tokenAssets = "≈$convert" + tokenAssets;
      balance = map.balance == null
          ? "0.0000"
          : StringUtil.dataFormat(map.balance.toDouble(), 4);
    }
    String iconPath = map.iconPath;
    String placeholderPath = Constant.ASSETS_IMG +
        "wallet/icon_" +
        map.coinType.toLowerCase() +
        "_token_default.png";
    String token = map.token;

    return Container(
      padding: EdgeInsets.only(
          left: OffsetWidget.setSc(20), right: OffsetWidget.setSc(20)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => {
          _cellDidSelectRowAt(index),
        },
        child: Container(
          padding: EdgeInsets.only(left: OffsetWidget.setSc(19)),
          height: OffsetWidget.setSc(55),
          // decoration: BoxDecoration(
          //   border: Border(
          //     bottom: BorderSide(
          //       color: Color(0XFFEAEFF2),
          //       width: 1,
          //       style: BorderStyle.solid,
          //     ),
          //   ),
          // ),
          child: Row(
            children: <Widget>[
              LoadNetworkImage(
                iconPath,
                width: OffsetWidget.setSc(36),
                height: OffsetWidget.setSc(36),
                fit: BoxFit.contain,
                scale: 2,
                placeholder: placeholderPath,
              ),
              OffsetWidget.hGap(8),
              Container(
                width: OffsetWidget.setSc(120),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      token,
                      style: TextStyle(
                          fontWeight: FontWightHelper.semiBold,
                          fontSize: OffsetWidget.setSp(18),
                          color: Color(0XFF171F24)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      token,
                      style: TextStyle(
                          fontWeight: FontWightHelper.medium,
                          fontSize: OffsetWidget.setSp(10),
                          color: Color(0xFFACBBCF)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topRight,
                width: OffsetWidget.setSc(100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      balance,
                      style: TextStyle(
                          fontSize: OffsetWidget.setSp(18),
                          fontWeight: FontWightHelper.regular,
                          color: Color(0XFF171F24)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      tokenAssets,
                      style: TextStyle(
                          fontWeight: FontWightHelper.medium,
                          fontSize: OffsetWidget.setSp(10),
                          color: Color(0xFF9B9B9B)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: OffsetWidget.setSc(20)),
                child: Image.asset(
                  Constant.ASSETS_IMG + "icon/arrow_dian_right.png",
                  fit: BoxFit.cover,
                  scale: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MHWallet stateWallet =
        Provider.of<CurrentChooseWalletState>(context).currentWallet;
    return CustomPageView(
      hiddenScrollView: true,
      hiddenLeading: true,
      backgroundColor: Color(0xFFF8F9FB),
      hiddenAppBar: true,
      child: CustomRefresher(
          refreshController: refreshController,
          onRefresh: () {
            Provider.of<CurrentChooseWalletState>(context, listen: false)
                .requestAssets();
            Future.delayed(Duration(seconds: 3)).then((value) => {
                  refreshController.loadComplete(),
                  refreshController.refreshCompleted(resetFooterState: true),
                });
          },
          enableFooter: false,
          child: stateWallet == null
              ? Container()
              : Column(
                  children: [
                    buildHeadView(),
                    Visibility(
                      visible: stateWallet.chainType ==
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                        itemCount:
                            Provider.of<CurrentChooseWalletState>(context)
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
