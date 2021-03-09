import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coinid/models/transrecord/trans_record.dart';
import 'package:flutter_coinid/net/chain_services.dart';
import 'package:flutter_coinid/utils/sharedPrefer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../public.dart';

class TransListPage extends StatefulWidget {
  TransListPage({
    Key key,
    this.params,
  }) : super(key: key);
  Map params = Map();

  @override
  _TransListPageState createState() => _TransListPageState();
}

class _TransListPageState extends State<TransListPage> {
  double tokenPrice = 0;

  String chainType;
  String token;
  String decimals;
  String contract;
  String walletAddress;
  String balance;
  String total;

  final List<Tab> _myTabs = <Tab>[
    Tab(text: 'wallets_all'.local()),
    Tab(text: 'payment_transtout'.local()),
    Tab(text: 'wallets_transin'.local()),
    Tab(text: 'wallets_transerr'.local()),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.params != null) {
      chainType = widget.params["chainType"][0];
      token = widget.params["token"][0];
      decimals = widget.params["decimals"][0];
      contract = widget.params["contract"][0];
      walletAddress = widget.params["walletAddress"][0];
      balance = widget.params["balance"][0];
      total = widget.params["total"][0];
    }
    _initData();
  }

  _initData() async {
    int amountType = await getAmountValue();
    String assets = "≈" + (amountType == 0 ? "￥" : "\$");
    LogUtil.v(
        "_initData $chainType walletAddress $walletAddress contract $contract");
    String coinType = Constant.getChainSymbol(int.tryParse(chainType));
    ChainServices.requestAssets(
      chainType: coinType,
      from: walletAddress,
      contract: contract,
      token: token,
      block: (result, code) {
        if (code == 200 && result is Map && mounted) {
          String balance = result["c"] as String;
          String price =
              amountType == 0 ? result["p"] as String : result["up"] as String;
          price = price.length == 0 ? "0" : price;
          setState(() {
            tokenPrice = double.tryParse(price);
            balance = balance;
            total = assets +
                (double.tryParse(balance) * tokenPrice).toStringAsFixed(2);
          });
        }
      },
    );
  }

  void _walletCategoryClick(int page) async {
    // _refreshTransList(page);
  }

  void _receiveClick() {
    Map<String, dynamic> params = HashMap();
    params["walletAddress"] = walletAddress;
    params["contract"] = contract;
    params["token"] = token;
    params["decimals"] = decimals;
    params["chainType"] = chainType;
    params["onlyAddress"] = 0;
    Routers.push(context, Routers.recervePaymentPage, params: params);
  }

  void _paymentClick() {
    Map<String, dynamic> params = Map();
    params["contract"] = contract;
    params["token"] = token;
    params["decimals"] = decimals;
    Routers.push(context, Routers.paymentPage, params: params).then((value) => {
          _initData(),
          // _refreshTransList(0),
        });
  }

  Widget _headerBuilder() {
    return GestureDetector(
      onTap: () {},
      child: Container(
          child: Column(
        children: [
          OffsetWidget.vGap(25),
          GestureDetector(
            onTap: () {
              if (walletAddress.isValid() == false) return;
              Clipboard.setData(ClipboardData(text: walletAddress));
              HWToast.showText(text: "copy_success".local());
            },
            child: Container(
              alignment: Alignment.center,
              width: OffsetWidget.setSc(300),
              child: RichText(
                maxLines: 3,
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: walletAddress,
                  style: TextStyle(
                      color: Color(0xFF171F24),
                      fontWeight: FontWeight.w400,
                      fontSize: OffsetWidget.setSp(10)),
                  children: [
                    WidgetSpan(
                      child: OffsetWidget.hGap(10),
                    ),
                    WidgetSpan(
                      child: LoadAssetsImage(
                        Constant.ASSETS_IMG + "icon/icon_copy.png",
                        scale: 2,
                        fit: null,
                        width: 10,
                        height: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          OffsetWidget.vGap(5),
          Container(
            alignment: Alignment.center,
            width: OffsetWidget.setSc(300),
            child: Text(
              balance,
              style: TextStyle(
                  color: Color(0xFF171F24),
                  fontWeight: FontWeight.w400,
                  fontSize: OffsetWidget.setSp(26)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: OffsetWidget.setSc(300),
            child: Text(
              total,
              style: TextStyle(
                  color: Color(0xFFACBBCF),
                  fontWeight: FontWeight.w400,
                  fontSize: OffsetWidget.setSp(16)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _myTabs.length,
      child: CustomPageView(
        hiddenScrollView: true,
        title: CustomPageView.getIconSmallTitle(
            smallIconPath: Constant.ASSETS_IMG + "wallet/wallet_dot.png",
            smallTitle: "Bytom",
            bigTitle: token),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Text(""),
        ),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: OffsetWidget.setSc(140),
                  padding: EdgeInsets.only(left: 16, right: 16),
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
                        indicatorColor: Color(0xFF586883),
                        indicatorWeight: 2,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: Color(0xFF586883),
                        labelStyle: TextStyle(
                          fontSize: OffsetWidget.setSp(16),
                          fontWeight: FontWeight.w500,
                        ),
                        unselectedLabelColor: Color(0xFFACBBCF),
                        unselectedLabelStyle: TextStyle(
                          fontSize: OffsetWidget.setSp(14),
                          fontWeight: FontWeight.w500,
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
                children: [
                  MTransListPage(
                    token: token,
                    selectIndex: MTransType.MTransType_All,
                    contract: contract,
                    walletAddress: walletAddress,
                    tokenPrice: tokenPrice,
                    chainType: chainType,
                  ),
                  MTransListPage(
                    token: token,
                    selectIndex: MTransType.MTransType_Out,
                    contract: contract,
                    walletAddress: walletAddress,
                    tokenPrice: tokenPrice,
                    chainType: chainType,
                  ),
                  MTransListPage(
                    token: token,
                    selectIndex: MTransType.MTransType_In,
                    contract: contract,
                    walletAddress: walletAddress,
                    tokenPrice: tokenPrice,
                    chainType: chainType,
                  ),
                  MTransListPage(
                    token: token,
                    selectIndex: MTransType.MTransType_Err,
                    contract: contract,
                    walletAddress: walletAddress,
                    tokenPrice: tokenPrice,
                    chainType: chainType,
                  )
                ],
              ),
            ),
            Container(
              height: OffsetWidget.setSc(100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _paymentClick,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            Constant.ASSETS_IMG + "icon/icon_normal.png",
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                      height: OffsetWidget.setSc(40),
                      width: OffsetWidget.setSc(160),
                      child: Text(
                        "trans_payment".local(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: OffsetWidget.setSp(14),
                            fontWeight: FontWightHelper.medium),
                      ),
                    ),
                  ),
                  OffsetWidget.hGap(15),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _receiveClick,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            Constant.ASSETS_IMG + "icon/icon_green.png",
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                      height: OffsetWidget.setSc(40),
                      width: OffsetWidget.setSc(160),
                      child: Text(
                        "trans_receive".local(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: OffsetWidget.setSp(14),
                            fontWeight: FontWightHelper.medium),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MTransListPage extends StatefulWidget {
  MTransListPage(
      {Key key,
      this.tokenPrice,
      this.selectIndex,
      this.contract,
      this.walletAddress,
      this.token,
      this.chainType})
      : super(key: key);
  final double tokenPrice;
  final MTransType selectIndex;
  final String contract;
  final String walletAddress;
  final String token;
  final String chainType;

  @override
  _MTransListPageState createState() => _MTransListPageState();
}

class _MTransListPageState extends State<MTransListPage>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
    initialLoadStatus: LoadStatus.idle,
  );
  List<MHTransRecordModel> _datas = [];
  int _page = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LogUtil.v("_MTransListPageState ");
    _requestTransListWithNet(_page);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void _requestTransListWithNet(int page) async {
    _page = page;
    MTransType selectIndex = widget.selectIndex;
    int chainType = int.tryParse(widget.chainType);
    String from = widget.walletAddress;
    String contract = widget.contract;
    LogUtil.v(
        "_requestTransListWithNet $from chainType $chainType  selectIndex $selectIndex _page $_page");
    HWToast.showLoading(clickClose: true);
    ChainServices.requestTransRecord(
        chainType, selectIndex, from, contract, page, (result, code) {
      HWToast.hiddenAllToast();
      _refreshController.loadComplete();
      _refreshController.refreshCompleted(resetFooterState: true);
      if (code == 200 && mounted && result != null) {
        setState(() {
          if (page == 1) {
            _datas.clear();
          }
          _datas.addAll(result);
        });
      }
    });
  }

  void _cellContentSelectRowAt(int index) {
    LogUtil.v("点击钱包整体");
    MHTransRecordModel transModel = _datas[index];
    String transStr = transModel.toString();
    Map<String, dynamic> params = {
      "transModel": transStr,
      "price": widget.tokenPrice.toString()
    };
    Routers.push(context, Routers.transDetailPage, params: params);
  }

  Widget _cellBuilder(int index) {
    MHTransRecordModel transModel = _datas[index];
    String logoPath;
    String to = transModel.to ??= "";
    String date = transModel.date;
    String amount = "";
    String remarks = transModel.remarks ??= "";
    Color txtColor;
    if (transModel.isOut == true) {
      logoPath = Constant.ASSETS_IMG + "icon/trans_out.png";
      txtColor = Color(0xFF586883);
      amount = "-";
      remarks = "translist_transoutsuccess".local();
    } else {
      logoPath = Constant.ASSETS_IMG + "icon/trans_in.png";
      txtColor = Color(0xFF586883);
      amount = "+";
      remarks = "translist_transinsuccess".local();
    }
    amount += transModel.amount + " ${transModel.token}";
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _cellContentSelectRowAt(index),
            child: Container(
              // width: OffsetWidget.setSc(309),
              height: OffsetWidget.setSc(60),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: OffsetWidget.setSc(16)),
                    child: LoadAssetsImage(
                      logoPath,
                      width: OffsetWidget.setSc(26),
                      height: OffsetWidget.setSc(26),
                      fit: BoxFit.contain,
                    ),
                  ),
                  OffsetWidget.hGap(12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: OffsetWidget.setSc(150),
                              child: Text(
                                to,
                                style: TextStyle(
                                    fontSize: OffsetWidget.setSp(14),
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF4A4A4A)),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            OffsetWidget.vGap(3),
                            Expanded(
                              child: Text(
                                amount,
                                style: TextStyle(
                                    fontSize: OffsetWidget.setSp(16),
                                    fontWeight: FontWeight.w400,
                                    color: txtColor),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: OffsetWidget.setSc(150),
                              child: Text(
                                date,
                                style: TextStyle(
                                    fontSize: OffsetWidget.setSp(10),
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF9B9B9B)),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            OffsetWidget.vGap(3),
                            Expanded(
                              child: Text(
                                remarks,
                                style: TextStyle(
                                    fontSize: OffsetWidget.setSp(10),
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF33D371)),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 1,
            color: Color(0xFFEAEFF2),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 32, right: 25),
      child: CustomRefresher(
        refreshController: _refreshController,
        onRefresh: () {
          _requestTransListWithNet(1);
        },
        onLoading: () {
          _requestTransListWithNet(_page + 1);
        },
        child: _datas.length == 0
            ? EmptyDataPage(
                refreshAction: () => {
                  _requestTransListWithNet(1),
                },
              )
            : ListView.builder(
                itemCount: _datas.length,
                itemBuilder: (BuildContext context, int index) {
                  return _cellBuilder(index);
                },
              ),
      ),
    );
  }
}
