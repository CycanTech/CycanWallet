import 'dart:collection';

import 'package:easy_localization/easy_localization.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coinid/channel/channel_scan.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/net/chain_services.dart';
import 'package:flutter_coinid/net/wallet_services.dart';
import 'package:flutter_coinid/services/EventBus.dart';
import 'package:flutter_coinid/utils/json_util.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';
import 'package:flutter_coinid/utils/ver_upgrade_util.dart';
import 'package:flutter_coinid/widgets/custom_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../public.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MHWallet mwallet;
  bool isShowSliderView = false;
  bool isShowAddResource = false;
  List collectionTokens = List(); //我的资产
  List allTokens = List(); //我的所有资产
  Map mainToken = {}; //主币的价格和数量
  String convert = "cny";
  var _eventBusOn;
  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    _getConvert();
    _findChooseWallet();
    //版本检测
    VerSionUpgradeUtil.getAppInfo(context);
    this._eventBusOn = eventBus.on<ConvertEvent>().listen((event) {
      if (event.value == 0) {
        convert = "cny";
      } else {
        convert = "usd";
      }
      setState(() {});
      _findChooseWallet();
    });
  }

  dispose() {
    this._eventBusOn.cancel(); //取消事件监听
    super.dispose();
  }

  _getConvert() async {
    int amountType = await getAmountValue();
    if (amountType == 0) {
      convert = "cny";
    } else {
      convert = "usd";
    }
    setState(() {});
    // String a = await rootBundle.loadString("resources/langs/en-US.json");
    // String b = await rootBundle.loadString("resources/langs/zh-CN.json");
    // Map en = JsonUtil.getObj(a.toString());
    // Map cn = JsonUtil.getObj(b.toString());
    // Map newmap = Map();
    // cn.forEach((key, value) {
    //   if (!en.containsKey(key)) {
    //     newmap[key] = value;
    //   }
    // });
    // LogUtil.v("rootBundle");
    // print(JsonUtil.encodeObj(newmap));
  }

  _findChooseWallet() async {
    MHWallet wallet = await MHWallet.findChooseWallet();

    if (wallet != null) {
      setState(() {
        mwallet = wallet;
        collectionTokens = List();
        allTokens = List();
        _findMainTokenCount();
      });
    }
  }

  _findMyCollectionTokens() {
    Future.delayed(Duration(seconds: 2)).then((value) => {
          refreshController.refreshCompleted(),
          refreshController.loadComplete(),
        });
    if (mwallet != null) {
      WalletServices.requestMyCollectionTokens(
          mwallet.walletAaddress, convert, mwallet.symbol.toUpperCase(),
          (result, code) {
        if (mounted) {
          setState(() {
            Map<String, dynamic> map = Map();
            if (result == null || result.length == 0) {
              //没有数据返回，自己补上主币数据
              result = [];
              map["id"] = "";
              map["contract"] = "";
              map["token"] = mwallet.symbol;
              map["coinType"] = mwallet.symbol;
              map["iconPath"] = "";
              map["state"] = "";
              if (mwallet.chainType == MCoinType.MCoinType_BTC.index) {
                map["decimals"] = "8";
              } else if (mwallet.chainType == MCoinType.MCoinType_ETH.index) {
                map["decimals"] = "18";
              } else if (mwallet.chainType == MCoinType.MCoinType_DOT.index) {
                map["decimals"] = "10";
              }
              if (convert == "cny") {
                map["price"] = mainToken["p"];
              } else {
                map["price"] = mainToken["up"];
              }
              map["balance"] = mainToken["c"].toString();
              result.add(map);
            } else {
              map = result[0];
              if (convert == "cny") {
                map["price"] = mainToken["p"];
              } else {
                map["price"] = mainToken["up"];
              }
              map["balance"] = mainToken["c"].toString();
            }
            collectionTokens = result;
          });
        }
      });
    }
  }

  _findCurrencyTokenPriceAndTokenCount() {
    if (mwallet != null) {
      WalletServices.requestGetCurrencyTokenPriceAndTokenCount(
          mwallet.walletAaddress, convert, mwallet.symbol.toUpperCase(),
          (result, code) {
        if (mounted) {
          setState(() {
            Map<String, dynamic> map = Map();
            if (result == null || result.length == 0) {
              //没有数据返回，自己补上主币数据
              result = [];
              map["symbol"] = mwallet.symbol.toUpperCase();
              map["code"] = "";
              if (convert == "cny") {
                map["price"] = mainToken["p"].toString();
              } else {
                map["price"] = mainToken["up"].toString();
              }
              map["balance"] = mainToken["c"].toString();
              result.add(map);
            } else {
              map = result[0];
              if (convert == "cny") {
                map["price"] = mainToken["p"].toString();
              } else {
                map["price"] = mainToken["up"].toString();
              }
              map["balance"] = mainToken["c"].toString();
            }
            allTokens = result;
          });
        }
      });
    }
  }

  _findMainTokenCount() {
    if (mwallet != null) {
      ChainServices.requestAssets(
        chainType: mwallet.symbol,
        from: mwallet.walletAaddress,
        contract: null,
        token: null,
        block: (result, code) {
          if (code == 200 && mounted) {
            print("主币价格：$result");
            mainToken = result as Map;
          }
          _findMyCollectionTokens();
          _findCurrencyTokenPriceAndTokenCount();
        },
      );
    }
  }

  List<Widget> getBarAction() {
    return <Widget>[
      GestureDetector(
        onTap: () => {
          Routers.push(context, Routers.walletManagerPage)
              .then((value) => _findChooseWallet()),
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
    Map<String, dynamic> map = collectionTokens[index];
    String total = StringUtil.dataFormat(
        double.parse(map["balance"].replaceAll(" " + map["token"], "")) *
            double.parse(map["price"].toString()),
        2);

    if (!StringUtil.isNotEmpty(total)) {
      total = "0.00";
    }

    Map<String, dynamic> params = HashMap();
    params["walletAddress"] = mwallet.walletAaddress;
    params["token"] = map["token"];
    params["decimals"] = map["decimals"];
    params["contract"] = map["contract"];
    params["chainType"] = mwallet.chainType;
    params["balance"] = map["balance"];
    params["total"] = (convert == "cny" ? '≈ ¥ ' : '≈ \$') + total;
    Routers.push(context, Routers.transListPage, params: params);
  }

  Widget _cellBuilder(int index) {
    Map<String, dynamic> map = collectionTokens[index];
    String total = "0.00";
    if (StringUtil.isNotEmpty(map["balance"]) &&
        StringUtil.isNotEmpty(map["token"])) {
      total = StringUtil.dataFormat(
          double.parse(map["balance"].replaceAll(" " + map["token"], "")) *
              double.parse(map["price"].toString()),
          2);
    }

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
            // color: Color(Constant.TextFileld_FillColor),
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
                      (convert == "cny" ? '≈ ¥ ' : '≈ \$') + total,
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
    if (StringUtil.isNotEmpty(mwallet.walletAaddress)) {
      Map<String, dynamic> params = HashMap();
      params["walletAddress"] = mwallet.walletAaddress;
      params["onlyAddress"] = "1";
      params["contract"] = "";
      params["token"] = mwallet.symbol;
      params["decimals"] = "0";
      params["chainType"] = mwallet.chainType;
      Routers.push(context, Routers.recervePaymentPage, params: params);
    } else {
      Map<String, dynamic> params = HashMap();
      params["active"] = mwallet.subPubKey;
      params["owner"] = mwallet.pubKey;
      Routers.push(context, Routers.registerShowKeyPage, params: params);
    }
  }

  _receive() {
    print("object");
  }

  _payment() {
    print("object");
  }

  _wallets() {
    print("object");
  }

  _scan() async {
    String result = await ChannelScan.scan();
    print("flutter扫码结果: $result");
  }

  _addAssetsList() {
    print("object");
    if (mwallet != null &&
        StringUtil.isNotEmpty(mwallet.walletAaddress) &&
        isShowAddResource) {
      Map<String, dynamic> params = HashMap();
      params["account"] = mwallet.walletAaddress;
      params["symbol"] = mwallet.symbol.toUpperCase();

      Routers.push(context, Routers.addAssetsPagePage, params: params)
          .then((value) => {
                _findMainTokenCount(),
              });
    }
  }

  Widget buildHeadView() {
    String logoPath = Constant.ASSETS_IMG + "wallet/logo_BTC.png";
    String bgPath = Constant.ASSETS_IMG + "background/bg_btc_index.png";
    bool isRegisterEos = true;
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

    if (mwallet != null) {
      if (mwallet.walletAaddress == null ||
          mwallet.walletAaddress.length == 0) {
        isRegisterEos = false;
      } else {
        isRegisterEos = true;
      }
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

    String address = isRegisterEos
        ? (mwallet != null ? mwallet.walletAaddress : "")
        : "main_noaccount".local();

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
                        params: params)
                    .then((value) => {
                          _findChooseWallet(),
                        });
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LoadAssetsImage(
                            logoPath,
                            width: OffsetWidget.setSc(17),
                            height: OffsetWidget.setSc(17),
                            fit: BoxFit.contain,
                          ),
                          Container(
                            width: OffsetWidget.setSc(230),
                            padding: EdgeInsets.only(left: 4),
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
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _walletEditName();
                        },
                        child: LoadAssetsImage(
                          Constant.ASSETS_IMG + "icon/icon_edit.png",
                          width: OffsetWidget.setSc(15),
                          height: OffsetWidget.setSc(18),
                          fit: BoxFit.contain,
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
                            "******",
                            style: TextStyle(
                                fontWeight: FontWightHelper.medium,
                                fontSize: OffsetWidget.setSp(23),
                                color: Color(0xFFFFFFFF)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          OffsetWidget.hGap(10),
                          LoadAssetsImage(
                            Constant.ASSETS_IMG +
                                "icon/icon_white_closeeyes.png",
                            width: OffsetWidget.setSc(17),
                            height: OffsetWidget.setSc(7),
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
          buildAssetsBar(),
        ],
      ),
    );
  }

  Widget buildAssetsBar() {
    return Container(
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
    return CustomPageView(
      hiddenScrollView: true,
      hiddenLeading: true,
      backgroundColor: Color(0xFFF8F9FB),
      actions: getBarAction(),
      child: CustomRefresher(
          refreshController: refreshController,
          onRefresh: () {
            _findMainTokenCount();
          },
          enableFooter: false,
          child: Column(
            children: [
              buildHeadView(),
              Container(
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
              Expanded(
                child: ListView.builder(
                  itemCount: collectionTokens.length,
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
