import 'package:flutter_coinid/channel/channel_dapp.dart';
import 'package:flutter_coinid/models/assets/currency_asset.dart';
import 'package:flutter_coinid/models/wallet/mh_wallet.dart';
import 'package:flutter_coinid/public.dart';
import 'package:flutter_coinid/utils/screenutil.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';

class WalletManager extends StatefulWidget {
  WalletManager({Key key}) : super(key: key);

  @override
  _WalletManagerState createState() => _WalletManagerState();
}

class _WalletManagerState extends State<WalletManager> {
  List<MHWallet> appWalletsLists = [];
  List<MHWallet> leadInWalletsLists = [];
  List<MHWallet> firmWalletLists = [];
  List<MHWallet> nfcWalletsLists = [];
  int currentPage = 0;
  final List<Tab> _myTabs = <Tab>[
    Tab(text: 'wallet_appgroup'.local()),
    Tab(text: 'wallet_leadin'.local()),
    // Tab(text: 'wallet_harewallet'.local()),
  ];

  String allAssetsValue = "0.00";
  int amountType = 0;
  String originAssets = "0";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
    _findWalletsWithDB(currentPage);
  }

  initData() async {
    int amount = await getAmountValue();
    String assets = await CurrencyAssetModel.fetchAllChainAssetsValue(
        isCny: amount == 0 ? true : false);
    originAssets = await getOriginMoney(amount == 0 ? true : false);
    setState(() {
      amountType = amount;
      allAssetsValue = assets;
    });
    CurrencyAssetModel.updateAllTokenAssets().then((value) {
      if(value == null) return;
      String newassets = amount == 0 ? value["cnysum"] : value["usdsum"];
      if (mounted) {
        setState(() {
          allAssetsValue = newassets;
        });
      }
    });

  }

  _findWalletsWithDB(int page) async {
    List<MHWallet> currents = [];
    if (page == 0) {
      currents = await MHWallet.findWalletsByType(
          MOriginType.MOriginType_Create.index);
      currents.addAll(await MHWallet.findWalletsByType(
          MOriginType.MOriginType_Restore.index));

      setState(() {
        appWalletsLists = currents;
      });
    } else if (page == 1) {
      currents = await MHWallet.findWalletsByType(
          MOriginType.MOriginType_LeadIn.index);

      setState(() {
        leadInWalletsLists = currents;
      });
    } else if (page == 2) {
      currents =
          await MHWallet.findWalletsByType(MOriginType.MOriginType_Colds.index);

      setState(() {
        firmWalletLists = currents;
      });
    } else if (page == 3) {
      currents =
          await MHWallet.findWalletsByType(MOriginType.MOriginType_NFC.index);

      setState(() {
        nfcWalletsLists = currents;
      });
    }
  }

  List<MHWallet> _findWallets(int page) {
    List<MHWallet> datas;
    if (page == 0) {
      datas = appWalletsLists;
    } else if (page == 1) {
      datas = leadInWalletsLists;
    } else if (page == 2) {
      datas = firmWalletLists;
    } else {
      datas = nfcWalletsLists;
    }
    return datas;
  }

  void _walletCategoryClick(int page) async {
    currentPage = page;
    LogUtil.v("_walletCategoryClick $page");
    Future.delayed(Duration(milliseconds: 500)).then((value) => {
          _findWalletsWithDB(page),
        });
  }

  void _headerAsssetsClick() {
    Routers.push(context, Routers.assetsListPage,
        params: {"originAssets": originAssets});
  }

  void _cellContentSelectRowAt(int page, int index) async {
    LogUtil.v("点击钱包整体");
    List<MHWallet> datas = _findWallets(page);
    MHWallet wallet = datas[index];
    if (await MHWallet.updateChoose(wallet)) {
      Routers.goBackWithParams(context, {"walletID": wallet.walletID});
    }
  }

  void _cellDetailDidSelect(int page, int index) {
    List<MHWallet> datas = _findWallets(page);
    MHWallet wallet = datas[index];
    MHWallet.updateChoose(wallet);
    Routers.push(context, Routers.walletInfoPagePage,
            params: {"walletID": wallet.walletID})
        .then((value) => {_findWalletsWithDB(currentPage)});
  }

  Widget _cellBuilder(int index, int page) {
    List<MHWallet> datas = _findWallets(page);
    MHWallet wallet = datas[index];
    String logoPath = Constant.getChainLogo(wallet.chainType);
    String name = Constant.getChainSymbol(wallet.chainType) + "-wallet";
    String address = wallet?.walletAaddress;
    String logodetail = Constant.ASSETS_IMG + "icon/wallet_detail.png";
    return Container(
      alignment: Alignment.center,
      // color: Colors.red,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _cellContentSelectRowAt(page, index),
            child: Container(
              // color: Colors.blue,
              height: OffsetWidget.setSc(54),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  LoadAssetsImage(
                    logoPath,
                    width: OffsetWidget.setSc(28),
                    height: OffsetWidget.setSc(28),
                    fit: BoxFit.contain,
                  ),
                  OffsetWidget.hGap(9),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                              fontSize: OffsetWidget.setSp(16),
                              fontWeight: FontWeight.w400,
                              color: Color(0XFF171F24)),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                        OffsetWidget.vGap(3),
                        Text(
                          address,
                          style: TextStyle(
                              fontSize: OffsetWidget.setSp(10),
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9B9B9B)),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _cellDetailDidSelect(page, index),
                    child: Container(
                      // color: Colors.red,
                      alignment: Alignment.centerRight,
                      width: OffsetWidget.setSc(40),
                      height: OffsetWidget.setSc(40),
                      child: LoadAssetsImage(
                        logodetail,
                        width: OffsetWidget.setSc(13),
                        height: OffsetWidget.setSc(3),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 1,
            color: Color(0xFFCFCFCF),
          ),
        ],
      ),
    );
  }

  Widget _headerBuilder() {
    String backimg = Constant.ASSETS_IMG + "background/bg_asset.png";
    return GestureDetector(
      onTap: () => _headerAsssetsClick(),
      child: Container(
          margin: EdgeInsets.only(
              left: OffsetWidget.setSc(16), right: OffsetWidget.setSc(16)),
          padding: EdgeInsets.only(
              left: OffsetWidget.setSc(10), right: OffsetWidget.setSc(10)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                backimg,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "wallet_allassets".local(),
                style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w400,
                    fontSize: OffsetWidget.setSp(11)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "≈",
                    style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: OffsetWidget.setSp(24),
                        fontWeight: FontWeight.w500),
                  ),
                  OffsetWidget.hGap(5),
                  Container(
                    // color: Colors.amber,
                    constraints: BoxConstraints(
                      maxWidth: OffsetWidget.setSc(255),
                    ),
                    child: Text(
                      allAssetsValue,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: OffsetWidget.setSp(32),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  OffsetWidget.hGap(5),
                  Text(
                    amountType == 0 ? "￥" : "\$",
                    style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: OffsetWidget.setSp(24),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget _getPageViewWidget(int page) {
    List datas = _findWallets(page);
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 32, right: 25),
      child: ListView.builder(
        itemCount: datas.length,
        itemBuilder: (BuildContext context, int index) {
          return _cellBuilder(index, page);
        },
      ),
    );
  }

  List<Widget> getBarAction() {
    return <Widget>[
      GestureDetector(
        onTap: () => {
          Routers.push(context, Routers.chooseTypePage).then((value) => {
                LogUtil.v("收到返回的数据 " + value.toString()),
              }),
        },
        child: LoadAssetsImage(
          Constant.ASSETS_IMG + "icon/wallet_insert.png",
          width: OffsetWidget.setSc(44),
          height: OffsetWidget.setSc(44),
          fit: BoxFit.contain,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _myTabs.length,
      child: CustomPageView(
        hiddenScrollView: true,
        actions: getBarAction(),
        title: Text(
          "my_wallet".local(),
          style: TextStyle(
              color: Color(0xFF000000),
              fontWeight: FontWeight.w400,
              fontSize: OffsetWidget.setSc(18)),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Container(),
        ),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: OffsetWidget.setSc(100),
                  child: _headerBuilder(),
                ),
                Material(
                    color: Colors.white,
                    child: Theme(
                      data: ThemeData(
                          splashColor: Color.fromRGBO(0, 0, 0, 0),
                          highlightColor: Color.fromRGBO(0, 0, 0, 0)),
                      child: TabBar(
                        tabs: _myTabs,
                        indicatorColor: Color(0xFF4A4A4A),
                        indicatorWeight: 2,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: Color(0xFF4A4A4A),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        unselectedLabelColor: Color(0xFF9B9B9B),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        onTap: (page) => {
                          _walletCategoryClick(page),
                        },
                      ),
                    )),
              ],
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(), //禁止左右滑动
                children: _myTabs.map((Tab tab) {
                  return _getPageViewWidget(
                    _myTabs.indexOf(tab),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
